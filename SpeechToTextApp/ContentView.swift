//
//  ContentView.swift
//  SpeechToTextApp
//
//  Created by Artemy Volkov on 25.06.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            Text(speechRecognizer.recognizedText)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .animation(.default, value: speechRecognizer.recognizedText)
            
            Button(action: speechRecognizer.toggleRecognition) {
                Text(speechRecognizer.isRecognizing ? "Stop Recognition" :  "Start Recognition")
            }
            .padding()
            .foregroundColor(.white)
            .fixedSize()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(speechRecognizer.isRecognizing ? .red : .green)
            )
        }
        .padding()
        .animation(.default, value: speechRecognizer.isRecognizing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
