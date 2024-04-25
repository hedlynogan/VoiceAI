//
//  TranscriptionManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/23/24.
//

import AI
import AVFAudio

struct TranscriptionManager {
    // IMPORTANT: Store your keys securely via a Proxy
    private static let client: OpenAI.APIClient = OpenAI.APIClient(
        apiKey: "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"
    )
    
    static func getTranscription(fromRecording recording: RecordedObjectModel) async {
//        do {
//            
//            
//            
//            let transcription = try await client.createTranscription(file: recording.audioData, prompt: nil)
//            print(transcription)
//            
//        } catch {
//            print(error)
//        }
    }
}
