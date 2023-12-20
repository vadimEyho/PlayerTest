import AVFoundation

class AudioManager: NSObject {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?
    var currentTrack: Track?

    private override init() {}

    func playTrack(withFileName fileName: String, tracks: [Track]) {
        if let currentTrack = currentTrack, currentTrack.fileName == fileName, let player = audioPlayer {
            // Возвращение на тот же трек, проверяем, играет ли он, и продолжаем воспроизведение
            if !player.isPlaying {
                player.play()
            }
            return
        }

        stop()

        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                currentTrack = tracks.first { $0.fileName == fileName }
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found.")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentTrack = nil
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
