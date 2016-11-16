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
    dynamic var data = NSData()
    let topics = List<Topic>()
    let wavePoints = List<Point>()
    
    //MARK: meta
    override class func primaryKey() -> String? { return "id" }
    
    convenience init(_ id:String, timestamp:Date){
        self.init()
        self.id = id
        self.timestamp = timestamp
        //self.topics = topics
    }
}

class Topic: Object {
    dynamic var name = ""
}

class Point: Object {
    dynamic var value: Double = 0
    
    convenience init(_ value:Double) {
        self.init()
        self.value = value
    }
}
