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
    
    private(set) var recorder = AudioRecorder()
        
    func startRecording() async {
        do {
            await self.prepareRecording()
            try await recorder.record()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() async {
        do {
            try await recorder.stop()
            //transcribeRecording()
            recorder = AudioRecorder()
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
    
    private func prepareRecording() async {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try await recorder.prepare()
        } catch {
            print(error)
        }
    }
}
