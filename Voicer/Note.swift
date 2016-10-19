//
//  Note.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import RealmSwift

class Note: Object {
    //MARK: properties
    dynamic var id: String = ""
    dynamic var timestamp = Date()
    
    //MARK: meta
    override class func primaryKey() -> String? { return "id" }
}
