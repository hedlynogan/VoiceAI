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
    
    @StateObject private var viewModel: RecorderViewModel
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \RecordedObjectModel.createdDate, order: .reverse) var recordings: [RecordedObjectModel]
        
    init(modelContainer: ModelContainer) {
        _viewModel = StateObject(wrappedValue: RecorderViewModel(modelContainer: modelContainer))
    }
    
    var body: some View {
        NavigationView {
            List(recordings) { recording in
                RecordedObjectView(recording: recording)
            }
            .navigationTitle("Voice Recorder")
            .overlay {
                noRecordingsView
            }
            .padding(.bottom, 100)
        }
        .overlay(alignment: .bottom) {
            recordButtonOverlay
        }
    }
    
    @ViewBuilder
    private var recordButtonOverlay: some View {
        VStack {
            if viewModel.isRecording {
                RecordingWaveView(recorder: viewModel.recorder)
                    .padding(.top, .large)
            }
            
            RecordButtonView(viewModel: viewModel)
        }
        .background(Material.ultraThinMaterial)
    }
    
    @ViewBuilder
    private var noRecordingsView: some View {
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
