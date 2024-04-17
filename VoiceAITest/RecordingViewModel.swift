//
//  RecordingViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import AVFAudio
import Media
import SwiftUI
import WhisperKit

class RecordingViewModel: ObservableObject {
    
    private let recorder = AudioRecorder()
    
    @Published var isRecording = false
    
    func startRecording() async {
        do {
            isRecording = true
            try await recorder.prepare()
            try await recorder.record()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() async {
        do {
            isRecording = false
            try await recorder.stop()
            //transcribeRecording()
        } catch {
            print(error)
        }
    }
    
    private func transcribeRecording() {
        do {
            if let recordingData = try recorder.recording?.data() {
                let file = try URL.temporaryFile(name: "\(UUID().uuidString).mpg", data: recordingData)
                Task {
                    let pipe = try? await WhisperKit()
                    let transcription = try? await pipe!.transcribe(audioPath: file.path())?.text
                    print(transcription!)
                }
            }
            
        } catch {
            print(error)
        }
    }
}
