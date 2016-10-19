//
//  NoteCell.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/19/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var tapAction: ((UITableViewCell) -> Void)?

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func configureWith(_ note: Note) {
        titleLabel!.text = note.id
        let date = NoteCell.formatter.string(from: note.timestamp)
        dateLabel!.text = "created: \(date)"
    }
    
    func flashBackground() {
        backgroundView = UIView()
        backgroundView!.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0)
        UIView.animate(withDuration: 2.0, animations: {
            self.backgroundView!.backgroundColor = .white
        })
    }

    @IBAction func buttonTap(sender: AnyObject) {
        tapAction?(self)
    }
}
