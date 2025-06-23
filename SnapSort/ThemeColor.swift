//
//  ThemeColor.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI

enum ThemeColor : String, Codable {
    case pink, orange, blue, green, custom

    var swiftUIColor: Color {
        switch self{
        case .orange: return .orange
        case .pink: return .pink
        case .blue: return .blue
        case .green: return .green
        case .custom: return .pink
            
    //pink for custom and shopping
    // blue for code
    // green for transport
    // orange for food
    
            
        }
        
    }
    
}
