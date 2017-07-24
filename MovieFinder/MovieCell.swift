//
//  MovieCell.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Movie Cell

class MovieCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
}
