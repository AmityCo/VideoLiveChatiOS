//
//  MessageTableView.swift
//  TestMigration
//
//  Created by Nontapat Siengsanor on 5/4/2564 BE.
//

import UIKit
import EkoChat

protocol MessageTableViewDelegate: class {
    func tableView(_ tableView: MessageTableView, didTapCell cell: UITableViewCell, message: EkoMessageModel)
    func tableViewWillBeginDragging(_ tableView: MessageTableView)
}

class MessageTableView: UITableView {
    
    weak var actionDelegate: MessageTableViewDelegate?
    
    // -> 1. declare MessageListManager on global scope
    var manager: MessageListManagerProtocol?
    
    // MARK: - Initializers
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    // MARK: - Private methods
    // -> 2. register cell, set datasouce and delegate
    private func setupTableView() {
        register(UINib(nibName: MessageCell.identifier, bundle: .main), forCellReuseIdentifier: MessageCell.identifier)
        dataSource = self
        delegate = self
    }
    
}

// MARK: - Table View DataSource
// -> 2.1 conform table view data source
extension MessageTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager?.numberOfMessages() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        
        if let manager = manager {
            let message = manager.message(at: indexPath)
            let reactions = manager.reactions(at: indexPath)
            cell.configure(with: message, reactions: reactions)
        }
        return cell
    }
    
}

// MARK: - Table View Delegate
// -> 2.2 confrom table view delegate
extension MessageTableView: UITableViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y.isLessThanOrEqualTo(0) {
            // load previous page when scrolled to the top
            manager?.loadPreviousMessages()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? MessageTableView else { return }
        actionDelegate?.tableViewWillBeginDragging(tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath), let message = manager?.message(at: indexPath) else { return }
        actionDelegate?.tableView(self, didTapCell: cell, message: message)
    }
    
}
