//
//  SystemMetricsCollector.swift
//  ActivityMonitor
//
//  Low-level system metrics collection using iOS APIs
//

import Foundation
import UIKit
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import Network
import NetworkExtension
import Metal

class SystemMetricsCollector {

    // MARK: - CPU Metrics

    // Store previous CPU info for delta calculation
    private var previousCPUInfo: (user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)?
    private let cpuLock = NSLock()

    func collectCPUMetrics() -> CPUMetrics {
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: uint = 0

        var totalUsage: Double = 0.0
        var userTime: Double = 0.0
        var systemTime: Double = 0.0
        var idleTime: Double = 0.0

        var mibKeys: [Int32] = [CTL_HW, HW_NCPU]
        var sizeOfNumCPUs = MemoryLayout<uint>.size
        let status = mibKeys.withUnsafeMutableBufferPointer { mib in
            sysctl(mib.baseAddress, 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
        }

        if status == 0 {
            cpuLock.lock()
            defer { cpuLock.unlock() }

            var numCPUsU = natural_t(numCPUs)

            let err: kern_return_t = host_processor_info(
                mach_host_self(),
                PROCESSOR_CPU_LOAD_INFO,
                &numCPUsU,
                &cpuInfo,
                &numCpuInfo
            )

            if err == KERN_SUCCESS {
                var totalUser: UInt32 = 0
                var totalSystem: UInt32 = 0
                var totalIdle: UInt32 = 0
                var totalNice: UInt32 = 0

                for i in 0..<Int(numCPUs) {
                    let cpuLoadInfo = cpuInfo.advanced(by: Int(i) * Int(CPU_STATE_MAX))

                    totalUser += UInt32(cpuLoadInfo[Int(CPU_STATE_USER)])
                    totalSystem += UInt32(cpuLoadInfo[Int(CPU_STATE_SYSTEM)])
                    totalIdle += UInt32(cpuLoadInfo[Int(CPU_STATE_IDLE)])
                    totalNice += UInt32(cpuLoadInfo[Int(CPU_STATE_NICE)])
                }

                // Calculate delta from previous measurement
                if let previous = previousCPUInfo {
                    let userDiff = totalUser > previous.user ? totalUser - previous.user : 0
                    let systemDiff = totalSystem > previous.system ? totalSystem - previous.system : 0
                    let idleDiff = totalIdle > previous.idle ? totalIdle - previous.idle : 0
                    let niceDiff = totalNice > previous.nice ? totalNice - previous.nice : 0

                    let totalDiff = userDiff + systemDiff + idleDiff + niceDiff

                    if totalDiff > 0 {
                        userTime = Double(userDiff + niceDiff) / Double(totalDiff) * 100.0
                        systemTime = Double(systemDiff) / Double(totalDiff) * 100.0
                        idleTime = Double(idleDiff) / Double(totalDiff) * 100.0
                        totalUsage = 100.0 - idleTime
                    }
                } else {
                    // First measurement - use absolute values
                    let totalTicks = totalUser + totalSystem + totalIdle + totalNice
                    if totalTicks > 0 {
                        userTime = Double(totalUser + totalNice) / Double(totalTicks) * 100.0
                        systemTime = Double(totalSystem) / Double(totalTicks) * 100.0
                        idleTime = Double(totalIdle) / Double(totalTicks) * 100.0
                        totalUsage = 100.0 - idleTime
                    }
                }

                // Store current values for next measurement
                previousCPUInfo = (totalUser, totalSystem, totalIdle, totalNice)

                // Clean up
                vm_deallocate(
                    mach_task_self_,
                    vm_address_t(bitPattern: cpuInfo),
                    vm_size_t(MemoryLayout<integer_t>.stride * Int(numCpuInfo))
                )
            }
        }

        return CPUMetrics(
            usage: totalUsage,
            userTime: userTime,
            systemTime: systemTime,
            idleTime: idleTime,
            timestamp: Date()
        )
    }

    // MARK: - Memory Metrics

    func collectMemoryMetrics() -> MemoryMetrics {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result: kern_return_t = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return .zero
        }

        let pageSize = UInt64(vm_kernel_page_size)

        let free = UInt64(vmStats.free_count) * pageSize
        let active = UInt64(vmStats.active_count) * pageSize
        let inactive = UInt64(vmStats.inactive_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize

        // Get total physical memory
        let total = ProcessInfo.processInfo.physicalMemory

        let used = active + wired + compressed

        return MemoryMetrics(
            used: used,
            total: total,
            free: free,
            active: active,
            inactive: inactive,
            wired: wired,
            compressed: compressed,
            timestamp: Date()
        )
    }

    // MARK: - Network Metrics

    private var previousNetworkMetrics: (received: UInt64, sent: UInt64, timestamp: Date)?

    func collectNetworkMetrics() -> NetworkMetrics {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var totalBytesReceived: UInt64 = 0
        var totalBytesSent: UInt64 = 0
        var totalPacketsReceived: UInt64 = 0
        var totalPacketsSent: UInt64 = 0

        guard getifaddrs(&ifaddr) == 0 else {
            return .zero
        }

        var pointer = ifaddr
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }

            guard let interface = pointer?.pointee else { continue }
            let name = String(cString: interface.ifa_name)

            // Only count non-loopback interfaces
            guard name != "lo0" else { continue }

            if interface.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                let data = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>.self)

                totalBytesReceived += UInt64(data.pointee.ifi_ibytes)
                totalBytesSent += UInt64(data.pointee.ifi_obytes)
                totalPacketsReceived += UInt64(data.pointee.ifi_ipackets)
                totalPacketsSent += UInt64(data.pointee.ifi_opackets)
            }
        }

        freeifaddrs(ifaddr)

        let currentTimestamp = Date()
        var downloadSpeed: Double = 0
        var uploadSpeed: Double = 0

        if let previous = previousNetworkMetrics {
            let timeInterval = currentTimestamp.timeIntervalSince(previous.timestamp)
            if timeInterval > 0 {
                let receivedDiff = totalBytesReceived > previous.received ? totalBytesReceived - previous.received : 0
                let sentDiff = totalBytesSent > previous.sent ? totalBytesSent - previous.sent : 0

                downloadSpeed = Double(receivedDiff) / timeInterval
                uploadSpeed = Double(sentDiff) / timeInterval
            }
        }

        previousNetworkMetrics = (totalBytesReceived, totalBytesSent, currentTimestamp)

        return NetworkMetrics(
            bytesReceived: totalBytesReceived,
            bytesSent: totalBytesSent,
            packetsReceived: totalPacketsReceived,
            packetsSent: totalPacketsSent,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            timestamp: currentTimestamp
        )
    }

    // MARK: - Storage Metrics

    func collectStorageMetrics() -> StorageMetrics {
        let fileManager = FileManager.default

        do {
            let systemAttributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())

            let totalSpace = (systemAttributes[.systemSize] as? NSNumber)?.uint64Value ?? 0
            let freeSpace = (systemAttributes[.systemFreeSize] as? NSNumber)?.uint64Value ?? 0
            let usedSpace = totalSpace - freeSpace

            return StorageMetrics(
                total: totalSpace,
                used: usedSpace,
                free: freeSpace,
                timestamp: Date()
            )
        } catch {
            print("Error collecting storage metrics: \(error)")
            return .zero
        }
    }

    // MARK: - Battery Metrics

    func collectBatteryMetrics() -> BatteryMetrics {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState

        let level = batteryLevel >= 0 ? Double(batteryLevel) * 100.0 : 0.0

        let state: BatteryMetrics.BatteryState
        var isCharging = false

        switch batteryState {
        case .charging:
            state = .charging
            isCharging = true
        case .full:
            state = .full
            isCharging = true
        case .unplugged:
            state = .unplugged
            isCharging = false
        case .unknown:
            state = .unknown
            isCharging = false
        @unknown default:
            state = .unknown
            isCharging = false
        }

        return BatteryMetrics(
            level: level,
            state: state,
            isCharging: isCharging,
            timestamp: Date()
        )
    }

    // MARK: - Disk I/O Metrics

    private var previousDiskIO: (pageins: UInt64, pageouts: UInt64, timestamp: Date)?
    private let diskIOLock = NSLock()

    func collectDiskIOMetrics() -> DiskIOMetrics {
        diskIOLock.lock()
        defer { diskIOLock.unlock() }

        // Use vm_statistics64 to get system-wide paging activity
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result: kern_return_t = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return .zero
        }

        let pageSize = UInt64(vm_kernel_page_size)

        // Get total pageins and pageouts (system-wide disk activity)
        let totalPageins = UInt64(vmStats.pageins)
        let totalPageouts = UInt64(vmStats.pageouts)

        // Convert pages to bytes
        let readBytes = totalPageins * pageSize
        let writeBytes = totalPageouts * pageSize

        var readSpeed: Double = 0.0
        var writeSpeed: Double = 0.0

        let now = Date()

        if let previous = previousDiskIO {
            let timeDelta = now.timeIntervalSince(previous.timestamp)
            if timeDelta > 0 {
                let pageinsDelta = totalPageins > previous.pageins ? totalPageins - previous.pageins : 0
                let pageoutsDelta = totalPageouts > previous.pageouts ? totalPageouts - previous.pageouts : 0

                readSpeed = Double(pageinsDelta * pageSize) / timeDelta
                writeSpeed = Double(pageoutsDelta * pageSize) / timeDelta
            }
        }

        previousDiskIO = (totalPageins, totalPageouts, now)

        return DiskIOMetrics(
            readBytes: readBytes,
            writeBytes: writeBytes,
            readSpeed: readSpeed,
            writeSpeed: writeSpeed,
            timestamp: now
        )
    }

    // MARK: - Collect All Metrics

    func collectAllMetrics() -> MetricsSnapshot {
        return MetricsSnapshot(
            cpu: collectCPUMetrics(),
            memory: collectMemoryMetrics(),
            network: collectNetworkMetrics(),
            storage: collectStorageMetrics(),
            battery: collectBatteryMetrics(),
            diskIO: collectDiskIOMetrics(),
            timestamp: Date()
        )
    }

    // MARK: - Network Details

    func collectNetworkDetails() -> NetworkDetails {
        var interfaceType = "Unknown"
        var interfaceName: String?
        var ipv4Address: String?
        var ipv6Address: String?
        var subnetMask: String?
        var defaultGateway: String?
        var dnsServers: [String] = []
        var isVPNActive = false
        var isProxyEnabled = false
        var proxyServer: String?
        var ssid: String?
        var bssid: String?
        var rssi: Int?
        var securityType: String?
        var wifiBand: String?
        var isHotspotActive = false
        var externalIP: String?

        // Check interfaces
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return .zero
        }
        defer { freeifaddrs(ifaddr) }

        var pointer = ifaddr
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }

            guard let interface = pointer?.pointee else { continue }
            let name = String(cString: interface.ifa_name)

            // Skip loopback
            if name == "lo0" { continue }

            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Determine interface type
                if name.starts(with: "en") {
                    interfaceType = "WiFi"
                    interfaceName = name
                } else if name.starts(with: "pdp_ip") {
                    interfaceType = "Cellular"
                    interfaceName = name
                } else if name.starts(with: "utun") || name.starts(with: "ipsec") {
                    isVPNActive = true
                    interfaceType = "VPN"
                    interfaceName = name
                }

                // Get IP address
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, socklen_t(0), NI_NUMERICHOST)

                let address = String(cString: hostname)

                if addrFamily == UInt8(AF_INET) {
                    if ipv4Address == nil {
                        ipv4Address = address
                    }

                    // Get subnet mask
                    if let netmask = interface.ifa_netmask {
                        var netmaskHost = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(netmask, socklen_t(netmask.pointee.sa_len),
                                   &netmaskHost, socklen_t(netmaskHost.count),
                                   nil, socklen_t(0), NI_NUMERICHOST)
                        if subnetMask == nil {
                            subnetMask = String(cString: netmaskHost)
                        }
                    }
                } else if addrFamily == UInt8(AF_INET6) {
                    if ipv6Address == nil && !address.starts(with: "fe80") {
                        ipv6Address = address
                    }
                }
            }
        }

        // Get default gateway
        defaultGateway = getDefaultGateway()

        // Get DNS servers
        dnsServers = getDNSServers()

        // Check for proxy
        if let proxies = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] {
            if let httpProxy = proxies["HTTPProxy"] as? String {
                isProxyEnabled = true
                proxyServer = httpProxy
                if let port = proxies["HTTPPort"] as? Int {
                    proxyServer = "\(httpProxy):\(port)"
                }
            }
        }

        // Get WiFi info (requires location permissions and entitlements)
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                    ssid = info[kCNNetworkInfoKeySSID as String] as? String
                    bssid = info[kCNNetworkInfoKeyBSSID as String] as? String
                }
            }
        }

        // Try to get WiFi band information (iOS 14+)
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                if let network = network {
                    ssid = network.ssid
                    bssid = network.bssid

                    // Determine band based on signal strength and frequency
                    // Note: Direct frequency access is not available, but we can infer from other properties
                    // This is an approximation
                    if network.signalStrength > 0.7 {
                        // Strong signal might indicate 5GHz
                        wifiBand = "5 GHz (inferred)"
                    } else {
                        wifiBand = "2.4 GHz (inferred)"
                    }
                }
            }
        }

        // Get cellular info
        let telephonyInfo = CTTelephonyNetworkInfo()
        var carrierName: String?
        var phoneNumber: String?
        var connectionType: String?
        var cellularBand: String?
        var mobileCountryCode: String?
        var mobileNetworkCode: String?
        var isoCountryCode: String?
        var allowsVOIP: Bool?

        if let carrier = telephonyInfo.serviceSubscriberCellularProviders?.values.first {
            carrierName = carrier.carrierName
            mobileCountryCode = carrier.mobileCountryCode
            mobileNetworkCode = carrier.mobileNetworkCode
            isoCountryCode = carrier.isoCountryCode
            allowsVOIP = carrier.allowsVOIP
        }

        if let currentRadioTech = telephonyInfo.serviceCurrentRadioAccessTechnology?.values.first {
            connectionType = getRadioTechnologyName(currentRadioTech)
            cellularBand = getCellularBandInfo(currentRadioTech, isoCountryCode: isoCountryCode)
        }

        // Check if hotspot is active (approximation - check for bridge interfaces)
        pointer = ifaddr
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }
            guard let interface = pointer?.pointee else { continue }
            let name = String(cString: interface.ifa_name)
            if name.starts(with: "bridge") {
                isHotspotActive = true
                break
            }
        }

        // Get network statistics
        var totalBytesSent: UInt64 = 0
        var totalBytesReceived: UInt64 = 0

        pointer = ifaddr
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }
            guard let interface = pointer?.pointee else { continue }
            let name = String(cString: interface.ifa_name)

            // Skip loopback
            if name == "lo0" { continue }

            if let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalBytesSent += UInt64(data.pointee.ifi_obytes)
                totalBytesReceived += UInt64(data.pointee.ifi_ibytes)
            }
        }

        return NetworkDetails(
            interfaceType: interfaceType,
            interfaceName: interfaceName,
            isVPNActive: isVPNActive,
            isProxyEnabled: isProxyEnabled,
            proxyServer: proxyServer,
            isHotspotActive: isHotspotActive,
            ipv4Address: ipv4Address,
            ipv6Address: ipv6Address,
            subnetMask: subnetMask,
            defaultGateway: defaultGateway,
            externalIP: externalIP,
            dnsServers: dnsServers,
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            securityType: securityType,
            wifiBand: wifiBand,
            carrierName: carrierName,
            phoneNumber: phoneNumber,
            connectionType: connectionType,
            cellularBand: cellularBand,
            mobileCountryCode: mobileCountryCode,
            mobileNetworkCode: mobileNetworkCode,
            isoCountryCode: isoCountryCode,
            allowsVOIP: allowsVOIP,
            totalBytesSent: totalBytesSent,
            totalBytesReceived: totalBytesReceived
        )
    }

    private func getDefaultGateway() -> String? {
        // iOS doesn't provide easy access to routing table
        // Return nil for now
        return nil
    }

    private func getDNSServers() -> [String] {
        var dnsServers: [String] = []

        // Try to get DNS servers from resolv.conf (limited on iOS)
        if let resolvPath = Bundle.main.path(forResource: "resolv", ofType: "conf") {
            do {
                let content = try String(contentsOfFile: resolvPath, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines)
                for line in lines {
                    if line.starts(with: "nameserver") {
                        let components = line.components(separatedBy: .whitespaces)
                        if components.count >= 2 {
                            dnsServers.append(components[1])
                        }
                    }
                }
            } catch {
                // Failed to read file
            }
        }

        // Fallback: Common DNS servers (Google, Cloudflare)
        if dnsServers.isEmpty {
            // Note: This is just a placeholder. Actual DNS servers can't be reliably determined on iOS
            // without jailbreak or special entitlements
        }

        return dnsServers
    }

    private func getRadioTechnologyName(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyGPRS:
            return "GPRS"
        case CTRadioAccessTechnologyEdge:
            return "EDGE"
        case CTRadioAccessTechnologyWCDMA:
            return "3G (WCDMA)"
        case CTRadioAccessTechnologyHSDPA:
            return "3G (HSDPA)"
        case CTRadioAccessTechnologyHSUPA:
            return "3G (HSUPA)"
        case CTRadioAccessTechnologyCDMA1x:
            return "CDMA 1x"
        case CTRadioAccessTechnologyCDMAEVDORev0:
            return "CDMA EV-DO Rev. 0"
        case CTRadioAccessTechnologyCDMAEVDORevA:
            return "CDMA EV-DO Rev. A"
        case CTRadioAccessTechnologyCDMAEVDORevB:
            return "CDMA EV-DO Rev. B"
        case CTRadioAccessTechnologyeHRPD:
            return "eHRPD"
        case CTRadioAccessTechnologyLTE:
            return "4G (LTE)"
        default:
            if #available(iOS 14.1, *) {
                if tech == CTRadioAccessTechnologyNRNSA {
                    return "5G (NSA)"
                } else if tech == CTRadioAccessTechnologyNR {
                    return "5G"
                }
            }
            return "Unknown"
        }
    }

    private func getCellularBandInfo(_ tech: String, isoCountryCode: String?) -> String? {
        // Note: iOS doesn't provide direct access to cellular band information
        // This is an approximation based on technology type and region

        if #available(iOS 14.1, *) {
            if tech == CTRadioAccessTechnologyNR || tech == CTRadioAccessTechnologyNRNSA {
                // 5G bands vary by region
                if isoCountryCode == "jp" {
                    return "n77, n78, n79 (typical)"
                } else if isoCountryCode == "us" {
                    return "n41, n71, n260, n261 (typical)"
                } else {
                    return "n1, n3, n28, n77, n78 (typical)"
                }
            }
        }

        if tech == CTRadioAccessTechnologyLTE {
            // LTE bands vary by region
            if isoCountryCode == "jp" {
                return "B1, B3, B8, B11, B18, B19, B21, B28, B42 (typical)"
            } else if isoCountryCode == "us" {
                return "B2, B4, B5, B12, B13, B66, B71 (typical)"
            } else {
                return "B1, B3, B7, B8, B20, B28 (typical)"
            }
        }

        // For 3G and earlier, band info is less critical
        return nil
    }

    // MARK: - GPU & Neural Engine Info

    func collectGPUInfo() -> GPUInfo {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return .zero
        }

        // GPU Family detection
        var family = "Unknown"
        if #available(iOS 16.0, *) {
            if device.supportsFamily(.apple9) {
                family = "Apple 9"
            } else if device.supportsFamily(.apple8) {
                family = "Apple 8"
            } else if device.supportsFamily(.apple7) {
                family = "Apple 7"
            } else if device.supportsFamily(.apple6) {
                family = "Apple 6"
            } else if device.supportsFamily(.apple5) {
                family = "Apple 5"
            } else if device.supportsFamily(.apple4) {
                family = "Apple 4"
            }
        }

        // Neural Engine detection based on device model
        var neuralEngineGen: String?
        var neuralEngineCores: Int?

        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? "Unknown"

        // Map device model to Neural Engine info
        if modelCode.contains("iPhone") {
            if modelCode.contains("16,") || modelCode.contains("17,") {
                neuralEngineGen = "Gen 6 (A17 Pro / A18)"
                neuralEngineCores = 16
            } else if modelCode.contains("15,") {
                neuralEngineGen = "Gen 5 (A16 Bionic)"
                neuralEngineCores = 16
            } else if modelCode.contains("14,") {
                neuralEngineGen = "Gen 4 (A15 Bionic)"
                neuralEngineCores = 16
            } else if modelCode.contains("13,") {
                neuralEngineGen = "Gen 3 (A14 Bionic)"
                neuralEngineCores = 16
            } else if modelCode.contains("12,") {
                neuralEngineGen = "Gen 2 (A13 Bionic)"
                neuralEngineCores = 8
            } else if modelCode.contains("11,") {
                neuralEngineGen = "Gen 1 (A12 Bionic)"
                neuralEngineCores = 8
            }
        } else if modelCode.contains("iPad") {
            if modelCode.contains("14,") || modelCode.contains("15,") {
                neuralEngineGen = "Gen 5/6 (M2/M4)"
                neuralEngineCores = 16
            } else if modelCode.contains("13,") {
                neuralEngineGen = "Gen 4 (M1/A14)"
                neuralEngineCores = 16
            }
        }

        // Check for advanced features
        let supportsRaytracing = device.supportsRaytracing

        // Mesh shaders support is inferred from GPU family
        let supportsMeshShaders = family.contains("Apple 8") || family.contains("Apple 9")

        return GPUInfo(
            name: device.name,
            family: family,
            maxThreadsPerThreadgroup: device.maxThreadsPerThreadgroup.width,
            recommendedMaxWorkingSetSize: device.recommendedMaxWorkingSetSize,
            currentAllocatedSize: UInt64(device.currentAllocatedSize),
            hasUnifiedMemory: device.hasUnifiedMemory,
            supportsRaytracing: supportsRaytracing,
            supportsMeshShaders: supportsMeshShaders,
            neuralEngineGeneration: neuralEngineGen,
            neuralEngineCores: neuralEngineCores
        )
    }
}
