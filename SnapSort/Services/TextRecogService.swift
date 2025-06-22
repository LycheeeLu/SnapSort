//
//  TextRecognitionService.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import Foundation
import Vision
import UIKit

@MainActor
class TextRecogService: ObservableObject {
    
    @Published
    var isProcessing = false
    
    //UIImage is the class for processing image in iOS
    //CGImage is data structure in Core Graphics
    //OCR requires turning UIImage into CGImage
    func extractText(from image: UIImage) async -> String{
        guard let cgImage = image.cgImage else {
            print("Could not get CGImage from UIImage")
            print("Photo might be corrupted or in PDF/Vector formate")
            return ""
        }
        
        return await withCheckedContinuation{ continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error{
                    print("Text recognition error: \(error.localizedDescription)")
                    continuation.resume(returning: "")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print(" No text observations found" )
                    continuation.resume(returning: "")
                    return
                }
                
                let extractedText = observations.compactMap{observation in observation.topCandidates(1).first?.string}.joined(separator: " ")
                
                print("Extracted text length: \(extractedText.count)")
                continuation.resume(returning: extractedText)
                
            }
            
            //configure requests for better accuracy
            
        }
        

    }
    
    
}
