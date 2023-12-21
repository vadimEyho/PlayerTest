import UIKit
import AVFoundation

protocol PlayerViewControllerDelegate: AnyObject {
    func playbackStateChanged(isPlaying: Bool, currentIndex: Int)
}

class PlayerViewController: UIViewController {

    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: CustomSlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    var track: Track?
    var currentIndex: Int = 0
    var tracks: [Track] = []

    var updateTimer: Timer?

    weak var delegate: PlayerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startUpdateTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopUpdateTimer()
    }

    func setupUI() {
        guard let track = track else {
            return
        }

        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        durationLabel.text = formatTime(AudioManager.shared.audioPlayer?.duration ?? 0)
        progressSlider.value = 0

        // Устанавливаем изображение кнопки в состояние "Pause"
        playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
    }



    func playNextTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex + 1) % tracks.count
        track = tracks[currentIndex]
        setupUI()
        AudioManager.shared.playTrack(withFileName: track?.fileName ?? "", tracks: tracks)
    }

    func playPreviousTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        track = tracks[currentIndex]
        setupUI()
        AudioManager.shared.playTrack(withFileName: track?.fileName ?? "", tracks: tracks)
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
        if AudioManager.shared.audioPlayer?.isPlaying == true {
            pause()
        } else {
            play()
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
        dismiss(animated: true) {
            AudioManager.shared.stop()
            self.delegate?.playbackStateChanged(isPlaying: false, currentIndex: self.currentIndex)
        }
    }

    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        if let player = AudioManager.shared.audioPlayer {
            player.currentTime = TimeInterval(sender.value) * player.duration
            currentTimeLabel.text = formatTime(player.currentTime)
            updateUI()
        }
    

    }

    func play() {
        if let player = AudioManager.shared.audioPlayer {
            player.play()
            UIView.transition(with: playPauseButton,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
                              },
                              completion: nil)
            delegate?.playbackStateChanged(isPlaying: true, currentIndex: currentIndex)
        }
    }

    func pause() {
        if let player = AudioManager.shared.audioPlayer {
            player.pause()
            UIView.transition(with: playPauseButton,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
                              },
                              completion: nil)
            delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func updateUI() {
        guard let player = AudioManager.shared.audioPlayer else {
            return
        }

        currentTimeLabel.text = formatTime(player.currentTime)
        let newProgress = Float(player.currentTime / player.duration)
        UIView.animate(withDuration: 0.3) {
            self.progressSlider.setValue(newProgress, animated: true)
            self.progressSlider.setNeedsDisplay()
        }

        delegate?.playbackStateChanged(isPlaying: player.isPlaying, currentIndex: currentIndex)
    }


}
