import UIKit
import AVFoundation

class TrackListViewController: UITableViewController, PlayerViewControllerDelegate {

    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                try await setupTracks()
                // После загрузки треков обновите таблицу
                self.tableView.reloadData()
            } catch {
                print("Error setting up tracks: \(error)")
            }
        }
    }

    func setupTracks() async throws {
        // Загрузите ваши треки
        let fileNames = [
            "АИГЕЛ - Пыяла",
            "Баста - На заре",
            "Три дня дождя, MONA - Прощание"
        ]

        // Установим продолжительность и другие метаданные для каждого трека
        for fileName in fileNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                do {
                    let asset = AVAsset(url: url)
                    var track = Track(fileName: fileName)

                    // Получаем метаданные трека
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

                    // Получаем продолжительность для каждого трека
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






    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)

        let track = tracks[indexPath.row]
        let artistTitle = "\(track.artist) - \(track.title)"
        let durationText = formatTime(track.totalDuration)

        // Создаем UILabel для отображения артиста и названия трека
        let artistTitleLabel = UILabel()
        artistTitleLabel.text = artistTitle
        artistTitleLabel.font = UIFont.systemFont(ofSize: 12)  // Размер шрифта по вашему желанию
        artistTitleLabel.textColor = .black  // Цвет текста
        artistTitleLabel.numberOfLines = 0  // Разрешаем перенос текста на несколько строк
        artistTitleLabel.translatesAutoresizingMaskIntoConstraints = false  // Включаем Auto Layout

        // Создаем UILabel для отображения продолжительности трека
        let durationLabel = UILabel()
        durationLabel.text = durationText
        durationLabel.font = UIFont.systemFont(ofSize: 10)  // Размер шрифта по вашему желанию
        durationLabel.textColor = .gray  // Цвет текста
        durationLabel.translatesAutoresizingMaskIntoConstraints = false  // Включаем Auto Layout

        // Создаем стековое представление для размещения элементов
        let stackView = UIStackView(arrangedSubviews: [artistTitleLabel, UIView(), durationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center  // Центрируем содержимое
        stackView.spacing = 8  // Расстояние между элементами (можете настроить по вашему желанию)
        stackView.translatesAutoresizingMaskIntoConstraints = false  // Включаем Auto Layout

        // Добавляем stackView к contentView ячейки
        cell.contentView.addSubview(stackView)

        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Устанавливаем конкретное значение высоты ячейки
        return 50  // Замените это значение на желаемую высоту
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

            if let currentTrack = AudioManager.shared.currentTrack,
                currentTrack.fileName == selectedTrack.fileName,
                AudioManager.shared.audioPlayer?.isPlaying == true {
                // Возвращение на тот же трек, который воспроизводится, просто открываем плеер
                AudioManager.shared.delegate = playerVC as? AudioPlayerDelegate
                present(playerVC, animated: true, completion: nil)
            } else {
                // Выбор нового трека или остановленного трека, останавливаем предыдущий и воспроизводим новый
                AudioManager.shared.stop()
                AudioManager.shared.delegate = nil
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
