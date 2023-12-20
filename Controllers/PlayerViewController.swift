import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!

    var audioPlayer: AVAudioPlayer?
    var track: Track?

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
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    // MARK: - IBActions

    @IBAction func playPauseButtonTapped(_ sender: Any) {
    DispatchQueue.main.async { [weak self] in
           guard let self = self else { return }

           if let player = self.audioPlayer {
               if player.isPlaying {
                   player.pause()
                   self.playPauseButton.setTitle("Play", for: .normal)
                   print("Paused")
               } else {
                   player.play()
                   self.playPauseButton.setTitle("Pause", for: .normal)
                   print("Playing")
               }
           }
       }
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
        playPauseButton.setTitle("Play", for: .normal)
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentTimeLabel.text = self.formatTime(player.currentTime)
            self.progressSlider.value = Float(player.currentTime)
            self.durationLabel.text = self.formatTime(player.duration)
            print("UI Updated")
        }
    }
}
