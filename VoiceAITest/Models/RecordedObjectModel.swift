//
//  RecordedObjectModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftData
import Foundation

@Model
class RecordedObjectModel {
    
    @Attribute(.unique) var id: UUID
    var audioData: Data
    var createdDate: Date
    var title: String
    
    init(audioData: Data) {
        self.id = UUID()
        self.audioData = audioData
        self.createdDate = Date.now
        self.title = "New Recording"
    }
}

extension RecordedObjectModel {
    var urlFromData: URL? {
        do {
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to get the documents directory")
                return nil
            }
            
            #if os(iOS)
            let fileURL = directory.appendingPathComponent("\(id).mp3")
            #elseif os(macOS)
            let fileURL = directory.appendingPathComponent("\(id).ccp")
            #endif
            try audioData.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            print("Failed to write data: \(error)")
            return nil
        }
        
    }
}
