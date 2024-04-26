//
//  OAITranscriptionCreationManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/26/24.
//

import AI
import Foundation

struct OAITranscriptionCreationManager {
    static let client: OpenAI.APIClient = OpenAI.APIClient(
        apiKey: "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"
    )
        
    private let client = OAITranscriptionCreationManager.client
    
    let recording: Recording
    
    
    func getTranscription() async {
        if let url = recording.urlToTranscribe {
            do {
                
                /* Read about prompts here: https://platform.openai.com/docs/guides/speech-to-text/prompting?lang=python */
                
//                let transcription = try await client.createTranscription(
//                    audioFile: url,
//                    prompt: nil
//                )
//                print(transcription)
                
            } catch {
                print(error)
            }
        }
    }
    
    
}

