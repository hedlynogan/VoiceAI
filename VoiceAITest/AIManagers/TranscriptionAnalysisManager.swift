//
//  TranscriptionParsingManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/25/24.
//

import OpenAI

struct TranscriptionAnalysisManager {
    // IMPORTANT: Store your keys securely via a Proxy
    static let client: OpenAI.APIClient = OpenAI.APIClient(
        apiKey: "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"
    )
    
    static let chatModel = OpenAI.Model.chat(.gpt_4_turbo)
    private static let tokenLimit = 4096
    
    static func getAnalysisForRecording(_ recording: Recording) async {
        let promptManager = RecordingAnalysisPromptManager()
        let sampleRecordingObject = promptManager.sampleRecordingObject
        
        if let transcription = recording.transcription {
            let messages: [AbstractLLM.ChatMessage] = [
                .system(promptManager.systemPrompt),
                .user {
                    .concatenate(separator: nil) {
                        sampleRecordingObject.recordingText
                    }
                },
                .functionCall(
                    of: promptManager.addRecordingAnalysisFunction,
                    arguments: sampleRecordingObject.expectedResult),
                .user {
                    .concatenate(separator: nil) {
                        PromptLiteral(transcription)
                    }
                }
            ]
            do {
                let completion = try await client.complete(
                    messages,
                    parameters: AbstractLLM.ChatCompletionParameters(
                        tokenLimit: .fixed(tokenLimit),
                        tools: [promptManager.addRecordingAnalysisFunction]
                    ),
                    model: chatModel
                )
                
                if let recordingAnalysis = try completion._allFunctionCalls.first?.decode(RecordingAnalysisPromptManager.AddRecordingResult.self).recordingAnalysis {
                    recording.processRecordingAnalysis(recordingAnalysis)
                }
                    
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
