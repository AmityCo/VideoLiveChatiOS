//
//  MessageReplyView.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 19/5/2564 BE.
//

import UIKit

protocol MessageReplyViewDelegate: class {
    func messageReplyView(_ view: MessageReplyView, didTouchCloseButton button: UIButton)
}

class MessageReplyView: UIView {
    
    // MARK: - Variables
    
    private let avatarImageView = UIImageView()
    private let displayNameLabel = UILabel()
    private let contentLabel = UILabel()
    private let closeButton = UIButton()
    
    weak var delegate: MessageReplyViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addSubview(avatarImageView)
        addSubview(displayNameLabel)
        addSubview(contentLabel)
        addSubview(closeButton)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(named: "user")
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        displayNameLabel.textColor = .black
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentLabel.textColor = .black
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.tintColor = .black
        
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            displayNameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            displayNameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            contentLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 8),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    @objc private func closeButtonTapped(_ sender: UIButton) {
        delegate?.messageReplyView(self, didTouchCloseButton: sender)
    }
    
    // MARK: - Configure
    
    func configure(displayName: String, content: String) {
        displayNameLabel.text = displayName
        contentLabel.text = content
    }
    
}
