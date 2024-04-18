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
    
    @Attribute(.unique) var fileURL: URL
    var createdDate: Date
    var title: String
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.createdDate = Date.now
        self.title = "New Recording - \(RecordedObjectHelper.formattedDate)"
    }
}

struct RecordedObjectHelper {
    static var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: Date.now)
    }
}
