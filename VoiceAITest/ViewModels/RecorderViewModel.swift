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
    private let modelContext: ModelContext
    private let whisperKitMode = UserDefaults.standard.bool(forKey: WKTranscriptionCreationManager.whisperKitModeKey)
    
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var recordings: [Recording]
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
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
    
    func deleteRecording(_ recording: Recording) {
        modelContext.delete(recording)
        self.recordings.removeFirst(of: recording)
    }
    
    private func processRecording() async {
        do {
            if let recordingData = try recorder.recording?.data() {
                
                let recording = Recording(audioData: recordingData)
                modelContext.insert(recording)
                try modelContext.save()
                
                await MainActor.run {
                    self.recordings = Recording.getRecordings(modelContext: modelContext)
                }
                
                if whisperKitMode {
                    //using on-device WhisperKit
                    Task(priority: .userInitiated) {
                        let transcriptionManager = WKTranscriptionCreationManager(recording: recording)
                        await transcriptionManager.getTranscription()
                        await MainActor.run {
                            self.recordings = Recording.getRecordings(modelContext: modelContext)
                        }
                    }
                } else {
                    //using the OpenAI Whisper API
                    Task(priority: .userInitiated) {
                        let transcriptionManager = OAITranscriptionCreationManager(recording: recording)
                        await transcriptionManager.getTranscription()
                        await MainActor.run {
                            self.recordings = Recording.getRecordings(modelContext: modelContext)
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }
}
