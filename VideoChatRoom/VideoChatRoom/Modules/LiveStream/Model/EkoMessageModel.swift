//
//  EkoMessageModel.swift
//  EkoUIKit
//
//  Created by Sarawoot Khunsri on 17/8/2563 BE.
//  Copyright © 2563 Eko Communication. All rights reserved.
//

import UIKit
import EkoChat
import UpstraUIKit

enum ReactionType: String {
    case heart
    case smile
    case joy
    case love
    case fire
    
    var title: String {
        switch self {
        case .heart: return "❤️"
        case .smile: return "😃"
        case .joy: return "😂"
        case .love: return "😍"
        case .fire: return "🔥"
        }
    }
    
    var sortingOrder: Int {
        switch self {
        case .heart: return 0
        case .smile: return 1
        case .joy: return 2
        case .love: return 3
        case .fire: return 4
        }
    }
    
}

class EkoMessageModel {
    
    let messageId: String
    let userId: String
    let displayName: String
    let syncState: EkoSyncState
    let messageType: EkoMessageType
    let createdAtDate: Date
    let date: String
    let time: String
    let text: String
    let reactions: [ReactionType]
    let parentId: String?
    var parentMessage: EkoMessageModel?
    
    public init(object: EkoMessage) {
        self.messageId = object.messageId
        self.userId = object.userId
        self.displayName = object.user?.displayName ?? "anonymous"
        self.syncState = object.syncState
        self.messageType = object.messageType
        self.createdAtDate = object.createdAtDate
        self.date = EkoDateFormatter.dateString(from: object.createdAtDate)
        self.time = EkoDateFormatter.timeString(from:  object.createdAtDate)
        self.text = object.data?["text"] as? String ?? ""
        self.parentId = object.parentId
        self.reactions = object.reactions?.compactMap { dict in
            if let key = dict.key as? String {
                return ReactionType(rawValue: key)
            }
            return nil
        } ?? []
    }
    
    public var isOwner: Bool {
        return userId == UpstraUIKitManager.client.currentUserId
    }
    
}
