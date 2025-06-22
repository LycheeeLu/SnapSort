//
//  ClassifiedScreenShot+Helper.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI

extension ClassifiedScreenShot{
    
    var hasThemes: Bool{
        !themes.isEmpty && themes != ["Uncategorized"]
    }
    
    var isUncategorized: Bool {
        themes == ["Uncategorized"]
    }

    //avoid UI being expanded by long texts
    var shortText: String {
        if extractedText.count > 100 {
            return String(extractedText.prefix(100)) + "..."
        }
        return extractedText
    }

}

