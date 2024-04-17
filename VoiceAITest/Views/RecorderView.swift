//
//  ContentView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import SwiftUI
import Media

struct RecorderView: View {
    
    private var viewModel = RecordingViewModel()
    
    @State var isRecording = false
    
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Voice Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                // if no recordings
                VStack {
                    Image(systemName: "mic")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Record to get started")
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
