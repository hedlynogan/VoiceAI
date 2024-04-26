//
//  TranscriptionManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/23/24.
//

import AVFAudio
import WhisperKit

class WKTranscriptionCreationManager {
    let recording: Recording
    let languageCode: String = "en"
    let task: DecodingTask = .transcribe
    
    static let whisperKitModeKey = "WHISPER_KIT_MODE"
    static let whisperKitMode = true
    
    // WhisperKit Transcription Decoder Settings
    private var temperatureStart: Float = 0
    private var fallbackCount: Double = 5
    private var sampleLength: Double = 224
    private var enablePromptPrefill: Bool = true
    private var enableCachePrefill: Bool = true
    private var enableSpecialCharacters: Bool = false
    private var enableTimestamps: Bool = true
    private var lastConfirmedSegmentEndSeconds: Float = 0
    
    private var currentFallbacks: Int = 0
    private var compressionCheckWindow: Double = 20
    private var currentDecodingLoops: Int = 0
    private var tokensPerSecond: TimeInterval = 0
    private var effectiveRealTimeFactor: TimeInterval = 0
    private var currentEncodingLoops: Int = 0
    private var firstTokenTime: TimeInterval = 0
    private var pipelineStart: TimeInterval = 0
    private var currentLag: TimeInterval = 0
    
    private var currentText = ""
    private var unconfirmedText: [String] = []
    private var confirmedSegments: [TranscriptionSegment] = []
    
    private var whisperKit: WhisperKit? {
        return WhisperKitDownloadManager.shared.whisperKit
    }
    
    init(recording: Recording) {
        self.recording = recording
    }
    
    func getTranscription() async
    {
        do {
            if let whisperKit = whisperKit,
               let audioURL = recording.urlToPlay {
                whisperKit.audioProcessor = AudioProcessor()
                try await transcribeCurrentFile(path: audioURL.path)
            }
        } catch {
            print(error)
        }
    }
    
    private func transcribeCurrentFile(path: String) async throws {
        let audioFileBuffer = try AudioProcessor.loadAudio(fromPath: path)
        let audioFileSamples = AudioProcessor.convertBufferToArray(buffer: audioFileBuffer)
        let transcription = try await transcribeAudioSamples(audioFileSamples)

        await MainActor.run {
            currentText = ""
            unconfirmedText = []
            guard let segments = transcription?.segments else {
                return
            }

            self.tokensPerSecond = transcription?.timings.tokensPerSecond ?? 0
            self.effectiveRealTimeFactor = transcription?.timings.realTimeFactor ?? 0
            self.currentEncodingLoops = Int(transcription?.timings.totalEncodingRuns ?? 0)
            self.firstTokenTime = transcription?.timings.firstTokenTime ?? 0
            self.pipelineStart = transcription?.timings.pipelineStart ?? 0
            self.currentLag = transcription?.timings.decodingLoop ?? 0

            self.confirmedSegments = segments
        }
        
        if let transcription = transcription {
            await recording.processWKTranscription(transcription)
        }
    }
    
    private func transcribeAudioSamples(_ samples: [Float]) async throws -> TranscriptionResult? {
        guard let whisperKit = whisperKit else { return nil }

        let seekClip = [lastConfirmedSegmentEndSeconds]
        let options = DecodingOptions(
            verbose: false,
            task: task,
            language: languageCode,
            temperature: temperatureStart,
            temperatureFallbackCount: Int(fallbackCount),
            sampleLength: Int(sampleLength),
            usePrefillPrompt: enablePromptPrefill,
            usePrefillCache: enableCachePrefill,
            skipSpecialTokens: !enableSpecialCharacters,
            withoutTimestamps: !enableTimestamps,
            clipTimestamps: seekClip
        )

        // Early stopping checks
        let decodingCallback: ((TranscriptionProgress) -> Bool?) = { progress in
            DispatchQueue.main.async {
                let fallbacks = Int(progress.timings.totalDecodingFallbacks)
                if progress.text.count < self.currentText.count {
                    if fallbacks == self.currentFallbacks {
                        self.unconfirmedText.append(self.currentText)
                    } else {
                        print("Fallback occured: \(fallbacks)")
                    }
                }
                self.currentText = progress.text
                self.currentFallbacks = fallbacks
                self.currentDecodingLoops += 1
            }
            // Check early stopping
            let currentTokens = progress.tokens
            let checkWindow = Int(self.compressionCheckWindow)
            if currentTokens.count > checkWindow {
                let checkTokens: [Int] = currentTokens.suffix(checkWindow)
                let compressionRatio = compressionRatio(of: checkTokens)
                if compressionRatio > options.compressionRatioThreshold! {
                    return false
                }
            }
            if progress.avgLogprob! < options.logProbThreshold! {
                return false
            }
            return nil
        }

        return try await whisperKit.transcribe(
            audioArray: samples,
            decodeOptions: options,
            callback: decodingCallback
        ).first
    }
}
