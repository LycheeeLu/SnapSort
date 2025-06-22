//
//  Keyword.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftData
import SwiftUI
import Foundation


@Model
class Keyword{
    
    var id: UUID
    var name: String
    var keywords: [String]
    var color: ThemeColor
    var createdDate: Date
    
    init(name: String, keywords: [String], color: ThemeColor = .pink ) {
        self.id = UUID()
        self.name = name
        self.keywords = keywords
        self.color = color
        self.createdDate = Date()
    }
    
}
