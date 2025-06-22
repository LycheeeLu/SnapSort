//
//  ThemeColor.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI

enum ThemeColor : String, Codable {
    case pink, orange, custom

    var swiftUIColor: Color {
        switch self{
        case .orange: return .orange
        case .pink: return .pink
        case .custom: return .pink
        }
    }
    
}
