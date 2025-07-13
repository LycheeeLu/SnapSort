//
//  ThemeListView.swift
//  SnapSort
//
//  Created by Jie Lu on 13.7.2025.
//



import SwiftUI
import SwiftData

struct ThemeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var themes: [Theme]
    
    @State private var showingAddTheme = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(themes) { theme in
                        ThemeRow(theme: theme) {
                            deleteTheme(theme)
                        }
                    }
                    
                    // Empty state
                    if themes.isEmpty {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddTheme) {
                ThemeSheetView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var addButton: some View {
        Button(action: {
            showingAddTheme = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Themes Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Create your first theme \n to organize your snaps")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddTheme = true
            }) {
                Text("Add Theme")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple)
                    )
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Methods
    
    private func deleteTheme(_ theme: Theme) {
        withAnimation {
            modelContext.delete(theme)
            try? modelContext.save()
        }
    }
}



// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Theme.self, configurations: config)
    
    // Add sample themes for preview
    let sampleThemes = [
        Theme(name: "Work", keywords: ["meeting", "email", "deadline", "project"], color: .blue),
        Theme(name: "Personal", keywords: ["family", "vacation", "hobby"], color: .green),
        Theme(name: "Learning", keywords: ["tutorial", "course", "study"], color: .orange)
    ]
    
    sampleThemes.forEach { container.mainContext.insert($0) }
    
    return ThemeListView()
        .modelContainer(container)
}
