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
    
    @StateObject private var viewModel: RecordingViewModel
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \RecordedObjectModel.createdDate, order: .reverse) var recordings: [RecordedObjectModel]
    
    @State var isRecording = false
    
    init(modelContainer: ModelContainer) {
        _viewModel = StateObject(wrappedValue: RecordingViewModel(modelContainer: modelContainer))
    }
    
    var body: some View {
        NavigationView {
            List(recordings) { recording in
                Text(recording.title)
            }
            .navigationTitle("Voice Recorder")
            .navigationBarTitleDisplayMode(.automatic)
            .overlay {
                if recordings.count == 0 {
                    VStack {
                        Image(systemName: "mic")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("Record to get started")
                    }
                    .offset(y: -100)
                }
            }
        }
        .overlay(alignment: .bottom) {
            VStack {
                if isRecording {
                    RecordingWaveView(recorder: viewModel.recorder)
                        .padding(.top, .large)
                }
                
                RecordButtonView(isRecording: $isRecording, viewModel: viewModel)
            }
            .background(Material.ultraThinMaterial)
        }
    }
}
