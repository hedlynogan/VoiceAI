//
//  WhisperKitManager.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/25/24.
//

import Foundation
import WhisperKit
import SwiftUI
import SwiftData

class WhisperKitDownloadManager: ObservableObject {
    
    private let modelStorage: String = "huggingface/models/argmaxinc/whisperkit-coreml"
    private var availableModels: [String] = []
    private var disabledModels: [String] = WhisperKit.recommendedModels().disabled
    private let repoName = "argmaxinc/whisperkit-coreml"
    private var specializationProgressRatio: Float = 0.7
    
    #if os(iOS)
    private let model: String = ModelVariant.tinyEn.description
    #elseif os(macOS)
    private let model: String = ModelVariant.largev3.description
    #endif
    
    private(set) var whisperKit: WhisperKit? = nil
    private(set) var localModelPath: String = ""
    private(set) var localModels: [String] = []
    
    @Published private(set) var downloadProgress: Float = 0
    @Published private(set) var modelState: ModelState = .unloaded
    @Published private(set) var availableLanguages: [String] = []
    
    static let shared = WhisperKitDownloadManager()
    
    private init() {} // Private initializer to ensure singleton usage
    
    private func fetchModel(modelContext: ModelContext) {
        availableModels = [model]
        // First check what's already downloaded
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelPath = documents.appendingPathComponent(modelStorage).path

            // Check if the directory exists
            if FileManager.default.fileExists(atPath: modelPath) {
                localModelPath = modelPath
                do {
                    let downloadedModels = try FileManager.default.contentsOfDirectory(atPath: modelPath)
                    for model in downloadedModels where !localModels.contains(model) {
                        localModels.append(model)
                        modelState = .downloaded
                        Recording.transcribeRecordings(modelContext: modelContext)
                    }
                } catch {
                    print("Error enumerating files at \(modelPath): \(error.localizedDescription)")
                }
            }
        }

        localModels = WhisperKit.formatModelFiles(localModels)
        for model in localModels {
            if !availableModels.contains(model),
               !disabledModels.contains(model)
            {
                availableModels.append(model)
            }
        }

        print("Found locally: \(localModels)")
        print("Selected model: \(model)")
        print("Local File Path: \(localModelPath)")

        Task {
            let remoteModels = try await WhisperKit.fetchAvailableModels(from: self.repoName)
            for model in remoteModels {
                if !self.availableModels.contains(model),
                   !self.disabledModels.contains(model)
                {
                    self.availableModels.append(model)
                }
            }
        }
    }

    func downloadModel(modelContext: ModelContext, redownload: Bool = false) {
        print("DOWNLOADING MODEL: \(model)")
        print("DISABLED MODELS FOR THIS DEVICE: \(WhisperKit.recommendedModels().disabled)")
        whisperKit = nil
        Task {
            whisperKit = try await WhisperKit(
                verbose: true,
                logLevel: .debug,
                prewarm: false,
                load: false,
                download: false
            )
            guard let whisperKit = whisperKit else {
                return
            }

            var folder: URL?

            // Check if the model is available locally
            if localModels.contains(model.description) && !redownload {
                // Get local model folder URL from localModels
                // TODO: Make this configurable in the UI
                folder = URL(fileURLWithPath: localModelPath).appendingPathComponent(model.description)
            } else {
                // Download the model
                folder = try await WhisperKit.download(variant: model.description, from: repoName, progressCallback: { progress in
                    DispatchQueue.main.async {
                        self.downloadProgress = Float(progress.fractionCompleted) * self.specializationProgressRatio
                        self.modelState = .downloading
                    }
                })
            }
            
            await MainActor.run {
                self.downloadProgress = specializationProgressRatio
                modelState = .downloaded
                Recording.transcribeRecordings(modelContext: modelContext)
            }

            if let modelFolder = folder {
                whisperKit.modelFolder = modelFolder

                await MainActor.run {
                    // Set the loading progress to 90% of the way after prewarm
                    self.downloadProgress = specializationProgressRatio
                    modelState = .prewarming
                }

                // Prewarm models
                do {
                    try await whisperKit.prewarmModels()
                } catch {
                    print("Error prewarming models, retrying: \(error.localizedDescription)")
                    if !redownload {
                        downloadModel(modelContext: modelContext, redownload: true)
                        return
                    } else {
                        // Redownloading failed, error out
                        modelState = .unloaded
                        return
                    }
                }

                await MainActor.run {
                    // Set the loading progress to 90% of the way after prewarm
                    self.downloadProgress = specializationProgressRatio + 0.9 * (1 - specializationProgressRatio)
                    modelState = .loading
                }

                try await whisperKit.loadModels()

                await MainActor.run {
                    if !localModels.contains(model.description) {
                        localModels.append(model.description)
                    }
                    
                    availableLanguages = Constants.languages.map { $0.key }.sorted()
                    downloadProgress = 1.0
                    modelState = whisperKit.modelState
                }
            }
        }
    }
    
    func deleteModel() {
        if localModels.contains(model) {
            let modelFolder = URL(fileURLWithPath: localModelPath).appendingPathComponent(model)
            
            do {
                try FileManager.default.removeItem(at: modelFolder)
                
                if let index = localModels.firstIndex(of: model) {
                    localModels.remove(at: index)
                }
                
                modelState = .unloaded
            } catch {
                print("Error deleting model: \(error)")
            }
        }
    }
}
