//
//  RecordedObjectViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI
import Media

struct RecordedObjectViewModel {
    let recording: RecordedObjectModel
    private let audioPlayer = AudioPlayer()
    
    @MainActor
    func playAudio() async {
        do {
            if let url = urlFromData {
                try await audioPlayer.play(url)
            }
        } catch {
            print(error)
        }
        
    }
    
    private var urlFromData: URL? {
        do {
            let data = recording.audioData
            let fileName = "\(recording.id.uuidString).m4a"
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // Check if the file already exists before writing
            if fileManager.fileExists(atPath: fileURL.path) {
                return fileURL
            } else {
                // Write the data to the file only if it does not already exist
                try data.write(to: fileURL, options: .atomic)
                return fileURL
            }
        } catch {
            return nil
        }
    }
}
