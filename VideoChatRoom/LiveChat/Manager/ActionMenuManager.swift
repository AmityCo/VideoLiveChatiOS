//
//  ActionMenuManager.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 19/5/2564 BE.
//

import UIKit

class ActionMenuManager {
    
    private let controller = UIMenuController.shared
    
    weak var messageListManager: MessageListManager?
    weak var messageComposeBarView: MessageComposeBarView?
    
    func showMenuItem(on view: UIView, message: EkoMessageModel) {
        messageComposeBarView?.resignFirstResponder()
        guard controller.menuItems == nil else {
            // if `menuItems` exists, hide it.
            resetMenuItems()
            return
        }

        var menuItems: [UIMenuItem] = []

        let reactionTypes: [ReactionType] = [.heart, .smile, .joy, .love, .fire]
        for reactionType in reactionTypes {
            let reactionItem = UIMenuItem(title: reactionType.title) { [weak self] _ in
                self?.messageListManager?.react(message: message, with: reactionType)
                self?.resetMenuItems()
            }
            menuItems.append(reactionItem)
        }
        let replyItem = UIMenuItem(title: "Reply") { [weak self] _ in
            self?.messageComposeBarView?.configureReplyView(with: message)
            self?.resetMenuItems()
        }
        let reportItem = UIMenuItem(title: "Report") { [weak self] _ in
            self?.messageListManager?.report(message: message)
            self?.resetMenuItems()
        }
        menuItems.append(replyItem)
        menuItems.append(reportItem)
        controller.menuItems = menuItems

        if #available(iOS 13.0, *) {
            controller.showMenu(from: view, rect: view.bounds)
        } else {
            controller.setTargetRect(view.bounds, in: view)
            controller.setMenuVisible(true, animated: true)
        }
    }
    
    func resetMenuItems() {
        // In order to support menu dismissing on focused cell,
        // we need clear `menuItems` whenever user interacts with other view.
        UIMenuController.shared.menuItems = nil
    }
    
}
