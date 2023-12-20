//
//  UITableViewController.swift
//  PlayerTest
//
//  Created by Вадим Эйхольс on 19.12.2023.
//

import UIKit

class TrackListViewController: UITableViewController {

    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTracks()
    }

    func setupTracks() {
        tracks = [
            Track(title: "На заре", artist: "АИГЕЛ", fileName: "АИГЕЛ - На заре"),
            Track(title: "На заре", artist: "Баста", fileName: "Баста - На заре.mp3"),
            Track(title: "Прощание", artist: "Три дня дождя, MONA", fileName: "Три дня дождя, MONA - Прощание")
        ]
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем ячейку в коде без использования IBOutlet
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TrackCell")

        let track = tracks[indexPath.row]
        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = track.artist

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        performSegue(withIdentifier: "PlayerSegue", sender: selectedTrack)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerSegue" {
            if let playerVC = segue.destination as? PlayerViewController,
               let selectedTrack = sender as? Track {
                playerVC.track = selectedTrack
            }
        }
    }
}

