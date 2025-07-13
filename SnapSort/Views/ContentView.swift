//
//  ContentView.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // fetch ModelContext from the environment to read/write SwfitData database
    @Environment(\.modelContext) private var modelContext
    
    //automatically search for and update instances of theme and ClassifiedScreenshot
    @Query private var theme: [Theme]
    @Query private var classifiedScreenshots: [ClassifiedScreenShot]
    
    //load services for processing photos and OCR
    // services lifetime: stay the same during contentView
    @StateObject private var photoService = PhotoService()
    @StateObject private var textService = TextRecogService()
    
    //record current selected Tab
    @State private var selectedTab = 0
    
    
    var body: some View {
        
        // a container (TabView with 3 tabs)
        TabView(selection: $selectedTab){
            //Home Tab
            HomeView()
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            
            GalleryView()
                .tabItem{
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                }
                .tag(1)
            
            
            ThemeListView()
                .tabItem{
                    Image(systemName: "tag.fill")
                    Text("Keywords")
                }
                .tag(2)
        }
        .environmentObject(photoService)
        .environmentObject(textService)
        .onAppear{
            setupDefaultThemes()
        }
        // inject photoService and textService into the envirotnment object
        // available at @EnvironmentObject
        
    }
    
    //for first initialization
    // if there is no default Themes in database
    private func setupDefaultThemes() {
        guard theme.isEmpty else  {return}
        
        let defaultThemes = ClassificationService.createDefaultThemes()
        for theme in defaultThemes {
            modelContext.insert(theme)
        }
        
        
        //saving context
        do {
            try modelContext.save()
            print("Default themes created successfully")
            
        } catch {
            print("Failed to save default themes")
            print("error: \(error)")
            
        }
        
        
        
    }
    
    
}
