import UIKit
import AVFoundation

class TrackListViewController: UITableViewController, PlayerViewControllerDelegate {

    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                try await setupTracks()
                self.tableView.reloadData()
            } catch {
                print("Error setting up tracks: \(error)")
            }
        }
    }

    func setupTracks() async throws {
        let fileNames = [
            "АИГЕЛ - Пыяла",
            "Баста - На заре",
            "Три дня дождя, MONA - Прощание"
        ]

        for fileName in fileNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                do {
                    let asset = AVAsset(url: url)
                    var track = Track(fileName: fileName)
                    let metadata = try await asset.loadMetadata(for: .id3Metadata)
                    for item in metadata {
                        if let key = item.commonKey {
                            switch key {
                            case .commonKeyTitle:
                                track.title = try await item.load(.value) as? String ?? track.title
                            case .commonKeyArtist:
                                track.artist = try await item.load(.value) as? String ?? track.artist
                            default:
                                break
                            }
                        }
                    }
                    if let duration = try? await asset.load(.duration) {
                        track.duration = duration.seconds
                        track.totalDuration = duration.seconds
                    }

                    tracks.append(track)
                } catch {
                    throw error
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)

        let track = tracks[indexPath.row]
        let artistTitle = "\(track.artist) - \(track.title)"
        let durationText = formatTime(track.totalDuration)

        let artistTitleLabel = UILabel()
        artistTitleLabel.text = artistTitle
        artistTitleLabel.font = UIFont.systemFont(ofSize: 12)
        artistTitleLabel.textColor = .black
        artistTitleLabel.numberOfLines = 0
        artistTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let durationLabel = UILabel()
        durationLabel.text = durationText
        durationLabel.font = UIFont.systemFont(ofSize: 10)
        durationLabel.textColor = .gray
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [artistTitleLabel, UIView(), durationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]

        if let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.track = selectedTrack
            playerVC.tracks = tracks
            playerVC.currentIndex = indexPath.row
            playerVC.delegate = self

            if let currentTrack = AudioManager.shared.currentTrack,
                currentTrack.fileName == selectedTrack.fileName,
                AudioManager.shared.audioPlayer?.isPlaying == true {
                AudioManager.shared.delegate = playerVC as? AudioPlayerDelegate
                present(playerVC, animated: true, completion: nil)
            } else {
                AudioManager.shared.stop()
                AudioManager.shared.delegate = nil
                AudioManager.shared.playTrack(withFileName: selectedTrack.fileName, tracks: tracks)
                present(playerVC, animated: true, completion: nil)
            }
        }
    }

    func playbackStateChanged(isPlaying: Bool, currentIndex: Int) {
    }
}
