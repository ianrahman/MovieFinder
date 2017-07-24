//
//  Networks.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/21/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import Foundation
import Alamofire

protocol Networks {
    
    var reachability: NetworkReachabilityManager { get }
    
}
