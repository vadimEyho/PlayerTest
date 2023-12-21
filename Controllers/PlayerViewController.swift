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
    var currentlyPlayingTrack: Track?


    var updateTimer: Timer?
    var isSliderBeingTouched = false

    weak var delegate: PlayerViewControllerDelegate?

    override func viewDidLoad() {
         super.viewDidLoad()
         setupUI()
         startUpdateTimer()

         // Добавляем обработчик жестов для слайдера
         let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
         progressSlider.addGestureRecognizer(panGestureRecognizer)

         // Подпишитесь на замыкание для обновления информации о треке
        AudioManager.shared.updateTrackInfoClosure = { [weak self] track in
            self?.updateTrackInfo(track: track)
            // Установите продолжительность в UI
            self?.durationLabel.text = self?.formatTime(track.totalDuration)
        }

     }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Проверяем, откуда происходит переход
        if isMovingFromParent {
            stopUpdateTimer()
            AudioManager.shared.stop()
            delegate?.playbackStateChanged(isPlaying: false, currentIndex: currentIndex)
        }
    }


    func setupUI() {
        guard let track = track else {
            return
        }

        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        durationLabel.text = formatTime(track.totalDuration)  // Устанавливаем продолжительность для текущего трека
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

        // Проверяем, текущий проигрываемый трек
        if track != currentlyPlayingTrack {
            setupUI()
            AudioManager.shared.playTrack(withFileName: track?.fileName ?? "", tracks: tracks)
        }
    }
    
    func updateTrackInfo(track: Track) {
           trackTitleLabel.text = track.title
           artistLabel.text = track.artist
       }

    func playPreviousTrack() {
        if tracks.isEmpty {
            return
        }

        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        track = tracks[currentIndex]

        // Проверяем, текущий проигрываемый трек
        if track != currentlyPlayingTrack {
            setupUI()
            AudioManager.shared.playTrack(withFileName: track?.fileName ?? "", tracks: tracks)
        }
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
            if self.isBeingDismissed {
                AudioManager.shared.stop()
                self.delegate?.playbackStateChanged(isPlaying: false, currentIndex: self.currentIndex)
            }
        }
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        guard let player = AudioManager.shared.audioPlayer, !isSliderBeingTouched else {
            return
        }

        let newTime = TimeInterval(sender.value) * player.duration
        player.currentTime = newTime
        currentTimeLabel.text = formatTime(newTime)
        updateUI()

        // Обновляем currentIndex
        currentIndex = Int(sender.value * Float(tracks.count))
        delegate?.playbackStateChanged(isPlaying: player.isPlaying, currentIndex: currentIndex)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let player = AudioManager.shared.audioPlayer else {
            return
        }

        switch gesture.state {
        case .began:
            isSliderBeingTouched = true
        case .changed:
            let translation = gesture.translation(in: progressSlider)
            let percentage = Float(translation.x / progressSlider.bounds.width)
            let newProgress = max(min(progressSlider.value + percentage, 1.0), 0.0)
            progressSlider.setValue(newProgress, animated: false)
            player.currentTime = TimeInterval(newProgress) * player.duration
            currentTimeLabel.text = formatTime(player.currentTime)
            updateUI()

            // Обновляем currentIndex
            currentIndex = Int(newProgress * Float(tracks.count))
            delegate?.playbackStateChanged(isPlaying: player.isPlaying, currentIndex: currentIndex)
        case .ended, .cancelled, .failed:
            isSliderBeingTouched = false
        default:
            break
        }
    }

    // Добавляем метод для обновления слайдера в реальном времени
    func updateSliderProgress() {
        if let player = AudioManager.shared.audioPlayer {
            let progress = Float(player.currentTime / player.duration)
            progressSlider.setValue(progress, animated: true)
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
        UIView.animate(withDuration: isSliderBeingTouched ? 0.0 : 0.3) {
            self.progressSlider.setValue(newProgress, animated: true)
            self.progressSlider.setNeedsDisplay()
        }

        delegate?.playbackStateChanged(isPlaying: player.isPlaying, currentIndex: currentIndex)
    }
}
