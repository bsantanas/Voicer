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
    @IBOutlet weak var graphView: VoiceGraphView!
    var tapAction: ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnGraph(tap:)))
        self.graphView.addGestureRecognizer(tap)
    }

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func configureWith(_ note: Note) {
        titleLabel!.text = "This is a very very long title with a lot of words that occupies two lines at least"//note.id 
        let date = NoteCell.formatter.string(from: note.timestamp)
        dateLabel!.text = date
        graphView.setBarsPathWith(levels: note.wavePoints.map({ CGFloat($0.value) }))
    }
    
    func flashBackground() {
        backgroundView = UIView()
        backgroundView!.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0)
        UIView.animate(withDuration: 2.0, animations: {
            self.backgroundView!.backgroundColor = .white
        })
    }

    func tappedOnGraph(tap: UITapGestureRecognizer) {
        tapAction?(self)
    }
}
