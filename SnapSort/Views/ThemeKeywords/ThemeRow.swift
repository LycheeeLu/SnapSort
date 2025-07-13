//
//  ThemeRow.swift
//  SnapSort
//
//  Created by Jie Lu on 24.6.2025.
//

import SwiftUI
import SwiftData

struct ThemeRow: View{
    @Bindable var theme: Theme
    let onDelete: () -> Void
    
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @Query private var classifiedScreenshots: [ClassifiedScreenShot]
    
    
    var screenshotCount: Int {
        classifiedScreenshots.filter {
            screenshot in screenshot.themes.contains(theme.name)
        }.count
    }
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            // Header Section
            HStack{
                // Color Circle
                Circle()
                    .fill(theme.color.swiftUIColor)
                    .frame(width: 16, height: 16)
                
                // Theme Name
                Text(theme.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                //Screenshot count Badge
                if screenshotCount > 0 {
                    Text("\(screenshotCount) snaps")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(theme.color.swiftUIColor.opacity(0.8))
                        )
                    
                }
                
                //Menu Button
                Menu {
                    Button(action: {
                        isEditing = true
                    }){
                        Label("Edit", systemImage:"pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action:{
                        showingDeleteConfirmation = true
                    }){
                        Label("Delete", systemImage: "trash")
                        
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                
            }
            
            // keywords section
            if !theme.keywords.isEmpty{
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                          alignment: .leading,
                          spacing: 6){
                    ForEach(theme.keywords.prefix(12), id: \.self) {
                        keyword in KeywordChip(keyword: keyword, color: theme.color.swiftUIColor)
                    }
                    
                    if theme.keywords.count > 12 {
                        Text("+ \(theme.keywords.count - 12) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray))
                            )
                    }
                    
                }
            } else {
                Text("No Keywords yet")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .italic()
            }
            
            
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $isEditing, content: {ThemeSheetView(existingTheme: theme)})
        .confirmationDialog(
            "Delete ' \(theme.name)'?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible){
                Button("Delete", role: .destructive){
                    onDelete()
                }
                Button("Cancel", role: .cancel){ }
            } message:{
                Text("This action cannot be undone.")
                Text("Screenshots will be reclassfified.")
            }
    }
    
}


// MARK: - Keyword chip
struct KeywordChip: View{
    let keyword: String
    let color: Color
    
    var body: some View{
        Text(keyword)
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.8))
            )
            .lineLimit(1)
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Theme.self, configurations: config)
    
    let sampleTheme = Theme(
        name: "Work",
        keywords: ["meeting", "email", "deadline", "project", "task", "schedule"],
        color: ThemeColor(rawValue: "blue") ?? .pink
    )
    
    ThemeRow(theme: sampleTheme, onDelete: {})
        .modelContainer(container)
        .padding()
}
