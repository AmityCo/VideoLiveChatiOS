//
//  MessageComposeBarView.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 18/5/2564 BE.
//

import UIKit

protocol MessageComposeBarViewDelegate: class {
    func messageComposeBarView(_ view: MessageComposeBarView, didTouchSendButton button: UIButton, with message: String, parentId: String?)
    func messageComposeBarView(_ view: MessageComposeBarView, didTouchCloseButton button: UIButton)
    func messageComposeBarView(_ view: MessageComposeBarView, touchesBegan touches: Set<UITouch>, with event: UIEvent?)
}

class MessageComposeBarView: UIView {
    
    // MARK: - Variables
    
    private let replyStackView = UIStackView()
    private let replyView = MessageReplyView()
    private let avatarImageView = UIImageView()
    private let textField = UITextField()
    private let sendButton = UIButton()
    private var heightConstraint: NSLayoutConstraint?
    
    weak var delegate: MessageComposeBarViewDelegate?
    private(set) var parentMessage: EkoMessageModel?
    
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
        addSubview(replyStackView)
        addSubview(avatarImageView)
        addSubview(textField)
        addSubview(sendButton)
        
        replyStackView.translatesAutoresizingMaskIntoConstraints = false
        replyStackView.distribution = .fill
        replyStackView.alignment = .fill
        replyStackView.axis = .vertical
        replyStackView.addArrangedSubview(replyView)
        
        replyView.isHidden = true
        replyView.delegate = self
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(named: "user")
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Say something nice..."
        textField.borderStyle = .roundedRect
        textField.delegate = self
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
        sendButton.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            replyStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            replyStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            replyStackView.topAnchor.constraint(equalTo: topAnchor),
            replyView.heightAnchor.constraint(equalToConstant: 78),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            avatarImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),
            textField.topAnchor.constraint(equalTo: replyStackView.bottomAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    @objc private func sendButtonTapped(_ sender: UIButton) {
        delegate?.messageComposeBarView(self, didTouchSendButton: sender, with: textField.text ?? "", parentId: parentMessage?.messageId)
        replyView.isHidden = true
        parentMessage = nil
        textField.text = nil
    }
    
    // MARK: - Configure
    
    func configure(avatar: UIImage?) {
        avatarImageView.image = avatar
    }
    
    func configureReplyView(with message: EkoMessageModel?) {
        parentMessage = message
        if let message = message {
            replyView.configure(displayName: message.displayName, content: message.text)
            replyView.isHidden = false
        } else {
            replyView.isHidden = true
        }
    }
    
}

extension MessageComposeBarView: MessageReplyViewDelegate {
    
    func messageReplyView(_ view: MessageReplyView, didTouchCloseButton button: UIButton) {
        configureReplyView(with: nil)
        delegate?.messageComposeBarView(self, didTouchCloseButton: button)
    }
    
}

extension MessageComposeBarView: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.messageComposeBarView(self, touchesBegan: touches, with: event)
    }
    
}
