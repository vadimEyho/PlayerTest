import AVFoundation

protocol AudioPlayerDelegate: AnyObject {
    func playbackStateChanged(isPlaying: Bool, currentIndex: Int)
}

class AudioManager: NSObject {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?
    var currentTrack: Track?
    var tracks: [Track] = []
    weak var delegate: AudioPlayerDelegate?
    
    private var _currentIndex: Int = 0

    var currentIndex: Int {
        get {
            return _currentIndex
        }
        set {
            let selectedTrack = tracks[newValue]
            updateTrackInfoClosure?(selectedTrack)
            _currentIndex = newValue
        }
    }

    var updateTrackInfoClosure: ((Track) -> Void)?

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func playTrack(withFileName fileName: String, tracks: [Track]) {
        if let currentTrack = currentTrack, currentTrack.fileName == fileName, let player = audioPlayer {
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

                if let selectedTrack = tracks.first(where: { $0.fileName == fileName }) {
                    currentTrack = selectedTrack
                    self.tracks = tracks
                    currentTrack?.duration = audioPlayer?.duration ?? 0
                    currentTrack?.totalDuration = tracks.reduce(0) { $0 + $1.duration }

                    delegate?.playbackStateChanged(isPlaying: true, currentIndex: currentIndex)
                    updateTrackInfoClosure?(selectedTrack)
                }
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

        currentIndex = (currentIndex + 1) % tracks.count
        let selectedTrack = tracks[currentIndex]
        playTrack(withFileName: selectedTrack.fileName, tracks: tracks)
    }

    func playPreviousTrack() {
        guard !tracks.isEmpty else {
            return
        }

        let newIndex = (currentIndex - 1 + tracks.count) % tracks.count
        playTrack(atIndex: newIndex)
    }

    private func playTrack(atIndex index: Int) {
        let selectedTrack = tracks[index]
        playTrack(withFileName: selectedTrack.fileName, tracks: tracks)
    }

    @objc private func audioPlayerDidFinishPlaying(_ notification: Notification) {
        delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)
        playNextTrack()
        
        if let currentTrack = currentTrack {
            playTrack(withFileName: currentTrack.fileName, tracks: tracks)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)
        playNextTrack()
    }
}
