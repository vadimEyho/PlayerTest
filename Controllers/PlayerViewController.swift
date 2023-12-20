import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    var audioPlayer: AVAudioPlayer?
    var track: Track?
    var currentIndex: Int = 0
    var tracks: [Track] = []
    var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioPlayer()
        startUpdateTimer()
    }

    func setupUI() {
        guard let track = track else {
            return
        }

        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        durationLabel.text = "00:00"
        progressSlider.value = 0

        progressSlider.minimumValue = 0
            progressSlider.maximumValue = 1
            progressSlider.setThumbImage(UIImage(), for: .normal)
            progressSlider.minimumTrackTintColor = UIColor.systemBlue
            progressSlider.maximumTrackTintColor = UIColor.lightGray

        
    }

    func setupAudioPlayer() {
        guard let track = track else {
            return
        }

        currentIndex = tracks.firstIndex(where: { $0.fileName == track.fileName }) ?? 0

        if let existingPlayer = audioPlayer {
            existingPlayer.stop()
        }

        if let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found.")
        }
    }


    func play() {
        setupAudioPlayer()
        audioPlayer?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateUI()
    }

    func pause() {
        setupAudioPlayer()
        audioPlayer?.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        updateUI()
    }


    func playNextTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex + 1) % tracks.count
        track = tracks[currentIndex]
        setupUI()
        setupAudioPlayer()
        play()
    }

    func playPreviousTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        track = tracks[currentIndex]
        setupUI()
        setupAudioPlayer()
        play()
    }


    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerFired), userInfo: nil, repeats: true)
    }

    @objc func updateTimerFired() {
        updateUI()
    }

    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let player = self.audioPlayer {
                if player.isPlaying {
                    self.pause()
                    print("Paused")
                } else {
                    self.play()
                    print("Playing")
                }
            }
        }
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        playNextTrack()
    }

    @IBAction func prevButtonTapped(_ sender: UIButton) {
        playPreviousTrack()
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        stopUpdateTimer()
        audioPlayer?.stop()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        if let player = audioPlayer {
            player.currentTime = TimeInterval(sender.value)
            currentTimeLabel.text = formatTime(player.currentTime)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextTrack()
    }
}

// MARK: - Helper methods

extension PlayerViewController {
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func updateUI() {
        guard let player = audioPlayer else {
            return
        }

        currentTimeLabel.text = formatTime(player.currentTime)
        progressSlider.value = Float(player.currentTime)
        durationLabel.text = formatTime(player.duration)
        
        progressSlider.value = Float(player.currentTime)

        durationLabel.text = formatTime(player.duration)
        
        let progress = player.currentTime / player.duration
                progressSlider.setValue(Float(progress), animated: false)

    }
}
