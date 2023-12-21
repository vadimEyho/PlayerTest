import AVFoundation

struct Track: Equatable {
    let title: String
    let artist: String
    let fileName: String
    var duration: TimeInterval
    var totalDuration: TimeInterval  // Новое поле для общей длительности трека

    init(title: String, artist: String, fileName: String) {
        self.title = title
        self.artist = artist
        self.fileName = fileName
        self.duration = 0
        self.totalDuration = 0

        // Загружаем продолжительность из аудиофайла
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            let playerItem = AVPlayerItem(url: url)
            self.duration = CMTimeGetSeconds(playerItem.asset.duration)
            self.totalDuration = CMTimeGetSeconds(playerItem.asset.duration)
        }
    }
}
