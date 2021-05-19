//
//  ClientManager.swift
//  VideoChatRoom
//
//  Created by Kay Thanathip on 5/4/21.
//

import UpstraUIKit
import EkoChat

enum Credentials {
    static let ascApiKey = "YOUR_API_KEY"
    static let userId = "sampleiOSUser"
    static let displayName = UIDevice.current.name
    static let liveChannelId = "YOUR_CHANNEL_ID"
}

class ClientManager {
    
    static let shared = ClientManager()
    private init () { }
    
    // MARK: - Properties
    private var token: EkoNotificationToken?
    private var channelRepository: EkoChannelRepository?
    var completionHandler: (() -> Void)?
    
    func setupUpstraUIKit() {
        UpstraUIKitManager.setup(Credentials.ascApiKey)
        UpstraUIKitManager.registerDevice(withUserId: Credentials.userId, displayName: Credentials.displayName)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            if UpstraUIKitManager.client.connectionStatus == .connected {
                self?.completionHandler?()
                self?.initilizeRepositories()
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Private methods
    
    private func initilizeRepositories() {
        channelRepository = EkoChannelRepository(client: UpstraUIKitManager.client)
        joinChannel(channelId: Credentials.liveChannelId)
    }

    private func joinChannel(channelId: String) {
        guard let channelRepository = self.channelRepository else { return }
        let channelObject: EkoObject<EkoChannel> = channelRepository.joinChannel(channelId)

        token = channelObject.observe { channelObject, error in
            print("Channel joined successfully.")
        }
    }
}
