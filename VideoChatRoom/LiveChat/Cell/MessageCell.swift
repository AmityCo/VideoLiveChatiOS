//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Kay Thanathip on 1/3/21.
//  Copyright © 2021 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    static var identifier: String { String(describing: self) }

    @IBOutlet private weak var messageBubble: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var replyNameLabel: UILabel!
    @IBOutlet private weak var replyContentLabel: UILabel!
    @IBOutlet private weak var separaterView: UIView!
    @IBOutlet private weak var secondBubbleView: UIView!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var reactionsLabel: UILabel!
    @IBOutlet private weak var reactionsCountLabel: UILabel!
    @IBOutlet private weak var reactionStackView: UIStackView!
    @IBOutlet private weak var reactionsContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = 12
        reactionsContainerView.layer.cornerRadius = 4
    }
    
    func configure(with message: EkoMessageModel, reactions: [ReactionType]) {
        if let parentMessage = message.parentMessage {
            nameLabel.text = parentMessage.displayName
            contentLabel.text = parentMessage.text
            
            replyNameLabel.text = message.displayName
            replyContentLabel.text = message.text
            separaterView.isHidden = false
            secondBubbleView.isHidden = false
        } else {
            nameLabel.text = message.displayName
            contentLabel.text = message.text
            
            separaterView.isHidden = true
            secondBubbleView.isHidden = true
        }
        
        let reactions = reactions.map({ $0.title }).joined(separator: "")
        reactionsLabel.text = "\(reactions)"
        reactionsLabel.isHidden = reactions.count == 0
        reactionsCountLabel.text = "\(reactions.count)"
        reactionsCountLabel.isHidden = reactions.count == 0
        reactionsContainerView.isHidden = reactions.count == 0
    }
    
}
