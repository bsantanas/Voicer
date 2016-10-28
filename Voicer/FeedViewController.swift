//
//  FeedViewController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class FeedViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    
    //MARK: Variables
    let trendingNotes: Results<Note> = {
        let realm = try! Realm()
        return realm.objects(Note.self).sorted(byProperty: "timestamp", ascending: false)
    }()
    let recommendedNotes: Results<Note> = {
        let realm = try! Realm()
        return realm.objects(Note.self).sorted(byProperty: "timestamp", ascending: false)
    }()
    var filteredNotes: Results<Note>?
    var sectionNames: [String] {
        return Set(trendingNotes.value(forKeyPath: "topic") as! [String]).sorted()
    }
    var trendingNotesToken: NotificationToken?
    var recommendedNotesToken: NotificationToken?
    var filteredNotesToken: NotificationToken?
    var audioPlayer: AVAudioPlayer!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotificationsForRealmCollections()
    }
    
    // MARK: Instance methods
    
    func playAudioFileFromNoteAt(index: Int) {
        do {
            let notes = currentNotes()
            let url = getDocumentsDirectory().appendingPathComponent(notes[index].id)
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("Couldn't open player")
        }
    }
    
    func currentNotes() -> Results<Note> {
        if let _ = filteredNotes {
            return filteredNotes!
        } else if segmentedControl.selectedSegmentIndex == 0 {
            return trendingNotes
        } else {
            return recommendedNotes
        }
    }
    
    func registerNotificationsForRealmCollections() {
        
        recommendedNotesToken = recommendedNotes.addNotificationBlock {[weak self]
            (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView,
                self?.currentNotes() == self?.recommendedNotes else { return }
            
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
        
        trendingNotesToken = trendingNotes.addNotificationBlock {[weak self]
            (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView,
                self?.currentNotes() == self?.trendingNotesToken else { return }
            
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
    
    func setFilteredNotes() {
        
        let realm = try! Realm()
        filteredNotes = realm.objects(Note.self).sorted(byProperty: "timestamp", ascending: false)
        
        filteredNotesToken = filteredNotes!.addNotificationBlock {[weak self]
            (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView,
                self?.currentNotes() == self?.filteredNotesToken else { return }
            
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
    
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = filteredNotes {
            return sectionNames.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notes = currentNotes()
        return notes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let notes = currentNotes()
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
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: UITableViewDelegate
}
