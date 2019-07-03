//
//  ViewController.swift
//  MarketingKeywordsTest
//
//  Created by Koh Jia Rong on 2019/7/2.
//  Copyright © 2019 Koh Jia Rong. All rights reserved.
//

import UIKit

struct Message: Decodable, Hashable {
    var sender: String?
    var subject: String?
    var bodyText: String?
    var isPrimary: Bool?
    var detectedAsPrimary: Bool?
}

class ViewController: UITableViewController {

    var allMessages = [Message]()
    var filteredMessages = [Message]()
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.insertSegment(withTitle: "All", at: 0, animated: false)
        sc.insertSegment(withTitle: "Yellow", at: 1, animated: false)
        sc.insertSegment(withTitle: "Red", at: 2, animated: false)
        sc.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentedControl)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select Sample", style: .plain, target: self, action: #selector(selectSampleEmails))
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(RowCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    //Extract messages from plist
    func getMessagesFromPropertyList(name: String) -> [Message]? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "plist") else {
            print("Error parsing plist")
            return nil
        }
        
        if let results = NSDictionary(contentsOf: url) {
            var messages = [Message]()
            
            results.forEach { (result) in
                let dictionary = result.value as? [String: AnyObject]
                let subject = dictionary?["subject"] as? String
                let sender = dictionary?["sender"] as? String
                let bodyText = dictionary?["bodyText"] as? String
                let isPrimary = dictionary?["isPrimary"] as? Bool
                
                let message = Message(sender: sender, subject: subject, bodyText: bodyText, isPrimary: isPrimary, detectedAsPrimary: nil)
                messages.append(message)
            }
            
            print("\(messages.count) messages extracted from plist.")
            return messages
        }
        
        return nil
    }
    
    ///Detect marketing related keywords inside subject line and sender address
    func extractKeywords(messages: [Message]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //TODO: Organisational emails + sift + unsubscribed
            //EdoSiftMapping
            //EdoContactItem sentToCount sentToFrequency
                        
            ///Extraction from subject line
            
            //Example: Sales, Deals, Exclusive etc
            let salePattern = "(sale(s)?|exclusive|save|buy|discount(s)?|free\\b|order|early bird|voucher|don't miss|don't forget|win\\b|promotion|offer)"
            
            //Example: 10% off
            let discountPattern = "[0-9]{1,3}%( off)?"
            
            //Example: $10.9, $100, $100.90
            let pricePattern = "\\$[0-9]+(.)?[0-9]{0,2}"
            
            let mediaPattern = "(breaking|review|top stories|news)"
            let bookingPattern = "(booking(s)?|reserv[a-z]+|receipt(s)?)"
            let eventPattern = "(event(s)?|exhibition|expo|agenda|conference|attend|bulletin|webinar)"
            
            let patternsForSubjectLine = [salePattern,
                                          pricePattern,
                                          discountPattern,
                                          bookingPattern,
                                          eventPattern,
                                          mediaPattern]
            
            ///Extraction from sender emails
            
            //Example: automated@airbnb.com, offers@airline.com, newsletter@techcrunch.com
            let senderPattern = "(promotion(s)?|automated|offer(s)?|deal(s)?|marketing|news[a-z]+)"
            
            let patternsForSender = [senderPattern]
            
            ///Extraction from bodyText
            
            //Search for the words "unsubscribe"
            //TODO: Use header
            let unsubscribePattern = "unsubscribe(d)?"
            let patternsForBodyText = [unsubscribePattern]
            
            var matchedCount = 0
            
            ///Extraction using regex
            messages.forEach { (message) in
                var matches = [String]()
                let subject = message.subject ?? ""
                let sender = message.sender ?? ""
                let bodyText = message.bodyText ?? ""
                
                //Extract from subject line
                patternsForSubjectLine.forEach({ (pattern) in
                    let match = self.listMatches(for: pattern, inString: subject)
                    matches += match
                })

                //Extract from sender
                patternsForSender.forEach({ (pattern) in
                    let match = self.listMatches(for: pattern, inString: sender)
                    matches += match
                })
                
                //Extract from BodyText
                patternsForBodyText.forEach({ (pattern) in
                    let match = self.listMatches(for: pattern, inString: bodyText)
                    matches += match
                })
                
                print("========")
                //            print(sender)
                print(subject)
                //            print(message.bodyText ?? "")
                print(matches)
                
                if !matches.isEmpty {
                    //If there are matches, message IS NOT a primary message
                    let newMessage = Message(sender: message.sender, subject: message.subject, bodyText: message.bodyText, isPrimary: message.isPrimary, detectedAsPrimary: false)
                    self.allMessages.append(newMessage)
                    matchedCount += 1
                } else {
                    //If there are no matches, message IS a primary message
                    let newMessage = Message(sender: message.sender, subject: message.subject, bodyText: message.bodyText, isPrimary: message.isPrimary, detectedAsPrimary: true)
                    self.allMessages.append(newMessage)
                }
            }
            
            DispatchQueue.main.async {
                self.filteredMessages = self.allMessages
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func selectSampleEmails() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edisonAction = UIAlertAction(title: "Edison", style: .default) { (_) in
            self.navigationItem.title = "Edison"
            
            let plistName = "sample4"
            self.prepare(plistName: plistName)
        }
        
        let personal1Action = UIAlertAction(title: "Personal 1", style: .default) { (_) in
            self.navigationItem.title = "Personal 1"

            let plistName = "sample"
            self.prepare(plistName: plistName)
        }
        
        let personal2Action = UIAlertAction(title: "Personal 2", style: .default) { (_) in
            self.navigationItem.title = "Personal 2"
            
            let plistName = "sample3"
            self.prepare(plistName: plistName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [edisonAction,
         personal1Action,
         personal2Action,
         cancelAction].forEach { (action) in
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func prepare(plistName: String) {
        self.allMessages.removeAll()
        self.filteredMessages.removeAll()
        
        let emailMessages = self.getMessagesFromPropertyList(name: plistName) ?? []
        self.extractKeywords(messages: emailMessages)
    }
    
    @objc func segmentedControlDidChange(_ segmentedControl: UISegmentedControl) {
        filteredMessages.removeAll()

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            //Show all messages
            filteredMessages = allMessages
        case 1:
            //Show yellow messages.
            //Messages that are 'Others', but wrongly detected as 'Primary'
            filteredMessages = allMessages.filter({ (message) -> Bool in
                let isPrimary = message.isPrimary ?? true
                let detectedAsPrimary = message.detectedAsPrimary ?? true
                
                if isPrimary == false && isPrimary != detectedAsPrimary {
                    return true
                }
                return false
            })
        default:
            //Show red messages.
            //Messages that are 'Primary', but wrongly detected as 'Others'
            filteredMessages = allMessages.filter({ (message) -> Bool in
                let isPrimary = message.isPrimary ?? true
                let detectedAsPrimary = message.detectedAsPrimary ?? true

                if isPrimary == true && isPrimary != detectedAsPrimary {
                    return true
                }
                return false
            })
        }
        
        tableView.reloadData()
    }
    
    //MARK:- TableView
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let allMessagesCount = allMessages.count
        let isPrimaryCount = allMessages.filter({$0.isPrimary ?? false}).count
//        let detectedAsPrimaryCount = allMessages.filter({$0.detectedAsPrimary ?? false}).count
        
        let correctlyDetectedAsPrimary = allMessages.filter { (message) -> Bool in
            let isPrimary = message.isPrimary ?? true
            if isPrimary == true {
                return isPrimary == message.detectedAsPrimary ?? true
            }
            return false
        }
        
        let correctlyDetectedAsOthers = allMessages.filter { (message) -> Bool in
            let isPrimary = message.isPrimary ?? true
            if isPrimary == false {
                return isPrimary == message.detectedAsPrimary ?? true
            }
            return false
        }

        let manualTitleLabel = UILabel()
        manualTitleLabel.text = "Messages Classification:"
        manualTitleLabel.font =  UIFont.systemFont(ofSize: 20, weight: .medium)
        
        let manualTextLabel = UILabel()
        manualTextLabel.text = "Total messages: \(allMessagesCount) \nisPrimary: \(isPrimaryCount)\nisOthers: \(allMessagesCount - isPrimaryCount)"
        manualTextLabel.numberOfLines = 0
        
        let detectedTitleLabel = UILabel()
        detectedTitleLabel.text = "Detection Results:"
        detectedTitleLabel.font =  UIFont.systemFont(ofSize: 20, weight: .medium)
        
        let detectedTextLabel = UILabel()
        detectedTextLabel.text = "Correctly detected as Primary: \(correctlyDetectedAsPrimary.count)\nCorrectly detected as Others: \(correctlyDetectedAsOthers.count)"
        detectedTextLabel.numberOfLines = 0
        
        let notesLabel = UILabel()
        notesLabel.text = "\nCells highlighted in yellow refers to messages that are classified as 'Others' but wrongly detected as 'Primary'. \n\nCells highlighted in red refers to messages that are classified as 'Primary' but wrongly detected as 'Others'"
        notesLabel.numberOfLines = 0
        notesLabel.textColor = .darkGray
        
        let stackView = UIStackView(arrangedSubviews: [manualTitleLabel, manualTextLabel, detectedTitleLabel, detectedTextLabel, notesLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RowCell
        cell.message = filteredMessages[indexPath.row]
        return cell
    }
    
    //MARK:- Helper
    
    func listMatches(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        return matches.map {
            let range = Range($0.range, in: string)!
            return String(string[range])
        }
    }
}

