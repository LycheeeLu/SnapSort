//
//  GalleryView.swift
//  SnapSort
//
//  Created by Jie Lu on 24.6.2025.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query private var classifiedScreenshots: [ClassifiedScreenShot]
    @State private var selectedTheme: String?
  
    var availableThemes: [String] {
        let allThemes = classifiedScreenshots.flatMap{ $0.themes}
        return Array(Set(allThemes)).sorted()
    }
    
    
    //creating grouped dictionary
    /*[
      "code": [Screenshot1, Screenshot4, ...],
      "work": [Screenshot2, Screenshot5, ...],
      "life": [Screenshot3, ...]
    ]*/

    var groupedScreenshots: [String: [ClassifiedScreenShot]]{
        Dictionary(grouping: classifiedScreenshots, by: {$0.themes.first ?? "other"})
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                // theme chips
                
                ScrollView(.horizontal, showsIndicators: true){
                    HStack(spacing: 8){
                        Button(action: { selectedTheme = nil }) {
                            Text("All")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTheme == nil ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedTheme == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        
                        ForEach(availableThemes, id: \.self){
                            theme in Button(action: {selectedTheme = theme}){
                                Text(theme.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.blue )
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 24){
                        ForEach(availableThemes, id: \.self){
                            theme in if selectedTheme == nil || selectedTheme == theme{
                                VStack(alignment: .leading){
                                    Text(theme.capitalized)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    
                                    ScrollView(.horizontal, showsIndicators:true){
                                        HStack(spacing: 4) {
                                            ForEach(groupedScreenshots [theme] ?? [], id: \.id){
                                                screenshot in ScreenshotCard(screenshot: screenshot)
                                                    .frame(width: 120)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
        
                        }
                        
                    }
                }
                .padding(.top)
               
            }
            .navigationTitle("Gallery")
            
            
        }
        }
  
}


// MARK: - Preview with Mock Data

#if DEBUG
import SwiftUI
import PhotosUI

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .environment(\.modelContext, MockModelContext(with: mockScreenshots))
            .previewDisplayName("GalleryView Preview")
    }

    static var mockScreenshots: [ClassifiedScreenShot] {
        [
            ClassifiedScreenShot(
                assetIdentifier: "mock_1",
                extractedText: "This is a sample screenshot that mentions Swift, Git, and APIs.",
                themes: ["code"],
                confidence: 0.85
            ),
            ClassifiedScreenShot(
                assetIdentifier: "mock_2",
                extractedText: "This is a sample screenshot that mentions japan, tokyo, and travel.",
                themes: ["travel"],
                confidence: 0.77
            ),
            ClassifiedScreenShot(
            assetIdentifier: "mock_3",
            extractedText: "This is a sample screenshot that mentions food food food.",
            themes: ["food"],
            confidence: 0.85
            )
        ]
    }
    
    static func MockModelContext(with screenshots: [ClassifiedScreenShot]) -> ModelContext {
            let container = try! ModelContainer(for: ClassifiedScreenShot.self)
            let context = ModelContext(container)
            for screenshot in screenshots {
                context.insert(screenshot)
            }
            return context
        }
}

#endif
