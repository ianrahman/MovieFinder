//
//  NotificationView.swift
//  MovieFinder
//
//  Created by Ian Rahman on 7/21/17.
//  Copyright © 2017 Evergreen Labs. All rights reserved.
//

import UIKit

// MARK: - Notification Type

enum NotificationType {
    
    case loading
    case defaultError((message: String))
    case jsonError
    
}

// MARK: - Notification View Delegate Protocol

protocol NotificationViewDelegate: class {
    
    func retry()
    
}

// MARK: - Notification View

class NotificationView: UIView {
    
    // MARK: - Properties
    
    let type: NotificationType
    weak var delegate: NotificationViewDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton! {
        didSet {
            retryButton.layer.borderWidth = 1.0
            retryButton.layer.borderColor = #colorLiteral(red: 0.7058042884, green: 0.7059273124, blue: 0.7057965398, alpha: 1).cgColor
        }
    }
    
    // MARK: - Initializers
    
    init(type: NotificationType) {
        self.type = type
        super.init(frame: CGRect.zero)
        containerView = self.loadNib(name: "Notification")
        addSubview(containerView)
        setUI(for: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    fileprivate func setUI(for type: NotificationType) {
        switch type {
        case .loading:
            setLoadingUI()
        case .defaultError(let message):
            setDefaultErrorUI(with: message)
        case .jsonError:
            setJSONErrorUI()
        }
    }
    
    fileprivate func setLoadingUI() {
        titleLabel.text = "Loading"
        messageLabel.isHidden = true
        activityIndicator.startAnimating()
        retryButton.isHidden = true
    }
    
    fileprivate func setDefaultErrorUI(with message: String) {
        titleLabel.text = "Error"
        messageLabel.text = message
        activityIndicator.isHidden = true
        retryButton.isHidden = false
    }
    
    fileprivate func setJSONErrorUI() {
        titleLabel.text = "Error"
        messageLabel.text = "Unable to read data from The Movie Database."
        activityIndicator.isHidden = true
        retryButton.isHidden = false
    }
    
    func present() {
        guard let superView = UIApplication.shared.keyWindow else { return }
        self.frame = superView.frame
        superView.addSubview(self)
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        delegate?.retry()
    }
    
}
