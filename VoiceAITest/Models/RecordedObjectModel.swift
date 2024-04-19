//
//  RecordedObjectModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftData
import Foundation

@Model
class RecordedObjectModel {
    
    @Attribute(.unique) var id: UUID
    var audioData: Data
    var createdDate: Date
    var title: String
    
    init(audioData: Data) {
        self.id = UUID()
        self.audioData = audioData
        self.createdDate = Date.now
        self.title = "New Recording - \(RecordedObjectHelper.formattedDate)"
    }
}

private struct RecordedObjectHelper {
    static var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: Date.now)
    }
}
