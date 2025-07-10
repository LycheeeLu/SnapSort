//
//  PhotoService.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import Foundation
import Photos
import UIKit

@MainActor //ensure UI-related updates on the main
class PhotoService: ObservableObject{
    //ObservableObject: bind this service to SwiftUI views
    // when the class conforms to ObservableObject, it can be subscribed to
    // and ObserbableObject updates SwiftUI’s view when data changes.
    
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    //@Published lets UI react to changes (permissions give or loading starts) in state
    
    
    //checks for current photo permission status on launch
    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    //ask the user for library access and hide/show screenshots if denied
    func requestPermission(){
        print("🔵 Asking for permission...")
        PHPhotoLibrary.requestAuthorization(for: .readWrite){ status in
            DispatchQueue.main.async {
                print("🟢 Permission result: \(status.rawValue)")
                self.authorizationStatus = status
            }
            
        }
    }
    
    //Load PHAsset objects for snaps from photo library
    func fetchScreenshots(limit: Int = 0) -> [PHAsset] {
        guard authorizationStatus == .authorized else {
            print("Photo access not authorized ")
            return []
        }
        
        let fetchOptions = PHFetchOptions()
        // filter only screenshots
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype & %d != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        //sort them by creation date, newest first
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if limit > 0 {
            fetchOptions.fetchLimit = limit
        }
        
        // result = all snaps
        let result = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []
        // go through every item in result
        result.enumerateObjects{asset, _, _ in
            assets.append(asset)}
        
        print(" Found \(assets.count) screenshots")
        
        //return lightweight handles to actual images in the library.
        return assets
    }
    
    
    // loads full-resolution or scaled image from the asset asynchronoously
    // using async funciton to avoid stuck in main thread
    func loadImage(for asset: PHAsset, targetSize: CGSize = CGSize(width: 1000, height: 1000)) async -> UIImage? {
        
        
        // withCheckedContinuation starts, and Swift suspends the loadImage function right there
        // Swift givse a continuaiton token
        return await withCheckedContinuation{continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            //PHImageManager.default().requestImage(...) is async API/requests to load image from disk or iCloud
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options){ image, info in
                continuation.resume(returning: image)
                // return the image to the code awaiting for it
            }
        }
        
    }
    // useful for gallery thumbnail
    func loadThumbnail(for asset: PHAsset) async -> UIImage? {
        return await loadImage(for: asset, targetSize: CGSize(width: 200, height: 200))
        
    }
    
    
    // useful for showing blank state or onboarding message
    func hasScreenshots() -> Bool {
        return !fetchScreenshots(limit: 1).isEmpty
    }
    
}
