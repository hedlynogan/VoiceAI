//
//  ContentView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import SwiftUI
import DSWaveformImageViews
import FloatingListItemSwiftUI

struct RecorderView: View {
    
    @StateObject private var viewModel = RecordingViewModel()
    
    private let recordButtonAnimation = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.5)
    private let recordButtonTransition = AnyTransition.opacity.combined(with: .scale(scale: 0.95))

    
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
                if viewModel.isRecording {
                    recordingButtonView
                        .transition(recordButtonTransition.animation(recordButtonAnimation))
                } else {
                    recordButtonView
                        .transition(recordButtonTransition.animation(recordButtonAnimation))
                }

            }
        }
    }
    
    @ViewBuilder 
    private var recordButtonView: some View {
        Button (action: {
            Task { @MainActor in
                await viewModel.startRecording()
            }
        }) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 5)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 10)
                
                Circle()
                    .fill(.red.opacity(0.8))
                    .frame(width: 50, height: 50)
            }
        }
        .frame(width: 70, height: 80)
    }
    
    @ViewBuilder
    private var recordingButtonView: some View {
        Button (action: {
            Task { @MainActor in
                await viewModel.stopRecording()
            }
        }) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 5)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 10)
                
                Rectangle()
                    .fill(.red.opacity(0.8))
                    .frame(width: 38, height: 38)
            }
        }
        .frame(width: 70, height: 80)
    }
}
