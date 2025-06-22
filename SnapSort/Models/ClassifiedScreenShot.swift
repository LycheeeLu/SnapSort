//
//  ClassifiedScreenShot.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI
import SwiftData
import Foundation

@Model
class ClassifiedScreenShot{
    
    var id: UUID
    var assetIdentifier: String
    var extractedText: String
    var dateClassified: Date
    var themes: [String]
    var confidence: Double // for future ML improvements
    
    
    init(assetIdentifier: String, extractedText: String, themes: [String], confidence: Double) {
        self.id = UUID()
        self.assetIdentifier = assetIdentifier
        self.extractedText = extractedText
        self.dateClassified = Date()
        self.themes = themes.isEmpty ? ["Uncategorized"] : themes
        self.confidence = confidence
    }
}
