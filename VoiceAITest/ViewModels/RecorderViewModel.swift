//
//  RecordingViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import Media
import SwiftUI
import SwiftData

class RecorderViewModel: ObservableObject {
    
    let recorder = AudioRecorder()
    private let modelContainer: ModelContainer
    
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var recordings: [Recording]
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let modelContext = ModelContext(modelContainer)
        self.recordings = Recording.getRecordings(modelContext: modelContext)
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
            await processRecording()
        } catch {
            print(error)
        }
    }
    
    private func processRecording() async {
        do {
            if let recordingData = try recorder.recording?.data() {
                
                let recording = Recording(audioData: recordingData)
                let modelContext = ModelContext(modelContainer)
                modelContext.insert(recording)
                try modelContext.save()
                
                await MainActor.run {
                    self.recordings = Recording.getRecordings(modelContext: modelContext)
                }
                
                Task(priority: .userInitiated) {
                    let transcriptionManager = TranscriptionCreationManager(recording: recording)
                    await transcriptionManager.getTranscription()
                    await MainActor.run {
                        self.recordings = Recording.getRecordings(modelContext: modelContext)
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }
}
