//
//  RecordingViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import AVFAudio
import Media
import SwiftUI
import SwiftData

class RecorderViewModel: ObservableObject {
    
    @Published private(set) var recorder = AudioRecorder()
    private let modelContainer: ModelContainer
    
    @Published private(set) var isRecording: Bool = false
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    func startRecording() async {
        do {
            try await recorder.prepare()
            try await recorder.record()
            isRecording = true
        } catch {
            print(error)
        }
    }
    
   @MainActor
    func stopRecording() async {
        do {
            try await recorder.stop()
            isRecording = false
            processRecording()
        } catch {
            print(error)
        }
    }
    
    private func processRecording() {
        do {
            if let recordingData = try recorder.recording?.data() {
                
                let permanentURL = try saveFilePermanently(data: recordingData, with: "\(UUID().uuidString).m4a")
                let recordedObjectModel = RecordedObjectModel(fileURL: permanentURL)
                let modelContext = ModelContext(modelContainer)
                modelContext.insert(recordedObjectModel)
                try modelContext.save()
            }
            
        } catch {
            print(error)
        }
    }
    
    private func saveFilePermanently(data: Data, with fileName: String) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Write the data to the file
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}
