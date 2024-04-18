//
//  RecordingObjectView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI

struct RecordedObjectView: View {
    
    let recording: RecordedObjectModel
    
    var body: some View {
        Text(recording.title)
    }
}
