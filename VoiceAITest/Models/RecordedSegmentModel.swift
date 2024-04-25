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
class RecordedSegmentModel {
    
    @Attribute(.unique) var id: UUID
    let segmentIndex: Int
    let startTime: Float
    let endTime: Float
    let text: String
    
    let recording: RecordedObjectModel
    
    init(recording: RecordedObjectModel, segment: TranscriptionSegment) {
        self.id = UUID()
        self.segmentIndex = segment.id
        self.startTime = segment.start
        self.endTime = segment.end
        self.text = segment.text
        self.recording = recording
    }
}

extension RecordedSegmentModel {
    
    var formattedTimestampText: String {
        return "[\(formatTimestamp(startTime)) --> \(formatTimestamp(endTime))] "
    }
    
    private func formatTimestamp(_ timestamp: Float) -> String {
        return String(format: "%.2f", timestamp)
    }
}
