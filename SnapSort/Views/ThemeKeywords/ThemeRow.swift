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
        .sheet(isPresented: $isEditing, content: {EditThemeView(theme: theme)})
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

// MARK: - Edit Theme View
struct EditThemeView: View {
    @Bindable var theme: Theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var themeName: String = ""
    @State private var keywordsText: String = ""
    @State private var selectedColor: ThemeColor = .pink
    
    private let availableColors: [ThemeColor] = [.blue, .green, .orange, .pink]

    var body: some View {
        NavigationView {
            Form {
                themeDetailsSection
                keywordsSection
                colorSection
            }
            .navigationTitle("Edit this Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    // MARK: - View Components
    
    private var themeDetailsSection: some View {
        Section("Theme Details") {
            themeNameTextEditor
          //  TextField("Theme Name", text: $themeName)
              //  .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var themeNameTextEditor: some View{
        TextEditor(text: $themeName)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
    
    private var keywordsSection: some View {
        Section("Keywords") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter keywords separated by space")
                    .font(.caption)
                    .foregroundColor(.white)
                
                keywordsTextEditor
            }
        }
    }
    
    private var keywordsTextEditor: some View {
        TextEditor(text: $keywordsText)
            .frame(minHeight: 100)
            .scrollContentBackground(.hidden)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
    
    private var colorSection: some View {
        Section("Color") {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(availableColors, id: \.self) { colorName in
                    colorButton(for: colorName)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 4)
    }
    
    private func colorButton(for colorName: ThemeColor) -> some View {
        Button(action: {
            selectedColor = colorName
        }) {
            Circle()
                .fill(colorName.swiftUIColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedColor == colorName ? Color.purple : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            saveTheme()
        }
        .disabled(themeName.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    // MARK: - Methods
    
    private func setupInitialValues() {
        themeName = theme.name
        keywordsText = theme.keywords.joined(separator: " ")
        selectedColor = theme.color
    }
    
    private func saveTheme() {
            let trimmedName = themeName.trimmingCharacters(in: .whitespaces)
            let keywords = keywordsText
                .components(separatedBy: " ")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            theme.name = trimmedName
            theme.keywords = keywords
            theme.color = selectedColor
            
            try? modelContext.save()
            dismiss()
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
