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
            
            
            KeywordsView()
                .tabItem{
                    Image(systemName: "tag.fill")
                    Text("Keywords")
                }
                .tag(2)
        }
        
        
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
