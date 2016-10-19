//
//  TableViewController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class TableViewController: UITableViewController {
    
    let notes: Results<Note> = {
        let realm = try! Realm()
        return realm.objects(Note.self).sorted(byProperty: "timestamp", ascending: false)
    }()
    var token: NotificationToken?
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        token = notes.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(let results, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                
                //re-order repos when new pushes happen
                tableView.insertRows(at: insertions.map { IndexPath(row:$0,section:0 ) }, with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let note = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.noteCell) as! NoteCell
        cell.configureWith(note)
        cell.tapAction = { (cell) in
            self.playAudioFileFromNoteAt(index: (tableView.indexPath(for: cell)?.row)!)
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func playAudioFileFromNoteAt(index: Int) {
        do {
            let url = getDocumentsDirectory().appendingPathComponent(notes[index].id)
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("Couldn't open player")
        }
    }
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
        
    }

}
