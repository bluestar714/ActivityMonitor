//
//  ActivityMonitorWidgetBundle.swift
//  ActivityMonitorWidget
//
//  Created by 青木佑一郎 on 2025/11/02.
//

import WidgetKit
import SwiftUI

@main
struct ActivityMonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActivityMonitorWidget()
        if #available(iOS 16.1, *) {
            ActivityMonitorWidgetLiveActivity()
        }
    }
}
