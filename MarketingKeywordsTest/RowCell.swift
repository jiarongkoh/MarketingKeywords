//
//  RowCell.swift
//  MarketingKeywordsTest
//
//  Created by Koh Jia Rong on 2019/7/3.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit

class RowCell: UITableViewCell {
    
    let subjectLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.numberOfLines = 0
        return l
    }()
    
    let senderLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let isPrimaryLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let detectedAsPrimaryLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.textAlignment = .right
        l.textColor = .darkGray
        l.numberOfLines = 0
        return l
    }()
    
    var message: Message? {
        didSet {
            guard let message = message else {return}
            
            let isPrimary = message.isPrimary ?? true
            let detectedAsPrimary = message.detectedAsPrimary ?? true
            
            subjectLabel.text = message.subject ?? ""
            senderLabel.text = message.sender ?? ""
            isPrimaryLabel.text = isPrimary ? "Primary" : "Others"
            detectedAsPrimaryLabel.text = detectedAsPrimary ? "Primary" : "Others"
            
            if isPrimary == false && isPrimary != detectedAsPrimary {
                backgroundColor = .yellow
            } else if isPrimary == true && isPrimary != detectedAsPrimary {
                backgroundColor = .red
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [
            subjectLabel,
            senderLabel,
            isPrimaryLabel
            ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        addSubview(detectedAsPrimaryLabel)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stackView.trailingAnchor.constraint(equalTo: detectedAsPrimaryLabel.leadingAnchor, constant: 0),
            
            detectedAsPrimaryLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0),
            detectedAsPrimaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            detectedAsPrimaryLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),
            detectedAsPrimaryLabel.widthAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
