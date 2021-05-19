import UIKit
import UpstraUIKit
import EkoChat
import MenuItemKit

// Video Player
import AVKit
import AVFoundation
import NotificationCenter

class LiveStreamViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoHeaderView: VideoHeaderView!
    @IBOutlet weak var messageTableView: MessageTableView!
    @IBOutlet weak var messageComposeBarView: MessageComposeBarView!
    @IBOutlet weak var composeBarBottomConstraints: NSLayoutConstraint!
    
    // MARK: - Variables
    private let messageListManager = MessageListManager(channelId: Credentials.liveChannelId)
    private let actionMenuManager = ActionMenuManager()
    
    //MARK: - Video Player Variables
    private var avPlayer: AVPlayer!
    private let playerController = AVPlayerViewController()
    private var playerLayer: AVPlayerLayer!
    private let STATUS_KEY = "status"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayer()
        setupVideoHeaderView()
        setupManager()
        setupTableView()
        setupComposeBarView()
    }
    
    private func setupVideoHeaderView() {
//        videoHeaderView.shareButtonHandler = { [weak self] in
//            let vc = UIActivityViewController(activityItems: ["Watch shows at: www.myapp.example.com"], applicationActivities: nil)
//            vc.popoverPresentationController?.sourceView = self?.view
//
//            self?.present(vc, animated: true, completion: nil)
//        }
        
        // navigate to sample view controller
        videoHeaderView.shareButtonHandler = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let sampleViewController = storyboard.instantiateViewController(identifier: "SampleViewController")
            self?.navigationController?.pushViewController(sampleViewController, animated: true)
        }
    }
    
    private func setupManager() {
        messageListManager.delegate = self
        messageTableView.manager = messageListManager
        messageListManager.fetchMessages()
        
        actionMenuManager.messageComposeBarView = messageComposeBarView
        actionMenuManager.messageListManager = messageListManager
    }
    
    private func setupTableView() {
        messageTableView.actionDelegate = self
        messageTableView.keyboardDismissMode = .onDrag
        KeyboardService.shared.delegate = self
    }
    
    private func setupComposeBarView() {
        messageComposeBarView.delegate = self
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
    
}

extension LiveStreamViewController: MessageTableViewDelegate {
    
    func tableView(_ tableView: MessageTableView, didTapCell cell: UITableViewCell, message: EkoMessageModel) {
        actionMenuManager.showMenuItem(on: cell.contentView, message: message)
    }
    
    func tableViewWillBeginDragging(_ tableView: MessageTableView) {
        actionMenuManager.resetMenuItems()
    }
    
}

extension LiveStreamViewController: KeyboardServiceDelegate {
    
    func keyboardWillChange(service: KeyboardService, height: CGFloat, animationDuration: TimeInterval) {
        actionMenuManager.resetMenuItems()
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

extension LiveStreamViewController: MessageComposeBarViewDelegate {
    
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
