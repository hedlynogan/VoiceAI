//
//  TranscriptionParsingManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/25/24.
//

import OpenAI

struct TranscriptionParsingManager {
    // IMPORTANT: Store your keys securely via a Proxy
    static let client: OpenAI.APIClient = OpenAI.APIClient(
        apiKey: "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"
    )
    
    static let chatModel = OpenAI.Model.chat(.gpt_4_turbo)
    private static let tokenLimit = 1000
    
    static func getAnalysisForRecording(recording: RecordedObjectModel) async -> RecordingAnalysisPromptManager.AddRecordingResult.RecordingAnalysis? {
        let promptManager = RecordingAnalysisPromptManager()
        let sampleRecordingObject = promptManager.sampleRecordingObject
        
        if let fullTextData = recording.fullTextData {
            do {
                let transcription = try String(data: fullTextData)
                
                let messages: [AbstractLLM.ChatMessage] = [
                    .system(promptManager.systemPrompt),
                    .user(sampleRecordingObject.recordingText),
                    .functionCall(
                        of: promptManager.addRecordingAnalysisFunction,
                        arguments: sampleRecordingObject.expectedResult),
                    .user(PromptLiteral(transcription))
                ]
                
                
                let completion = try await client.complete(
                    messages,
                    parameters: AbstractLLM.ChatCompletionParameters(
                        tokenLimit: .fixed(tokenLimit),
                        tools: [promptManager.addRecordingAnalysisFunction]
                    )
                )
                
                return try completion._allFunctionCalls.first?.decode(RecordingAnalysisPromptManager.AddRecordingResult.self).recordingAnalysis
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
