//
//  PerfScopeXWidgetBundle.swift
//  PerfScopeXWidget
//
//  Created by 青木佑一郎 on 2025/11/02.
//

import WidgetKit
import SwiftUI

@main
struct PerfScopeXWidgetBundle: WidgetBundle {
    var body: some Widget {
        PerfScopeXWidget()
        if #available(iOS 16.1, *) {
            PerfScopeXWidgetLiveActivity()
        }
    }
}
