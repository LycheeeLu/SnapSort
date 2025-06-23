//
//  ClassifyService.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//


import Foundation

class ClassificationService{
    
    //main classificaton method
    static func classifyText(_ text: String, with themes: [Theme]) -> [String]{
        //if a condition is false, immediately returen/throw/break/continue
        guard !text.isEmpty else { return ["Uncategorized"]}
        
        // what about chinese and japanese hmmmm
        let cleanText = text.lowercased()
        var matchedThemes: [String] = []
        var themeScores: [(String, Int)] = []
        
        //score theme on keyword matches
        for theme in themes {
            let score = calculateThemeScore(text: cleanText, theme: theme)
            if score > 0 {
                themeScores.append((theme.name, score))
            }
        }
        
        //sort by score and take top matches
        themeScores.sort{ $0.1 > $1.1}
        //max three themes per image
        matchedThemes = themeScores.prefix(3).map{ $0.0}
        
        return matchedThemes.isEmpty ? ["Uncategorized"] : matchedThemes
        
        
        
    }
    
    
    
    //calculating relevance score for a topic
    private static func calculateThemeScore( text: String, theme: Theme) -> Int{
        var score = 0
        
        for keyword in theme.keywords {
            //again what about chinese
            let keywordLower = keyword.lowercased()
            
            //assign different scores

            
            //higher score
            if text.contains("\(keywordLower)") ||
                text.hasPrefix("\(keywordLower)") ||
                text.hasSuffix("\(keywordLower)"){
                score += 3
            } else if text.contains(keywordLower){
                //partial match for lower score
                score += 1
            }
            
            // else no scores
            
        }
        
        return score
        
    }
    
    
    // get classification confidence (0 to 1.0)
    static func getConfidence(for text: String, themes: [String], allThemes: [Theme]) -> Double{
        
        guard !themes.isEmpty && themes != ["Uncategorized"] else {return 0.0}
        
        // again what about chinese
        let cleanText = text.lowercased()
        var totalScore = 0
        var maxPossibleScore = 0
        
        for themeName in themes {
            if let theme = allThemes.first(where: { $0.name == themeName}){
                totalScore += calculateThemeScore(text: cleanText, theme: theme)
                maxPossibleScore += theme.keywords.count * 3
                // max possible score per theme
            }
            
        }
        
        
        return maxPossibleScore > 0 ? min(Double(totalScore) / Double(maxPossibleScore), 1.0) : 0.0

        
    }
    
    
    
    //default topics for new users
    //will do more complex matching (like per-word tokenization or machine learning) later
    static func createDefaultThemes() -> [Theme]{
        return [
            Theme(
                name: "code",
                keywords: ["code", "programming", "swift", "python", "javascript", "git", "function", "class", "variable", "debug", "api", "database", "algorithm", "bug", "java", "repo", "project"],
                color: ThemeColor.blue
                
            ),
            
            Theme(
                name: "shopping",
                keywords: ["price", "buy", "cosmetics", "order", "shipping", "pay", "discount", "sale", "brand", "purchase", "makeup", "refund", "$", "yen", "coupon"],
                color: ThemeColor.pink
                
            ),
            
            Theme(
                name: "transport",
                keywords: ["flight", "hotel", "booking", "trip", "passport", "ticket", "tram", "airport", "boarding", "luggage", "bus", "line"],
                color:  ThemeColor.green
                
            ),
            
            Theme(
                name: "food",
                keywords: ["food", "takeout", "cook", "meal", "yummy", "restaurant", "sushi"],
                color: ThemeColor.orange
            )
            
            
            
        ]
        
    }
}

