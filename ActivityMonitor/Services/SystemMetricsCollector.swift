//
//  SystemMetricsCollector.swift
//  ActivityMonitor
//
//  Low-level system metrics collection using iOS APIs
//

import Foundation
import UIKit

class SystemMetricsCollector {

    // MARK: - CPU Metrics

    func collectCPUMetrics() -> CPUMetrics {
        var cpuInfo: processor_info_array_t!
        var prevCpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numPrevCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: uint = 0
        let CPUUsageLock = NSLock()

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
            CPUUsageLock.lock()

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

                let totalTicks = totalUser + totalSystem + totalIdle + totalNice

                if totalTicks > 0 {
                    userTime = Double(totalUser) / Double(totalTicks) * 100.0
                    systemTime = Double(totalSystem) / Double(totalTicks) * 100.0
                    idleTime = Double(totalIdle) / Double(totalTicks) * 100.0
                    totalUsage = 100.0 - idleTime
                }

                // Clean up
                let prevCpuInfoSize = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                if let prevCpuInfo = prevCpuInfo {
                    vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
                }

                prevCpuInfo = cpuInfo
                numPrevCpuInfo = numCpuInfo
            }

            CPUUsageLock.unlock()
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

    // MARK: - Collect All Metrics

    func collectAllMetrics() -> MetricsSnapshot {
        return MetricsSnapshot(
            cpu: collectCPUMetrics(),
            memory: collectMemoryMetrics(),
            network: collectNetworkMetrics(),
            storage: collectStorageMetrics(),
            timestamp: Date()
        )
    }
}
