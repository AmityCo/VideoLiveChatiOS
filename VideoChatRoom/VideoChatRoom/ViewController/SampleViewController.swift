//
//  SampleViewController.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 19/5/2564 BE.
//

import UIKit

class SampleViewController: UIViewController {

    @IBOutlet weak var tableView: MessageTableView!
    @IBOutlet weak var messageComposeBarView: MessageComposeBarView!
    
    // MARK: - Variables
    private let messageListManager = MessageListManager(channelId: Credentials.liveChannelId)
    private let actionMenuManager = ActionMenuManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupManager()
        setupTableView()
        setupComposeBarView()
    }
    
    private func setupManager() {
        messageListManager.delegate = self
        tableView.manager = messageListManager
        messageListManager.fetchMessages()
        
        actionMenuManager.messageComposeBarView = messageComposeBarView
        actionMenuManager.messageListManager = messageListManager
    }
    
    private func setupTableView() {
        tableView.actionDelegate = self
    }
    
    private func setupComposeBarView() {
        messageComposeBarView.delegate = self
    }
    
}

extension SampleViewController: MessageListManagerDelegate {
    func manager(_ manager: MessageListManager, didReceiveMessages: [EkoMessageModel]) {
        tableView.reloadData()
    }
    
    func manager(_ manager: MessageListManager, didCreateMessageSuccess message: EkoMessageModel) {
        tableView.reloadData()
    }
    
    func manager(_ manager: MessageListManager, didCreateMessageFailWithError error: Error?) {
        // send message failure
        print(error?.localizedDescription)
    }
}

extension SampleViewController: MessageTableViewDelegate {
    
    func tableView(_ tableView: MessageTableView, didTapCell cell: UITableViewCell, message: EkoMessageModel) {
        actionMenuManager.showMenuItem(on: cell.contentView, message: message)
    }
    
    func tableViewWillBeginDragging(_ tableView: MessageTableView) {
        actionMenuManager.resetMenuItems()
    }
    
}

extension SampleViewController: MessageComposeBarViewDelegate {
    
    func messageComposeBarView(_ view: MessageComposeBarView, didTouchSendButton button: UIButton, with message: String, parentId: String?) {
        messageListManager.sendMessage(withText: message, withParentId: parentId)
    }
    
    func messageComposeBarView(_ view: MessageComposeBarView, didTouchCloseButton button: UIButton) {
        // Do something here
    }
    
    func messageComposeBarView(_ view: MessageComposeBarView, touchesBegan touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        actionMenuManager.resetMenuItems()
    }
    
}
