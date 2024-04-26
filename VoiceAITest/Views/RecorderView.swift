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
    @StateObject private var whisperKitDownloadManager = WhisperKitDownloadManager.shared
    
    @Environment(\.modelContext) var modelContext
    //@Query(sort: \Recording.createdDate, order: .reverse) var recordings: [Recording]
        
    init(modelContainer: ModelContainer) {
        _viewModel = StateObject(wrappedValue: RecorderViewModel(modelContainer: modelContainer))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if WhisperKitDownloadManager.shared.downloadProgress < 1.0 {
                    VStack {
                        Text("AI Model Download Progress: \(String(format: "%.2f", whisperKitDownloadManager.downloadProgress * 100))%")
                            .italic()
                    }
                }
                List(viewModel.recordings) { recording in
                    RecordingView(recording: recording)
                    #if os(iOS)
                        .swipeActions {
                            deleteButton(forRecording: recording)
                        }
                    #else
                        .contextMenu {
                            deleteButton(forRecording: recording)
                        }
                    #endif
                }
                .navigationTitle("Voice Recorder")
                .overlay {
                    noRecordingsView
                }
                .safeAreaInset(edge: .bottom) {
                    recordButtonOverlay
                }
                .onAppear {
                    Task { @MainActor in
                        whisperKitDownloadManager.downloadModel(modelContext: modelContext)
                        Recording.transcribeRecordings(modelContext: modelContext)
                        Recording.analyzeRecordings(modelContext: modelContext)
                    }
                }
            }
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
        if viewModel.recordings.count == 0 {
            VStack {
                Image(systemName: "mic")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Record to get started")
            }
            .offset(y: -100)
        }
    }
    
    @ViewBuilder
    private func deleteButton(forRecording recording: Recording) -> some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            viewModel.deleteRecording(recording)
        }
    }
}
