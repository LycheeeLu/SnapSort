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
    // this is function for single image OCR
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
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US", "zh-Hans" ,"ja-JP"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do{
                try handler.perform([request])
            } catch{
                print("Failed to perform text recognition:")
                print("error: \(error.localizedDescription)")
                continuation.resume(returning: "")
            }
        }
        

    }
    
    
    //Batch processing multiple images in chunks of 10
    // to avoid lag or overloading
    func extractTextFromImages(_ images: [UIImage]) async ->[String] {
        isProcessing = true
        
        //defer ensures isProcessing is reset when finished, even if early returns or errors happen.
        defer { isProcessing = false }
        
        
        var results: [String] = []
        let chunkSize = 10
        let total = images.count
        
        
        //stride() walk through the list 10 at a time
        for chunkStart in stride(from: 0, to: total, by: chunkSize){
            let chunk = Array(images[chunkStart..<min(chunkStart + chunkSize, total)])
            
            for image in chunk {
                let text = await extractText(from: image)
                results.append(text)
            }
        }
        
       
        
        return results
        
    }

        //Helper to clean and normalize extracted text
    func cleanText( _ text: String)-> String{
        return text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\s+", with:  " ", options:.regularExpression)
    }
    
    
}
