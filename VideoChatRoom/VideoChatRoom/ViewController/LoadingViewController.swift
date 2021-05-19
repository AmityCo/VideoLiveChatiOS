//
//  LoadingViewController.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 8/4/2564 BE.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true // hide navigation bar
        
        ClientManager.shared.setupUpstraUIKit()
        ClientManager.shared.completionHandler = { [weak self] in
            // This block get called after connection completed
            print("EkoClient successfully connected")
            
            // navigate to LiveStreamViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let livewStreamViewController = storyboard.instantiateViewController(identifier: "LiveStreamViewController")
            self?.navigationController?.pushViewController(livewStreamViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingIndicator.stopAnimating()
    }

}
