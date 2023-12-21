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
            // Перед изменением currentIndex, уведомляем об изменении текущего трека
            let selectedTrack = tracks[newValue]
            updateTrackInfoClosure?(selectedTrack)
            _currentIndex = newValue
        }
    }

    // Добавьте замыкание для обновления информации о треке
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

                if let selectedTrack = tracks.first(where: { $0.fileName == fileName }) {
                    currentTrack = selectedTrack
                    self.tracks = tracks
                    // Установите продолжительность для текущего трека
                    currentTrack?.duration = audioPlayer?.duration ?? 0
                    // Установите общую продолжительность для текущего трека
                    currentTrack?.totalDuration = tracks.reduce(0) { $0 + $1.duration }

                    // Уведомляем делегата о начале воспроизведения нового трека
                    delegate?.playbackStateChanged(isPlaying: true, currentIndex: currentIndex)

                    // Вызовите замыкание для обновления информации о треке
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
        // Уведомляем делегата о завершении воспроизведения текущего трека
        delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)

        // Переключаемся на следующий трек
        playNextTrack()
        
        // Убедимся, что метод playNextTrack установит новый текущий трек и запустит его воспроизведение
        // без этого кода, он просто инкрементирует currentIndex и вызывает playTrack(atIndex:),
        // который игнорирует воспроизведение, если трек такой же, как текущий
        if let currentTrack = currentTrack {
            playTrack(withFileName: currentTrack.fileName, tracks: tracks)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Уведомляем делегата о завершении воспроизведения текущего трека
        delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)

        // Переключаемся на следующий трек
        playNextTrack()
    }
}
