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
import Combine

class RecordingViewModel: ObservableObject {
    
    private let recorder: AudioRecorder
    
    private var cancellables = Set<AnyCancellable>()
    
    private var timer: Timer?
    @Published var samples: [Float] = []
    
    init(recorder: AudioRecorder) {
        self.recorder = recorder
        observeRecorderState()
    }
    
    private func observeRecorderState() {
        recorder.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                self?.handleStateChange(newState)
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange(_ newState: AudioRecorder.State) {
        switch newState {
        case .recording:
            startTimer()
        default:
            stopTimer()
        }
    }
    
    private func startTimer() {
        // Start or reset the timer to update the samples
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let power = 1 - self.recorder.normalizedPowerLevel
            self.samples.append(contentsOf: [power,power,power])
            print(self.samples)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startRecording() async {
        do {
            try await recorder.prepare()
            try await recorder.record()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() async {
        do {
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
