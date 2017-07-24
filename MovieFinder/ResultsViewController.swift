//
//  ResultsViewController.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/20/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Results Coordinator Protocol

protocol ResultsCoordinator: Coordinator, UITableViewDelegate, UITableViewDataSource {
    
    func viewDidLoad(_ viewController: ResultsViewController)
    func didTapVoiceSearchButton(on viewController: ResultsViewController)
    
}

// MARK: - Results View Controller

final class ResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: ResultsCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var voiceSearchBarButtonItem: UIBarButtonItem = {
        let voiceSearchBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(didTapVoiceSearchButton))
        return voiceSearchBarButtonItem
    }()
    
    // MARK: - Actions
    
    @objc fileprivate func didTapVoiceSearchButton() {
        coordinator?.didTapVoiceSearchButton(on: self)
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        coordinator?.viewDidLoad(self)
    }
    
}
