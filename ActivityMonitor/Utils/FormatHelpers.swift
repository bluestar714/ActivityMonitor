//
//  FormatHelpers.swift
//  ActivityMonitor
//
//  Utility functions for formatting metrics data
//

import Foundation

struct FormatHelpers {

    // MARK: - Byte Formatting

    static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: Int64(bytes))
    }

    static func formatBytesCompact(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        let mb = Double(bytes) / 1_048_576.0
        let kb = Double(bytes) / 1024.0

        if gb >= 1.0 {
            return String(format: "%.1f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.0f MB", mb)
        } else {
            return String(format: "%.0f KB", kb)
        }
    }

    // MARK: - Speed Formatting

    static func formatSpeed(_ bytesPerSecond: Double) -> String {
        let mbps = bytesPerSecond / 1_048_576.0
        let kbps = bytesPerSecond / 1024.0

        if mbps >= 1.0 {
            return String(format: "%.1f MB/s", mbps)
        } else if kbps >= 1.0 {
            return String(format: "%.0f KB/s", kbps)
        } else {
            return String(format: "%.0f B/s", bytesPerSecond)
        }
    }

    static func formatSpeedCompact(_ bytesPerSecond: Double) -> String {
        let mbps = bytesPerSecond / 1_048_576.0
        let kbps = bytesPerSecond / 1024.0

        if mbps >= 1.0 {
            return String(format: "%.1f M", mbps)
        } else if kbps >= 1.0 {
            return String(format: "%.0f K", kbps)
        } else {
            return String(format: "%.0f", bytesPerSecond)
        }
    }

    // MARK: - Percentage Formatting

    static func formatPercentage(_ value: Double, decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f%%", value)
    }

    // MARK: - Time Formatting

    static func formatUptime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Number Formatting

    static func formatLargeNumber(_ number: UInt64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension TimeInterval {
    var formatted: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
