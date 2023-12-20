import UIKit

class TrackListViewController: UITableViewController, PlayerViewControllerDelegate {

    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTracks()
    }

    func setupTracks() {
        // Загрузите ваши треки
        tracks = [
            Track(title: "На заре", artist: "АИГЕЛ", fileName: "АИГЕЛ - Пыяла", duration: 0, totalDuration: 3*60 + 40),  // Установите продолжительность трека
            Track(title: "На заре", artist: "Баста", fileName: "Баста - На заре", duration: 0, totalDuration: 3*60 + 40),
            Track(title: "Прощание", artist: "Три дня дождя, MONA", fileName: "Три дня дождя, MONA - Прощание", duration: 0, totalDuration: 3*60 + 40)
        ]
    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TrackCell")

        let track = tracks[indexPath.row]
        let artistTitle = "\(track.artist) - \(track.title)"
        let durationText = formatTime(track.totalDuration)

        cell.textLabel?.text = "\(artistTitle) \(durationText)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10)

        return cell
    }




    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }



    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]

        if let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.track = selectedTrack
            playerVC.tracks = tracks
            playerVC.currentIndex = indexPath.row
            playerVC.delegate = self

            if let currentTrack = AudioManager.shared.currentTrack, currentTrack == selectedTrack {
                // Возвращение на тот же трек, продолжаем воспроизведение
                present(playerVC, animated: true, completion: nil)
            } else {
                // Выбор нового трека, останавливаем предыдущий и воспроизводим новый
                AudioManager.shared.stop()
                AudioManager.shared.playTrack(withFileName: selectedTrack.fileName, tracks: tracks)
                present(playerVC, animated: true, completion: nil)
            }
        }
    }


    // MARK: - PlayerViewControllerDelegate

    func playbackStateChanged(isPlaying: Bool, currentIndex: Int) {
        // Обработка изменений состояния воспроизведения, если необходимо
    }
}
