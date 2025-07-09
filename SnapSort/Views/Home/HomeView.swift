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
    
    @EnvironmentObject var photoService: PhotoService
    @Query private var themeKeywords: [Theme]
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    
    @state private var processingProgress = 0.0
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(
                    spacing: 24
                ){
                    // Header Section
                    
                    // Permission Section
                    
                }
                .padding()
            }
            .navigationTitle("Screenshot Classifier")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .alert("Processing Complete", isPresented: $showingAlert) {
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
            Text("Sort your Screenshorts")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("use AI to categorize important screenshot information")
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
                    .foregroundStyle(.gray)
                
                Text("Photo Access Required to find and classify screenshots")
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
                    Text("Allow Photo Access")
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
            
        }
        .disabled(themeKeywords.isEmpty)
        
    }
    
}


