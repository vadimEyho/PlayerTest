import UIKit

class TrackListViewController: UITableViewController {
    
    var tracks: [Track] = []
    var selectedTrack: Track?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTracks()
    }
    
    func setupTracks() {
        // Загрузите ваши треки
        tracks = [
            Track(title: "На заре", artist: "АИГЕЛ", fileName: "АИГЕЛ - Пыяла"),
            Track(title: "На заре", artist: "Баста", fileName: "Баста - На заре"),
            Track(title: "Прощание", artist: "Три дня дождя, MONA", fileName: "Три дня дождя, MONA - Прощание")
        ]
    }

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        AudioManager.shared.playAudio(fileName: selectedTrack.fileName)
        self.selectedTrack = selectedTrack
        performSegue(withIdentifier: "PlayerSegue", sender: selectedTrack)
    }
}

// MARK: - PlayerViewControllerDelegate

extension TrackListViewController: PlayerViewControllerDelegate {
    func playbackStateChanged(isPlaying: Bool, currentIndex: Int) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedTrack = tracks[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = selectedTrack.title
                cell.detailTextLabel?.text = selectedTrack.artist
            }
        }
    }
}
