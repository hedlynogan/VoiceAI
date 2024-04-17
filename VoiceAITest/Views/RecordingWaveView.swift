//
//  RecordingWaveView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/17/24.
//

import SwiftUI
import DSWaveformImageViews
import DSWaveformImage
import Media

struct RecordingWaveView: View {
    
    @StateObject var viewModel: RecordingWaveViewModel
    
    init(recorder: AudioRecorder) {
        _viewModel = StateObject(wrappedValue: RecordingWaveViewModel(recorder: recorder))
    }
    
    var body: some View {
        WaveformLiveCanvas(
            samples: viewModel.samples,
            configuration: viewModel.configuration,
            renderer: LinearWaveformRenderer(),
            shouldDrawSilencePadding: true
        )
        .maxWidth(.infinity)
        .maxHeight(30)
    }
}
