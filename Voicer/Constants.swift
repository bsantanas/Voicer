//
//  Constants.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

struct SegueIdentifiers {
    static let feedToAddNote = "feedToAddNote"
    static let unwindToHome = "unwindToHome"
    static let unwindToHomeAndSave = "unwindToHomeAndSave"
}

struct ReuseIdentifiers {
    static let noteCell = "noteCell"
}

struct Colors {
    struct green {
        static let normal = UIColor(red:80/255,green:177/255,blue:195/255,alpha:1)
        static let dark = UIColor(red:20/255,green:130/255,blue:151/255,alpha:1)
        static let light = UIColor(red:189/255,green:238/255,blue:247/255,alpha:1)
    }
    static let red = UIColor(red:255/255,green:66/255,blue:66/255,alpha:1)
}

