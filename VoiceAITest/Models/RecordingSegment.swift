//
//  RecordedSegementModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/25/24.
//

import SwiftData
import Foundation
import WhisperKit

@Model
class RecordingSegment {
    
    @Attribute(.unique) var id: UUID
    let segmentIndex: Int
    let startTime: Float
    let endTime: Float
    let textData: Data
    
    let recording: Recording
    
    init(recording: Recording, segment: TranscriptionSegment) {
        self.id = UUID()
        self.segmentIndex = segment.id
        self.startTime = segment.start
        self.endTime = segment.end
        self.textData = Data(segment.text.utf8)
        self.recording = recording
    }
}

extension RecordingSegment {
    
    var text: String? {
        return String(data: textData, encoding: .utf8)
    }
    
    var formattedTimestampText: String {
        return "[\(formatTimestamp(startTime)) --> \(formatTimestamp(endTime))] "
    }
    
    private func formatTimestamp(_ timestamp: Float) -> String {
        return String(format: "%.2f", timestamp)
    }
}
