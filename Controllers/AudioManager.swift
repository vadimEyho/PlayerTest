//
//  AudioManager.swift
//  PlayerTest
//
//  Created by Вадим Эйхольс on 20.12.2023.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?

    func playAudio(fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found.")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
    }
}
