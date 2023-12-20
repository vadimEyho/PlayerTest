//
//  TrackModel.swift
//  PlayerTest
//
//  Created by Вадим Эйхольс on 19.12.2023.
//

import Foundation

struct Track: Equatable {
    let title: String
    let artist: String
    let fileName: String
    var duration: TimeInterval
    var totalDuration: TimeInterval  // Новое поле для общей длительности трека
}

