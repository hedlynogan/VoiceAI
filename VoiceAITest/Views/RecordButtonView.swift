//
//  RecordButtonView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftUI

struct RecordButtonView: View {
    @Binding var isRecording: Bool
    let viewModel: RecordingViewModel
    
    private let animation = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.5)
    private let transition = AnyTransition.opacity.combined(with: .scale(scale: 0.95))
    
    var body: some View {
        Button (action: {
            Task { @MainActor in
                if isRecording {
                    await viewModel.stopRecording()
                } else {
                    await viewModel.startRecording()
                }
                isRecording.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 5)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 10)
                
                if isRecording {
                    Rectangle()
                        .fill(.red.opacity(0.8))
                        .frame(width: 38, height: 38)
                        .transition(transition.animation(animation))
                } else {
                    Circle()
                        .fill(.red.opacity(0.8))
                        .frame(width: 50, height: 50)
                        .transition(transition.animation(animation))
                }
            }
        }
        .frame(width: 70, height: 80)
    }
}
