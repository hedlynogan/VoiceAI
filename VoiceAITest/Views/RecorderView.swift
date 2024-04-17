//
//  ContentView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import SwiftUI
import Media
import SwiftData

struct RecorderView: View {
    
    private var viewModel: RecordingViewModel
    
    @Environment(\.modelContext) var modelContext
    @Query var recordings: [RecordedObjectModel]
    
    @State var isRecording = false
    
    init(modelContainer: ModelContainer) {
        self.viewModel = RecordingViewModel(modelContainer: modelContainer)
    }
    
    var body: some View {
        NavigationView {
            List(recordings) { recording in
                Text(recording.fileURL.absoluteString)
            }
            .navigationTitle("Voice Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if recordings.count == 0 {
                    VStack {
                        Image(systemName: "mic")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("Record to get started")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    if isRecording {
                        RecordingWaveView(recorder: viewModel.recorder)
                            .padding(.bottom, .extraLarge)
                    }
                    
                    RecordButtonView(isRecording: $isRecording, viewModel: viewModel)
                }
            }
        }
    }
}
