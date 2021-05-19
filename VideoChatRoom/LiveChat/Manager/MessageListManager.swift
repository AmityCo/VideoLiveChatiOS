//
//  MessageListManager.swift
//  TestMigration
//
//  Created by Nontapat Siengsanor on 5/4/2564 BE.
//

import UIKit
import EkoChat
import UpstraUIKit

protocol MessageListManagerDelegate: class {
    func manager(_ manager: MessageListManager, didReceiveMessages messages: [EkoMessageModel])
    func manager(_ manager: MessageListManager, didCreateMessageSuccess message: EkoMessageModel)
    func manager(_ manager: MessageListManager, didCreateMessageFailWithError error: Error?)
}

protocol MessageListManagerProtocol {
    
    var delegate: MessageListManagerDelegate? { get set }
    
    // action
    func fetchMessages()
    func loadPreviousMessages()
    func sendMessage(withText text: String, withParentId parentId: String?)
    
    // datasource
    func message(at indexPath: IndexPath) -> EkoMessageModel
    func reactions(at indexPath: IndexPath) -> [ReactionType]
    func numberOfMessages() -> Int
    
}

class MessageListManager: MessageListManagerProtocol {
    
    // MARK: - Properties
    
    weak var delegate: MessageListManagerDelegate?
    
    private let channelId: String
    private var messages: [EkoMessageModel] = []
    private let messageRepository: EkoMessageRepository
    private let reactionRepository: EkoReactionRepository
    private var messagesCollection: EkoCollection<EkoMessage>?
    private var messagesNotificationToken: EkoNotificationToken?
    private var createMessageNotificationToken: EkoNotificationToken?
    private var parentMessageTokenMap: [String: EkoNotificationToken] = [:]
    private var reactionTokenMap: [String: EkoNotificationToken] = [:]
    private var reactionMap: [String: [ReactionType]] = [:]
    
    init(channelId: String) {
        self.channelId = channelId
        messageRepository = EkoMessageRepository(client: UpstraUIKitManager.client)
        reactionRepository = EkoReactionRepository(client: UpstraUIKitManager.client)
    }
    
    // MARK: - Action
    
    func getMessage(messageId: String, completion: ((EkoMessage?) -> Void)?) {
        let messageObject = messageRepository.getMessage(messageId)
        messagesNotificationToken = messageObject?.observe { (message, _) in
            completion?(message.object)
        }
    }
    
    func fetchMessages() {
        messagesCollection = messageRepository.messages(withChannelId: channelId, filterByParentId: false, parentId: nil, reverse: true)
        messagesNotificationToken = messagesCollection?.observe { [weak self] (collection, _, error) in
            self?.prepareData(with: collection)
        }
    }
    
    func loadPreviousMessages() {
        // load previous page when scrolled to the top
        guard let collection = messagesCollection else { return }
        switch collection.loadingStatus {
        case .loaded:
            if collection.hasPrevious {
                collection.previousPage()
            }
        default:
            break
        }
    }
    
    func sendMessage(withText text: String, withParentId parentId: String?) {
        if parentId != "" {
            createMessageNotificationToken = messageRepository.createTextMessage(withChannelId: channelId, text: text, parentId: parentId)
                .observe { [weak self] (message, error) in
                    guard let strongSelf = self else { return }
                    if let object = message.object {
                        let model = EkoMessageModel(object: object)
                        self?.delegate?.manager(strongSelf, didCreateMessageSuccess: model)
                    } else {
                        self?.delegate?.manager(strongSelf, didCreateMessageFailWithError: error)
                    }
                }
        } else {
            createMessageNotificationToken = messageRepository.createTextMessage(withChannelId: channelId, text: text)
                .observe { [weak self] (message, error) in
                    guard let strongSelf = self else { return }
                    if let object = message.object {
                        let model = EkoMessageModel(object: object)
                        self?.delegate?.manager(strongSelf, didCreateMessageSuccess: model)
                    } else {
                        self?.delegate?.manager(strongSelf, didCreateMessageFailWithError: error)
                    }
                }
        }
    }
    
    func react(message: EkoMessageModel, with reaction: ReactionType) {
        if reactionMap[message.messageId]?.contains(reaction) ?? false {
            // if message contains desire reaction, remove the action.
            reactionRepository.removeReaction(reaction.rawValue, referenceId: message.messageId, referenceType: .message) { [weak self] (success, error) in
                guard let strongSelf = self else { return }
                if success {
                    print("-> successfully removed \(reaction.rawValue) reaction")
                    if let index = strongSelf.reactionMap[message.messageId]?.firstIndex(where: { $0 == reaction }) {
                        strongSelf.reactionMap[message.messageId]?.remove(at: index)
                        strongSelf.delegate?.manager(strongSelf, didReceiveMessages: strongSelf.messages)
                    }
                } else  {
                    print("-> failed removing \(reaction.rawValue)")
                    strongSelf.messagesCollection?.resetPage() // force reloading when error occurs
                }
            }
        } else {
            // if message doesn't contain the reaction, add the action.
            reactionRepository.addReaction(reaction.rawValue, referenceId: message.messageId, referenceType: .message) { [weak self] (success, error) in
                guard let strongSelf = self else { return }
                if success {
                    print("-> successfully added \(reaction.rawValue) reaction")
                    strongSelf.reactionMap[message.messageId]?.append(reaction)
                    strongSelf.delegate?.manager(strongSelf, didReceiveMessages: strongSelf.messages)
                } else  {
                    print("-> failed adding \(reaction.rawValue)")
                    strongSelf.messagesCollection?.resetPage() // force reloading when error occurs
                }
            }
        }
    }
    
    func report(message: EkoMessageModel) {
        getMessage(messageId: message.messageId) { (message) in
            guard let message = message else { return }
            let messageFlagger = EkoMessageFlagger(client: UpstraUIKitManager.client, message: message)
            messageFlagger.flag { success, error in
                if success {
                    print("Report success")
                } else {
                    print("Report failed")
                }
            }
        }
    }
    
    // MARK: - Datasource
    
    func message(at indexPath: IndexPath) -> EkoMessageModel {
        return messages[indexPath.row]
    }
    
    func reactions(at indexPath: IndexPath) -> [ReactionType] {
        let message = messages[indexPath.row]
        return reactionMap[message.messageId]?
            .sorted(by: { $0.sortingOrder < $1.sortingOrder }) ?? []
    }
    
    func numberOfMessages() -> Int {
        return messages.count
    }
    
    // MARK: - Private method
    
    private func prepareData(with collection: EkoCollection<EkoMessage>?) {
        guard let collection = collection else { return }
        print("-> Collection count: \(collection.count())")
        var storeMessages: [EkoMessageModel] = []
        for index in 0..<collection.count() {
            guard let message = collection.object(at: UInt(index)) else { return }
            let model = EkoMessageModel(object: message)
            storeMessages.append(model)
            
            if let parentId = model.parentId {
                parentMessageTokenMap[parentId] = messageRepository.getMessage(parentId)?.observe { [weak self] (parentMessage, _) in
                    if let object = parentMessage.object {
                        model.parentMessage = EkoMessageModel(object: object)
                    }
                    self?.parentMessageTokenMap[parentId]?.invalidate()
                }
            }
            
            if reactionMap[model.messageId] == nil {
                reactionMap[model.messageId] = model.reactions
            }
        }
        messages = storeMessages.reversed()
        delegate?.manager(self, didReceiveMessages: messages)
    }
    
}
