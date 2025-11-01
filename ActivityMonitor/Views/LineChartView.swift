//
//  LineChartView.swift
//  ActivityMonitor
//
//  Lightweight real-time line chart for performance metrics
//

import SwiftUI

struct LineChartView: View {
    let data: [Double]
    let maxValue: Double
    let color: Color
    let showGradient: Bool

    init(data: [Double], maxValue: Double = 100.0, color: Color = .blue, showGradient: Bool = true) {
        self.data = data
        self.maxValue = maxValue
        self.color = color
        self.showGradient = showGradient
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                GridLines(maxValue: maxValue)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)

                // Gradient fill
                if showGradient && data.count > 1 {
                    LineChartShape(data: data, maxValue: maxValue)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                // Line
                if data.count > 1 {
                    LineChartShape(data: data, maxValue: maxValue)
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

struct LineChartShape: Shape {
    let data: [Double]
    let maxValue: Double

    func path(in rect: CGRect) -> Path {
        guard data.count > 1 else { return Path() }

        var path = Path()

        let stepX = rect.width / CGFloat(data.count - 1)
        let scale = rect.height / CGFloat(maxValue)

        // Start from bottom-left for fill
        path.move(to: CGPoint(x: 0, y: rect.height))

        // Draw line through data points
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height - (CGFloat(value) * scale)

            if index == 0 {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        // Close path for fill
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

struct GridLines: Shape {
    let maxValue: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Horizontal lines (5 lines)
        for i in 0...4 {
            let y = rect.height * CGFloat(i) / 4
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }

        return path
    }
}

// MARK: - Preview

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LineChartView(
                data: [20, 35, 45, 30, 55, 70, 45, 60, 40, 50],
                maxValue: 100,
                color: .blue
            )
            .frame(height: 100)
            .padding()

            LineChartView(
                data: [10, 20, 30, 40, 50, 60, 70, 80],
                maxValue: 100,
                color: .green
            )
            .frame(height: 100)
            .padding()
        }
    }
}
