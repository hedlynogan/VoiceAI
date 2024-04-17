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
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
}
