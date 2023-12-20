import UIKit
import AVFoundation

class TrackListViewController: UITableViewController {

    var tracks: [Track] = []
    var selectedTrack: Track?
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTracks()
    }

    func setupTracks() {
        tracks = [
            Track(title: "На заре", artist: "АИГЕЛ", fileName: "АИГЕЛ - Пыяла"),
            Track(title: "На заре", artist: "Баста", fileName: "Баста - На заре"),
            Track(title: "Прощание", artist: "Три дня дождя, MONA", fileName: "Три дня дождя, MONA - Прощание")
        ]
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TrackCell")

        let track = tracks[indexPath.row]
        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = track.artist

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        self.selectedTrack = selectedTrack
        performSegue(withIdentifier: "PlayerSegue", sender: selectedTrack)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerSegue" {
            if let playerVC = segue.destination as? PlayerViewController,
               let selectedTrack = sender as? Track {
                playerVC.track = selectedTrack
                playerVC.tracks = tracks
                playerVC.selectedTrack = selectedTrack
                playerVC.currentIndex = tracks.firstIndex(of: selectedTrack) ?? 0
                // Передаем делегата в плеер
                playerVC.delegate = self
                // Запускаем воспроизведение, если плеер не проигрывает
                if audioPlayer?.isPlaying == false {
                    audioPlayer?.play()
                }
            }
        }
    }
}

// MARK: - PlayerViewControllerDelegate

extension TrackListViewController: PlayerViewControllerDelegate {
    func playbackStateChanged(isPlaying: Bool, currentIndex: Int) {
        // Обновляем состояние воспроизведения в соответствии с изменениями в плеере
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedTrack = tracks[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = selectedTrack.title
                cell.detailTextLabel?.text = selectedTrack.artist
            }
        }
    }
}
