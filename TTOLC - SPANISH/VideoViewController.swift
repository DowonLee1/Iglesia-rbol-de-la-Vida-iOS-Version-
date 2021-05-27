//
//  VideoViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import UIKit
import CoreData
import youtube_ios_player_helper
import AudioToolbox
import MediaPlayer
import SafariServices

class VideoViewController: UIViewController, YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shareButtonImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bibleVerseLabel: UILabel!
    @IBOutlet weak var pastorNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var offeringButton: UIButton!
    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var nextVideoTable: UITableView!
    @IBOutlet weak var nextVideoTableTitleLabel: UILabel!
    
    let notification = UINotificationFeedbackGenerator()
    
    var passedCaption = ""
    var passedBibleVerse = ""
    var passedPastorName = ""
    var passedDate = ""
    var passedUrl = ""
    var counter = 0
    var passedIndex = 0
    var passedPost = [Post]()
    var keyboardOn = false
    var toggleSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetUp()
        
//        MPVolumeView.setVolume(0.7)
    }

    private func layoutSetUp() {
        // for better touch response, separate image and button then make button size bigger than image.
        if view.frame.size.height <= view.frame.size.width * 2{
            print("screen ratio is 16:9 as iphone 8")
            shareButtonImage.frame.size.height = 12
            shareButtonImage.frame.size.width = 13
        }
        // 21:9 DISPLAY SCALE FRAME WORK
        else if view.frame.size.height >= view.frame.size.width * 2{
            print("screen ratio is 21:9 as iphone x")
            shareButtonImage.frame.size.height = 13
            shareButtonImage.frame.size.width = 13
        }
        shareButton.center = shareButtonImage.center
        shareButton.frame.size.height = 30
        shareButton.frame.size.width = 30
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.topAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        detailView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        detailView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        offeringButton.layer.cornerRadius = 5
        offeringButton.translatesAutoresizingMaskIntoConstraints = false
        offeringButton.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        offeringButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 17).isActive = true
        offeringButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -17).isActive = true
        offeringButton.heightAnchor.constraint(equalToConstant: (offeringButton.frame.size.width / 7.6)).isActive = true
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        videoView.delegate = self
        videoView.frame.size.width = screenWidth
        videoView.frame.size.height = CGFloat((screenWidth / 16) * 9.6)
        videoView.load(withVideoId: passedUrl, playerVars: ["playsinline": 1])
        
        nextVideoTable.delegate = self
        nextVideoTable.dataSource = self
        
        nextVideoTableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nextVideoTableTitleLabel.topAnchor.constraint(equalTo: offeringButton.bottomAnchor, constant: 10).isActive = true
        nextVideoTableTitleLabel.heightAnchor.constraint(equalToConstant: offeringButton.frame.size.height).isActive = true
        nextVideoTableTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextVideoTableTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        nextVideoTable.translatesAutoresizingMaskIntoConstraints = false
        nextVideoTable.topAnchor.constraint(equalTo: nextVideoTableTitleLabel.bottomAnchor).isActive = true
        nextVideoTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        nextVideoTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextVideoTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nextVideoTable.insertRows(at: [IndexPath(row: self.passedPost.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
        
        titleLabel.text = passedCaption
        bibleVerseLabel.text = passedBibleVerse
        pastorNameLabel.text = passedPastorName
        dateLabel.text = passedDate
        
        // CHECK THE LABEL LINE FOR PROPER LAYOUT
        if countLabelLines(label: titleLabel) == 2 {
            bibleVerseLabel.text = ""
        }
        else {
            titleLabel.text = passedCaption + "\n"
        }
        
        while (counter < passedIndex + 1) {
            passedPost.remove(at: 0)
            counter += 1
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if passedPost.count > 10 {
            return 10
        }
        else {
            return passedPost.count
        }
        
    }
    
    func countLabelLines(label: UILabel) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = label.text! as NSString

        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = nextVideoTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomVideoViewCell
        let url = URL(string: "https://drive.google.com/uc?export=view&id=\(passedPost[indexPath.row].imageUrl)")
        cell.thumbnailImage.loadImage(from: url!)
        cell.titleLabel.text = passedPost[indexPath.row].title
        cell.bibleVerseLabel.text = passedPost[indexPath.row].bibleVerse
        cell.pastorNameLabel.text = passedPost[indexPath.row].pastorName
        cell.dateLabel.text = passedPost[indexPath.row].date
        
        // check the label line for proper layout
        if countLabelLines(label: cell.titleLabel) == 2 {
            cell.bibleVerseLabel.text = ""
        }
        else {
            cell.titleLabel.text = passedPost[indexPath.row].title + "\n"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        videoView.load(withVideoId: passedPost[indexPath.row].url, playerVars: ["playsinline": 1])
        passedUrl = passedPost[indexPath.row].url
        titleLabel.text = passedPost[indexPath.row].title
        bibleVerseLabel.text = passedPost[indexPath.row].bibleVerse
        pastorNameLabel.text = passedPost[indexPath.row].pastorName
        dateLabel.text = passedPost[indexPath.row].date
        
        // check the label line for proper layout
        if countLabelLines(label: titleLabel) == 2 {
            bibleVerseLabel.text = ""
        }
        else {
            titleLabel.text = passedPost[indexPath.row].title + "\n"
        }
        
        dateLabel.textColor = .black
        AudioServicesPlaySystemSound(1519)
    
        self.nextVideoTableTitleLabel.alpha = 0
        self.detailView.alpha = 0
        self.offeringButton.alpha = 0
        self.nextVideoTable.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            self.nextVideoTableTitleLabel.alpha = 1
            self.detailView.alpha = 1
            self.offeringButton.alpha = 1
            self.nextVideoTable.alpha = 1
        }
        counter = 0
        while (counter < indexPath.row + 1) {
            passedPost.remove(at: 0)
            counter += 1
        }
        nextVideoTable.reloadData()
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        AudioServicesPlaySystemSound(1519)
        videoView.playVideo()
    }
    
    // check the live status
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        playerView.duration { (duration, error) in
            print("time: \(playTime) duration: \(duration)")
            if (duration == 0.0 || duration == 15.0){
                if self.toggleSwitch == false {
                    self.dateLabel.text = "LIVE STREAMING"
                    self.dateLabel.textColor = UIColor(red: 225/255, green: 0/255, blue: 0/255, alpha: 1.0)
                    self.dateLabel.alpha = 0
                    UIView.animate(withDuration: 1) {
                        self.dateLabel.alpha = 1
                    }
                    self.toggleSwitch = true
                }
            }
            else {
//                print("It is not live")
            }
        }
    }
    
    @IBAction func offeringButtonClicked(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        if let url = URL(string: "https://donorbox.org/iglesia-arbol-de-la-vida") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        let items = ["https://www.youtube.com/watch?v=\(passedUrl)"]
        AudioServicesPlaySystemSound(1519)
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}
