import AVFoundation

class AudioManager: NSObject {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?
    var currentTrack: Track?
    var tracks: [Track] = []

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
                self.tracks = tracks
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

    func playNextTrack() {
        guard !tracks.isEmpty else {
            return
        }

        let newIndex = (currentIndex + 1) % tracks.count
        playTrack(atIndex: newIndex)
    }

    func playPreviousTrack() {
        guard !tracks.isEmpty else {
            return
        }

        let newIndex = (currentIndex - 1 + tracks.count) % tracks.count
        playTrack(atIndex: newIndex)
    }

    private var currentIndex: Int {
        guard let currentTrack = currentTrack else {
            return 0
        }

        return tracks.firstIndex(where: { $0 == currentTrack }) ?? 0
    }

    private func playTrack(atIndex index: Int) {
        let selectedTrack = tracks[index]
        playTrack(withFileName: selectedTrack.fileName, tracks: tracks)
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
