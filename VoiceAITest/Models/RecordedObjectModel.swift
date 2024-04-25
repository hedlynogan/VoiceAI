//
//  RecordedObjectModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftData
import Foundation
import WhisperKit

@Model
class RecordedObjectModel {
    
    @Attribute(.unique) var id: UUID
    let audioData: Data
    let createdDate: Date
    var title: String
    
    var transcribed: Bool = false
    var fullTextData: Data?
    
    @Relationship(deleteRule: .cascade, inverse: \RecordedSegmentModel.recording) var segments: [RecordedSegmentModel]?
    
    
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
    
    var fullText: String? {
        if let fullTextData = fullTextData {
            return String(data: fullTextData, encoding: .utf8)
        }
        
        return nil
    }
    
    func processTranscription(_ transcription: TranscriptionResult) {
        fullTextData = Data(transcription.text.utf8)
        transcribed = true
        transcription.segments.forEach {
            let segmentModel = RecordedSegmentModel(recording: self, segment: $0)
            modelContext?.insert(segmentModel)
        }
        modelContext?.insert(self)
        do {
            try modelContext?.save()
        } catch {
            print(error)
        }
    }
    
    // TODO: query all models that have not been transcribed and transcribe them
    // TODO: query all models that haven't had analysis done, and do it
}
