//
//  Genre.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import Foundation
import Marshal

// MARK: - Genre

struct Genre {
    
    let id: Int
    let name: String
    
}

// MARK: - Unmarshaling

extension Genre: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
    }
    
}
