//
//  HomeView.swift
//  SnapSort
//
//  Created by Jie Lu on 24.6.2025.
//

import SwiftUI
import SwiftData
import Photos

struct HomeView: View{
    @Binding var selectedTab: Int
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var textService: TextRecogService
    
    // for testing, use State
    //@State private var themeWords: [Theme] = []
    @Query private var themeWords: [Theme] = []
    @Query private var classifiedScreenshots: [ClassifiedScreenShot]
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var isProcessing = false
    @State private var processingProgress = 0.0
    @State private var currentProcessingIndex = 0
    @State private var totalScreenshots = 0
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(
                    spacing: 24
                ){
                    // Header Section
                    headerSection
                    
                    // Permission Section
                    if photoService.authorizationStatus != .authorized {
                        permissionSection
                    } else {
                        //Stats Section
                        
                        quickActionsSection
                        
                        processingSection
                    }
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("SnapSort")
            //for testing only
            /*.onAppear {
                if themeWords.isEmpty {
                    themeWords = ClassificationService.createDefaultThemes()
                }
            }*/
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .alert("Process info", isPresented: $showingAlert) {
                Button("OK"){ }
                } message: {
                    Text(alertMessage)
                }
            }
            
        }
        
        // MARK: - Header section
        // fileprivate for preview
    fileprivate var headerSection: some View{
        VStack(spacing: 12){
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text("sort your snaps album")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("with themes you care 💗")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    // MARK: - Permission Section
    fileprivate var permissionSection: some View{
        VStack(spacing: 20){
            VStack(spacing: 16){
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundStyle(.cyan)
                
                Text("Photo Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
            }
            
            Button( action: {
                photoService.requestPermission()
            }){
                HStack{
                    Image(systemName: "lock.open.fill")
                    Text("Allow")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Processing Section
    fileprivate var processingSection: some View{
        VStack(spacing: 20){
            if isProcessing {
                processingView
            } else {
                processButton
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        
    }
    
    
    fileprivate var processingView: some View{
        VStack(spacing: 16){
            HStack{
                ProgressView()
                    .scaleEffect(0.8)
                
                //indeterminate progress view animation
                //notify the user content is loading
                
                Text("Processing Screenshots...")
                    .font(.headline)
                
                Spacer()
            }
            
            ProgressView(value: processingProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("\(currentProcessingIndex) of \(totalScreenshots)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(processingProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            
        }
        
    }
    
    private var processButton: some View{
        Button(action: {
            Task{
                await processScreenshots()
            }
        }){
            HStack{
                Image(systemName: "wand.and.rays")
                Text("Classify screenshots")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View{
        VStack(alignment: .leading, spacing: 12){
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count:2),
                spacing: 12
            ){
                QuickActionCard(
                    title: "View Gallery",
                    icon: "photo.on.rectangle.angled",
                    color: .blue
                    
                ){
                    // Switch to gallery tab
                    print("Gallery card tapped")
                    selectedTab = 1
                }
                
                
                QuickActionCard(
                    title: "Edit Topics",
                    icon: "tag.fill",
                    color: .indigo
                ){
                    // Switch to keywords tab
                    print("Edit Topics Card tapped")
                    selectedTab = 2
                }
                
                QuickActionCard(
                    title: "Export data",
                    icon: "square.and.arrow.up",
                    color: .purple
                ){
                    // export functionality
                }
                
                
                //might neeed more quick actions
            }
            
        }
    }
    
    // MARK: - Quick Action Card
    struct QuickActionCard: View{
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View{
            Button(action: action){
                VStack(){
                    Image(systemName: icon)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    
    // MARK: - FUNCTIONS
    private func processScreenshots() async {
        guard !themeWords.isEmpty else {
            alertMessage = "Uh-oh, Please add topics first"
            showingAlert = true
            return
        }
        isProcessing = true
        processingProgress = 0.0
        
        let screenshots = photoService.fetchScreenshots()
        totalScreenshots = screenshots.count
        currentProcessingIndex = 0
        
        guard !screenshots.isEmpty else{
            alertMessage = "No screenshots found in the photo library"
            showingAlert = true
            isProcessing = false
            return
        }
        
        var processedCount = 0
        var newClassfications = 0
        
        for(_, asset) in screenshots.enumerated(){
            //Check if already processed
            // using trailing closure to spot the first instance
            // of screenshot that has been classified
            let existingScreenshot = classifiedScreenshots.first{
                $0.assetIdentifier == asset.localIdentifier
            }
            
            if existingScreenshot == nil{
                await processScreenshot(asset)
                newClassfications += 1
            }
            
            processedCount += 1
            currentProcessingIndex = processedCount
            processingProgress = Double(processedCount) / Double(totalScreenshots)
            
        }
        isProcessing = false
        alertMessage = "\(newClassfications) new screenshots classified."
        showingAlert = true
 
    }
    
    private func processScreenshot(_ asset: PHAsset) async{
        guard let image = await photoService.loadImage(for: asset) else {
            print("failed to load image for asset: \(asset.localIdentifier)")
            return
        }
        
        let extractedText = await textService.extractText(from: image)
        let themes = ClassificationService.classifyText(extractedText, with: Array(themeWords))
        let condifence = ClassificationService.getConfidence(for: extractedText, themes: themes, allThemes: Array(themeWords))
        
        let screenshot = ClassifiedScreenShot(
            assetIdentifier: asset.localIdentifier, extractedText: extractedText, themes: themes, confidence: condifence)
        
        modelContext.insert(screenshot)
        
        //save periodically to avoid memory issues
        // use ? so that if fails, the code doesnt crash
        if classifiedScreenshots.count % 10 == 0 {
            try? modelContext.save()
        }
        
    }
    
    
    private func refreshData() async {
        photoService.objectWillChange.send()
        //change the UI when data changed
    }
    
}



class MockPhotoService: PhotoService {
    override init() {
        super.init()
        self.authorizationStatus = .authorized
    }

    override func requestPermission() {
        print("🔵 Mock: Pretending permission is granted.")
        self.authorizationStatus = .authorized
    }
}

#Preview("HomeView") {
    @Previewable @State var selectedTab = 0
    
    let mockService = MockPhotoService() as PhotoService
    
    return TabView(selection: $selectedTab) {
        HomeView(selectedTab: $selectedTab)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
        
        Text("Gallery View")
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Gallery")
            }
            .tag(1)
        
        Text("Keywords View")
            .tabItem {
                Image(systemName: "tag.fill")
                Text("Keywords")
            }
            .tag(2)
    }
    .environmentObject(mockService)
    .environmentObject(TextRecogService())
}
