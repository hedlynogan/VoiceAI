//
//  WaveViewViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/16/24.
//

import SwiftUI
import DSWaveformImageViews
import DSWaveformImage

struct WaveViewViewModel {
    
    @State private var configuration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(Waveform.Style.StripeConfig(color: .red,
                                                    width: 3,
                                                    lineCap: .round)),
        verticalScalingFactor: 0.9
    )
    
    @State private var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .red,
                              width: 3,
                              spacing: 3))
    )
}
