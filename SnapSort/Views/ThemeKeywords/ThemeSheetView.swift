//
//  KeywordView.swift
//  SnapSort
//
//  Created by Jie Lu on 14.7.2025.
//

import SwiftUI
import SwiftData

// MARK: - Add Theme View
struct ThemeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // for editing mode
    let existingTheme: Theme?
    // decide whether to edit old themes or to add new themes
    private var isEditing: Bool {
            existingTheme != nil
        }
        
        private var navigationTitle: String {
            isEditing ? "Edit Theme" : "Add New Theme"
        }
    
    @State private var themeName: String = ""
    @State private var keywordsText: String = ""
    @State private var selectedColor: ThemeColor = .blue
    
    private let availableColors: [ThemeColor] = [.blue, .green, .orange, .pink]
    
    init(existingTheme: Theme? = nil) {
          self.existingTheme = existingTheme
      }
      
    
    var body: some View {
        NavigationStack {
            Form {
                themeDetailsSection
                keywordsSection
                colorSection
            }
            .navigationTitle(navigationTitle)
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
        }
    }
    
    private var themeNameTextEditor: some View {
        TextEditor(text: $themeName)
            .frame(minHeight: 44)
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
                    .foregroundColor(.secondary)
                
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
         if let theme = existingTheme {
             //load themes from database
             themeName = theme.name
             keywordsText = theme.keywords.joined(separator: " ")
             selectedColor = theme.color
         } else {
             // switch to add themes mode
             themeName = ""
             keywordsText = ""
             selectedColor = .blue
         }
     }
    
    private func saveTheme() {
        let trimmedName = themeName.trimmingCharacters(in: .whitespaces)
        let keywords = keywordsText
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        if let theme = existingTheme {
              // update themes
              theme.name = trimmedName
              theme.keywords = keywords
              theme.color = selectedColor
          } else {
              // add new themes
              let newTheme = Theme(
                  name: trimmedName,
                  keywords: keywords,
                  color: selectedColor
              )
              modelContext.insert(newTheme)
          }
        
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving theme: \(error)")
        }
    }
}


// MARK: - Preview
#Preview("Add Theme") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Theme.self, configurations: config)
    
    ThemeSheetView()
        .modelContainer(container)
}

#Preview("Edit Theme") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Theme.self, configurations: config)
    
    let sampleTheme = Theme(
        name: "Work",
        keywords: ["meeting", "email", "deadline", "project"],
        color: .blue
    )
    
    ThemeSheetView(existingTheme: sampleTheme)
        .modelContainer(container)
}
