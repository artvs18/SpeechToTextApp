//
//  SpeechRecognizer.swift
//  SpeechToTextApp
//
//  Created by Artemy Volkov on 25.06.2023.
//

import Foundation
import Speech
import Combine

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var recognizedText: String = ""
    @Published var isRecognizing: Bool = false
    
    init() {}
}

extension SpeechRecognizer {
    private func startRecognition() {
        recognizedText = ""
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.recognitionTask?.cancel()
            self?.recognitionTask = nil
            
            self?.request = SFSpeechAudioBufferRecognitionRequest()
            
            guard let request = self?.request else {
                print("Unable to create request.")
                return
            }
            
            guard let inputNode = self?.audioEngine.inputNode else {
                print("Audio engine has no input node.")
                return
            }
            
            request.shouldReportPartialResults = true
            
            self?.recognitionTask = self?.speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
                guard let result = result else {
                    print("Recognition failed: \(error?.localizedDescription ?? "No result")")
                    return
                }
                
                let text = result.bestTranscription.formattedString
                
                self?.addRandomNumber(to: text)
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self?.request?.append(buffer)
            }
            
            self?.audioEngine.prepare()
            
            do {
                try self?.audioEngine.start()
                
                DispatchQueue.main.async {
                    self?.isRecognizing.toggle()
                }
            } catch {
                print("Could not start audio engine: \(error)")
            }
        }
    }
    
    private func stopRecognition() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.audioEngine.stop()
            self?.audioEngine.inputNode.removeTap(onBus: 0)
            self?.request = nil
            self?.recognitionTask = nil
            
            DispatchQueue.main.async {
                self?.isRecognizing.toggle()
            }
        }
    }
    
    private func addRandomNumber(to text: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let words = text.split(separator: " ")
            let wordsWithNumbers = words.map { word -> String in
                let randomNumber = Int.random(in: 1...100)
                return "\(word) \(randomNumber)"
            }
            let finalText = wordsWithNumbers.joined(separator: " ")
            
            DispatchQueue.main.async {
                self?.recognizedText = finalText
            }
        }
    }
    
    func toggleRecognition() {
        isRecognizing ? stopRecognition() : startRecognition()
    }
}
