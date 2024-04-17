//
//  ContentView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import SwiftUI
import DSWaveformImageViews
import DSWaveformImage
import FloatingListItemSwiftUI
import Media

struct RecorderView: View {
    
    @StateObject private var viewModel = RecordingViewModel(recorder: AudioRecorder())
    @State var isRecording = false
    
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
                if isRecording {
                    VStack {
                        
                        WaveformLiveCanvas(
                            samples: viewModel.samples,
                            configuration: Waveform.Configuration(style: .striped(.init(color: .red, width: 3, spacing: 3)), verticalScalingFactor: 0.9),
                            renderer: LinearWaveformRenderer(),
                            shouldDrawSilencePadding: true
                        )
                        .maxWidth(.infinity)
                        .maxHeight(30)
                        .padding(.bottom, .extraLarge)
                        
                        recordingButtonView
                            .transition(recordButtonTransition.animation(recordButtonAnimation))
                    }
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
            isRecording = true
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
            isRecording = false
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
