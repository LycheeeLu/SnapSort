//
//  Keyword+Helper.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//


import SwiftUI

// Helper method to check if snap text contains any keywords
extension Theme{
    func matches(text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return keywords.contains{
            keyword in
            lowercasedText.contains (keyword.lowercased())
        }
    }
}
