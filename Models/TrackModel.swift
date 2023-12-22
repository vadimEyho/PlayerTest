import AVFoundation

struct Track: Equatable {
    var title: String
    var artist: String
    var fileName: String
    var duration: TimeInterval = 0
    var totalDuration: TimeInterval = 0

    init(fileName: String) {
        let components = fileName.components(separatedBy: " - ")
        if components.count == 2 {
            artist = components[0]
            title = components[1]
        } else {
            artist = "Unknown Artist"
            title = fileName
        }
        self.fileName = fileName
    }
}

