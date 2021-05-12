import UIKit
import UpstraUIKit
import EkoChat
import MenuItemKit

// Video Player
import AVKit
import AVFoundation
import NotificationCenter

class LiveStreamViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: MessageTableView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var composeBarBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var replyCloseButton: UIButton!
    @IBOutlet weak var replyAvatarImageView: UIImageView!
    @IBOutlet weak var replyDisplaynameLabel: UILabel!
    @IBOutlet weak var replyContentLabel: UILabel!
    @IBOutlet weak var replyContainerView: UIView!
    
    // MARK: - Variables
    private let messageListManager = MessageListManager(channelId: Credentials.liveChannelId)
    private var parentMessage: EkoMessageModel?
    private var referenceFrame: CGRect?
    
    //MARK: - Video Player Variables
    private var avPlayer: AVPlayer!
    private let playerController = AVPlayerViewController()
    private var playerLayer: AVPlayerLayer!
    private let STATUS_KEY = "status"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replyContainerView.isHidden = true
        setupPlayer()
        setupManager()
        setupTableView()
        
        textField.delegate = self
    }
    
    private func setupManager() {
        messageListManager.delegate = self
        messageTableView.manager = messageListManager
        messageListManager.fetchMessages()
    }
    
    private func setupTableView() {
        messageTableView.actionDelegate = self
        messageTableView.keyboardDismissMode = .onDrag
        KeyboardService.shared.delegate = self
    }
    
    @IBAction func sendMessageTapped(_ sender: Any) {
        let newMessage = textField.text ?? ""
        messageListManager.sendMessage(withText: newMessage, withParentId: parentMessage?.messageId)
        textField.text = ""
        replyContainerView.isHidden = true
        parentMessage = nil
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let vc = UIActivityViewController(activityItems: ["Watch shows at: www.myapp.example.com"], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
                
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePlayerFrame()
        playVideo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.updatePlayerFrame()
        }
    }
    
    //MARK: - Video Player Section
    
    private func setupPlayer() {
        // setup AVPlayer
        avPlayer = AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!)
        
        // setup AVPlayerLayer
        playerLayer = AVPlayerLayer(player:avPlayer)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = videoView.bounds
        
        // add player to view
        videoView.layer.addSublayer(playerLayer)
    }
    
    private func updatePlayerFrame() {
        playerLayer.frame = videoView.bounds
    }
    
    private func playVideo() {
        avPlayer.play()
        avPlayer.seek(to:CMTimeMakeWithSeconds(0.0,preferredTimescale: .max))
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        avPlayer.addObserver(self, forKeyPath: STATUS_KEY, options: .new, context: nil)
    }

    private func removePlayer() {
        avPlayer.pause()
        avPlayer.removeObserver(self, forKeyPath: STATUS_KEY)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        playerLayer.removeFromSuperlayer()
    }

    @objc func playerDidFinishPlaying() {
        avPlayer.seek(to:CMTimeMakeWithSeconds(0.0,preferredTimescale: .max))
        self.avPlayer.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath?.elementsEqual(STATUS_KEY))! && self.avPlayer.status == AVPlayer.Status.readyToPlay {
            self.avPlayer.play()
        }
    }
    
    @IBAction func replyCloseButtonTapped(_ sender: Any) {
        configureReplyView(with: nil)
    }
    
    // MARK: - Action Menu
    
    private func showMenuItem(on view: UIView, message: EkoMessageModel) {
        textField.resignFirstResponder()
        let controller = UIMenuController.shared
        
        guard controller.menuItems == nil else {
            // if `menuItems` exists, hide it.
            resetMenuItems()
            return
        }
        
        var menuItems: [UIMenuItem] = []
        
        let reactionTypes: [ReactionType] = [.heart, .smile, .joy, .love, .fire]
        for reactionType in reactionTypes {
            let reactionItem = UIMenuItem(title: reactionType.title) { [weak self] _ in
                self?.messageListManager.react(message: message, with: reactionType)
                self?.resetMenuItems()
            }
            menuItems.append(reactionItem)
        }
        let replyItem = UIMenuItem(title: "Reply") { [weak self] _ in
            self?.configureReplyView(with: message)
            self?.resetMenuItems()
        }
        let reportItem = UIMenuItem(title: "Report") { [weak self] _ in
            self?.messageListManager.report(message: message)
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
    
    private func resetMenuItems() {
        // In order to support menu dismissing on focused cell,
        // we need clear `menuItems` whenever user interacts with other view.
        UIMenuController.shared.menuItems = nil
    }
    
    private func configureReplyView(with message: EkoMessageModel?) {
        parentMessage = message
        if let message = message {
            replyDisplaynameLabel.text = message.displayName
            replyContentLabel.text = message.text
            replyContainerView.isHidden = false
        } else {
            replyContainerView.isHidden = true
        }
    }
    
}

extension LiveStreamViewController: MessageTableViewDelegate {
    
    func tableView(_ tableView: MessageTableView, didTapCell cell: UITableViewCell, message: EkoMessageModel) {
        showMenuItem(on: cell.contentView, message: message)
    }
    
    func tableViewWillBeginDragging(_ tableView: MessageTableView) {
        resetMenuItems()
    }
    
}

extension LiveStreamViewController: KeyboardServiceDelegate {
    
    func keyboardWillChange(service: KeyboardService, height: CGFloat, animationDuration: TimeInterval) {
        resetMenuItems()
        composeBarBottomConstraints.constant = height
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }
    
}

extension LiveStreamViewController: MessageListManagerDelegate {
    
    func manager(_ manager: MessageListManager, didReceiveMessages: [EkoMessageModel]) {
        messageTableView.reloadData()
    }
    
    func manager(_ manager: MessageListManager, didCreateMessageSuccess message: EkoMessageModel) {
        messageTableView.reloadData()
    }
    
    func manager(_ manager: MessageListManager, didCreateMessageFailWithError error: Error?) {
        // send message failure
    }
    
}

extension LiveStreamViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetMenuItems()
    }
    
}
