//
//  Utilities.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/19/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
