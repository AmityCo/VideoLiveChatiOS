# VideoLiveChat Demo App

## Stack Used
- Swift [Official Document](https://developer.apple.com/swift/resources/)
- Amity UIKit and Chat SDK [Official Document](https://docs.amity.co/uikit/ios-1/overview)
- MenuItemKit [Official Document](https://github.com/cxa/MenuItemKit)

## How to Run Project Locally
### Do a pod install
```
pod install
```
### Open .xcworkspace file on Xcode, build, and run the project

## Amity Chat SDK Installation Guide
### Setup steps for the SDK
1. Add the SDK to your repository

Add the SDK to your repository via **Carthage** or **Cocoapods**
```
# Example for Cocoapods. Add this line to your podfile
pod 'UpstraUIKit', '1.11.4', :source => "https://github.com/EkoCommunications/EkoMessagingSDKUIKit.git"
```
More details on installation method, please refer to here: [Getting Started on iOS](https://docs.amity.co/uikit/ios-1/getting-started)

2. Create new SDK Instance with your API Key

Before using the Chat SDK, you will need to create a new SDK instance with your API key (find it via the Admin Panel under settings). For this project, we have set it up where you only need to put your API key in **ClientManager.swift**. LoadingViewController will use the method to setup everything.

```swift
import UpstraUIKit
import EkoChat

enum Credentials {
    static let ascApiKey = "YOUR_API_KEY"
    ...
}
```
File: Managers/ClientManager.swift

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = true // hide navigation bar
    
    ClientManager.shared.setupUpstraUIKit()
    ClientManager.shared.completionHandler = { [weak self] in
        // This block get called after connection completed
        print("EkoClient successfully connected")
        ...
    }
}
```
File: Modules/Loading/ViewController/LoadingViewController.swift

3. Register a session for your device with User ID

ClientManager already set it up for you, you only need to provide your desired User ID

```swift
import UpstraUIKit
import EkoChat

enum Credentials {
    static let ascApiKey = "YOUR_API_KEY"
    static let userId = "sampleiOSUser"
    static let displayName = UIDevice.current.name
    ...
}
```
File: Managers/ClientManager.swift

4. Join a channel
Before the user can see, send, and receive messages, the user needs to be in a channel first. For this project, you can either specify the channel ID in the **ClientManager.swift** file or pass in the channel ID directly in **LiveStreamViewController.swift**. If you decide to pass in the channel ID directly, be sure to pass that into **initializeRepositories** function in the **ClientManager.swift** file as well.

```swift
// MARK: - Variables
private let messageListManager = MessageListManager(channelId: CHANNEL_ID_HERE)
```
File: LiveStreamViewController.swift

```swift
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
```
File: ClientManager.swift

5. Retrieve messages in a channel
We have setup the project where **MessageListManager.swift** will fetch the messages in **fetchMessages** function.

```swift
func fetchMessages() {
    messagesCollection = messageRepository.messages(withChannelId: channelId, filterByParentId: false, parentId: nil, reverse: true)
    messagesNotificationToken = messagesCollection?.observe { [weak self] (collection, _, error) in
        self?.prepareData(with: collection)
    }
}
```
File: Managers/MessageListManager.swift

LiveStreamViewController will setup everything by using the methods inside the above file. The setup is highly straightforward, please feel free to jump around by looking at its definition.

## UI Modularize

Live Chat UI is divided into three main UI classes as follows: `MessageTableView`, `MessageComposeBarView` and `MessageReplyView`.
Please see image below for further reference.

![image](https://user-images.githubusercontent.com/74768384/118767327-c50dd780-b8a7-11eb-8358-75d277cf1e02.png)

### How to use them
1. Create the view you desire on the storyboard
2. Link the respective view to the class you want to use (Select the view > identity inspector > put the name of the class inside the class input field under custom class)
3. Each class will populate every element, including the constraints automatically to your view on the storyboard

For more example on how you may set this up, please see Main.storyboard and take a look at LiveStreamViewController or SampleViewController.

### Chat message options
1. Send message
2. Reply
3. React
4. Flag/Report
