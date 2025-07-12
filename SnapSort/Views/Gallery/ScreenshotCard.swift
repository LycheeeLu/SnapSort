//
//  ScreenshotCard.swift
//  SnapSort
//
//  Created by Jie Lu on 24.6.2025.
//

import SwiftUI
import Photos
import _SwiftData_SwiftUI

struct ScreenshotCard: View{
    let screenshot: ClassifiedScreenShot
    @EnvironmentObject var photoService: PhotoService
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var showingDetail = true
    
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0){
            //Image Sectiomn
            imageSection
            
            //Content Section
            contentSection
            
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            showingDetail = true
        }
        .onAppear{
            loadImage()
        }
        .sheet(isPresented: $showingDetail){
            ScreenshotDetailView(screenshot: screenshot,
                                 image: image)
        }
        
    }
    
    // MARK: - Image Section
    private var imageSection: some View{
        ZStack{
            if let image = image{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
            } else if isLoading {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 160)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                    )
            } else {
                //loading failed or no photo
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                
                
            }
        }
        
    }
    
    
    // MARK: - func loadImage
    private func loadImage(){
        Task{
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [screenshot.assetIdentifier], options: nil)
         
            guard let asset = fetchResult.firstObject else {
                await MainActor.run{
                    self.isLoading = false
                }
                return
            }
            
            if let loadedImage = await photoService.loadImage(for: asset) {
                await MainActor.run{
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run{
                    self.isLoading = false
                }
            }
        }
    }
    
    
    // MARK: - Content Section
    private var contentSection: some View{
        VStack(alignment: .leading, spacing: 8){
            //Themes
            if screenshot.hasThemes && screenshot.themes != ["Uncategorized"] {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                    ForEach(screenshot.themes.prefix(4), id: \.self){
                        theme in ThemeChip(theme: theme)
                    }
                }
            } else {
                ThemeChip(theme: "Uncategorized", isUncategorized: true)
            }
            
            
            //extracted text preview
            if !screenshot.extractedText.isEmpty{
                Text(screenshot.extractedText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
            } else {
                Text ("No Text Detected")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(12)
        
    }
    
}



    // MARK: - Theme Chip
struct ThemeChip: View{
    let theme: String
    var isUncategorized: Bool = false
    @Query private var themeWords: [Theme]
    
    
    var themeColor: Color {
        if isUncategorized {
            return .gray
        }
        
        if let themeWord = themeWords.first(where: { $0.name == theme}){
            return themeWord.color.swiftUIColor
        }
        
        return .blue
    }
    
    var body: some View{
        Text(theme)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(themeColor)
                        )
    }
    
}



    // MARK: - Screenshot Detail View
struct ScreenshotDetailView: View{
    let screenshot: ClassifiedScreenShot
    let image: UIImage?
    // Get the dismiss function from SwiftUI's environment
    // for full-screen views — so user can close (dismiss) the current view when needed.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        NavigationView{
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    // Image dispay
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                        
                        }
                    //themes section
                    VStack(alignment: .leading, spacing: 12){
                        Text("Themes")
                            .font(.headline)
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 3),spacing: 8
                        ){
                            ForEach(screenshot.themes, id: \.self){
                                theme in ThemeChip(theme: theme)
                            }
                        
                        }
                   
                    }
                    
                    
                    //extracted text section
                    VStack(alignment: .leading, spacing: 12){
                        Text("Extracted text")
                            .font(.headline)
                        
                        if !screenshot.extractedText.isEmpty {
                            Text(screenshot.extractedText)
                                .font(.body)
                                .textSelection(.enabled)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                    
                        } else{
                            Text("Text Not Detected.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    //ensure empty space in the bottom
                    Spacer(minLength: 50)
                    
                    
                }
                .padding()
            }
            .navigationTitle("Screenshot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done"){
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ScreenshotCard_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack{
            ForEach(mockScreenshots, id: \.assetIdentifier){
                screenshot in
                ScreenshotCard(screenshot: screenshot)
                    .environmentObject(MockPhotoService())
                    .previewLayout(.sizeThatFits)
                    .padding()
            }
        }

    }

    static var mockScreenshots: [ClassifiedScreenShot] {
        return [
            ClassifiedScreenShot(
            assetIdentifier: "mock_1",
            extractedText: "This is a sample screenshot that mentions Swift, Git, and APIs.",
            themes: ["code", "work"],
            confidence: 0.85
        ),
            ClassifiedScreenShot(
                assetIdentifier: "mock_2",
                extractedText: "This is a sample screenshot that mentions japan, tokyo, and travel.",
                themes: ["travel"],
                confidence: 0.77
            )
        
        ]
    }

    class MockPhotoService: PhotoService {
        override func loadThumbnail(for asset: PHAsset) async -> UIImage? {
            // Return a placeholder image from system
            return UIImage(systemName: "photo")
        }
    }
}
#endif
