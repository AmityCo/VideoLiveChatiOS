//
//  VideoHeaderView.swift
//  VideoChatRoom
//
//  Created by Nontapat Siengsanor on 18/5/2564 BE.
//

import UIKit

class VideoHeaderView: UIView {
    
    // MARK: - Variables
    
    private let titleLabel = UILabel()
    private let subtitleLable = UILabel()
    private let shareButton = UIButton()
    
    var shareButtonHandler: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(titleLabel)
        addSubview(subtitleLable)
        addSubview(shareButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .black
        titleLabel.text = "Title"
        
        subtitleLable.translatesAutoresizingMaskIntoConstraints = false
        subtitleLable.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLable.textColor = .black
        subtitleLable.text = "Subtitle"
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.tintColor = .black
        
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            subtitleLable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            subtitleLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLable.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            shareButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 24),
            shareButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    @objc private func shareButtonTapped(_ sender: UIButton) {
        shareButtonHandler?()
    }
    
    // MARK: - Configure
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLable.text = subtitle
    }
    
}
