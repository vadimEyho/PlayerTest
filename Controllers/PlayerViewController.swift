import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
 
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    


    @IBOutlet weak var closeButton: UIButton!

    var audioPlayer: AVAudioPlayer?
    var track: Track?
    var currentIndex: Int = 0
    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioPlayer()
    }

    func setupUI() {
        guard let track = track else {
            return
        }

        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        durationLabel.text = "00:00"
        progressSlider.value = 0
    }

    func setupAudioPlayer() {
        guard let track = track,
              let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("Audio file not found.")
            return
        }

        do {
            if let existingPlayer = audioPlayer {
                existingPlayer.stop()
            }

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            play()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    func play() {
        audioPlayer?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateUI()
    }

    func pause() {
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
    }

    func playPreviousTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        track = tracks[currentIndex]
        setupUI()
        setupAudioPlayer()
    }

    // MARK: - IBActions

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

    func audioPlayerUpdateTime(_ player: AVAudioPlayer) {
        updateUI()
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
    }
}
