//
//  RecordedObjectModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftData
import Foundation
import WhisperKit
import SwiftUI

@Model
class Recording {
    
    @Attribute(.unique) var id: UUID
    let audioData: Data
    let createdDate: Date
    var title: String
    
    var isTranscribed: Bool = false
    var transcriptionData: Data?
    @Relationship(deleteRule: .cascade, inverse: \RecordingSegment.recording) var segments: [RecordingSegment]?
    
    var isAnalyzed: Bool = false
    var summary: String?
    @Relationship(deleteRule: .cascade, inverse: \RecordingKeyPoint.recording) var keyPoints: [RecordingKeyPoint]?

    
    init(audioData: Data) {
        self.id = UUID()
        self.audioData = audioData
        self.createdDate = Date.now
        self.title = "New Recording"
    }
}

extension Recording {
    
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
    
    var transcription: String? {
        if let transcriptionData = transcriptionData {
            return String(data: transcriptionData, encoding: .utf8)
        }
        
        return nil
    }
    
    func processTranscription(_ transcription: TranscriptionResult) async {
        transcriptionData = Data(transcription.text.utf8)
        isTranscribed = true
        transcription.segments.forEach {
            let recordingSegment = RecordingSegment(recording: self, segment: $0)
            modelContext?.insert(recordingSegment)
        }
        modelContext?.insert(self)
        do {
            try modelContext?.save()
            await TranscriptionAnalysisManager.getAnalysisForRecording(self)
        } catch {
            print(error)
        }
    }
    
    static func transcribeRecordings(modelContext: ModelContext) {
        let untranscribedRecordings = FetchDescriptor<Recording>(predicate: #Predicate { recording in
            recording.isTranscribed == false
        })
        do {
            try modelContext.enumerate(untranscribedRecordings) { recording in
                let transcriptionManager = TranscriptionCreationManager(recording: recording)
                Task(priority: .userInitiated) {
                    await transcriptionManager.getTranscription()
                    await TranscriptionAnalysisManager.getAnalysisForRecording(recording)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func processRecordingAnalysis(_ recordingAnalysis: RecordingAnalysisPromptManager.AddRecordingResult.RecordingAnalysis) {
        
        isAnalyzed = true
        title = recordingAnalysis.title
        summary = recordingAnalysis.summary
        
        recordingAnalysis.keypoints.forEach {
            let keyPoint = RecordingKeyPoint(recording: self, keyPoint: $0)
            modelContext?.insert(keyPoint)
        }
        
        modelContext?.insert(self)
        do {
            try modelContext?.save()
        } catch {
            print(error)
        }
    }
    
    static func analyzeRecordings(modelContext: ModelContext) {
        let unanlyzedRecordings = FetchDescriptor<Recording>(predicate: #Predicate { recording in
            recording.isAnalyzed == false
        })
        do {
            try modelContext.enumerate(unanlyzedRecordings) { recording in
                Task(priority: .userInitiated) {
                    await TranscriptionAnalysisManager.getAnalysisForRecording( recording)
                }
            }
        } catch {
            print(error)
        }
    }
}
