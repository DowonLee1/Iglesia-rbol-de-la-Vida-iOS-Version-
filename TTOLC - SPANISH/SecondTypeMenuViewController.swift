//
//  SecondTypeMenuViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import UIKit
import AudioToolbox
import MessageUI
import Firebase
import AVFoundation
import AVKit

class SecondTypeMenuViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var paddingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var secondActionButton: UIButton!
    @IBOutlet weak var textViewLabel: UITextView!
    @IBOutlet weak var shareButtonImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    var ref: DatabaseReference!
    
    var passedSectionTitle = ""
    var passedImage2Url = ""
    var passedImage3Url = ""
    var passedMainMenu = [MainMenu]()
    var navBackground = UIView()
    var statusBackground = UIView()
    var animationView = UIView()
    var shareButtonUrl = ""
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    var latitude = NSNumber()
    var longitude = NSNumber()
    var mapTitle = ""
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetUp()
        initialAnimation()
        changbleObjects()
        if passedSectionTitle == "MISIONERO" {
            missionaryVideoSetup()
        }
    }
    
    private func missionaryVideoSetup() {
        centerImage.frame.size.height = (image.frame.size.width / 16) * 9
        centerImage.center.y = image.center.y + 2
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "missionary", ofType: "mp4")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = centerImage.bounds
        centerImage.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(SecondTypeMenuViewController.videoDidPlayToEnd(_:)), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }

    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero)
    }
    
    private func changbleObjects() {
        if passedSectionTitle == "EVENTO" {
            titleLabel.text = passedSectionTitle
            subTitleLabel.text = "POR LA IGLESIA DEL ÁRBOL DE LA VIDA"
            actionButton.setTitle("CONTÁCTENOS", for: .normal)
            secondActionButton.alpha = 1
            secondActionButton.setTitle("DIRECCIÓN", for: .normal)
            
            // taking description text from server
            ref = Database.database().reference().child("eventDescription").child("description")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
        }
        else if passedSectionTitle == "SOBRE NOSOTROS" {
            titleLabel.text = "SOBRE NOSOTROS"
            subTitleLabel.text = "LA IGLESIA DEL ÁRBOL DE LA VIDA"
            actionButton.setTitle("CONTÁCTENOS", for: .normal)
            secondActionButton.alpha = 1
            secondActionButton.setTitle("INFORMACIÓN", for: .normal)
            
            // taking description text from server
            ref = Database.database().reference().child("aboutUsDescription").child("description")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
        }
        else if passedSectionTitle == "MISIONERO" {
            titleLabel.text = "MISIONERO"
            subTitleLabel.text = "POR LA IGLESIA DEL ÁRBOL DE LA VIDA"
            actionButton.setTitle("CONTÁCTENOS", for: .normal)
            secondActionButton.alpha = 1
            secondActionButton.setTitle("VIDEO MISIONERO", for: .normal)
            
            // taking description text from server
            ref = Database.database().reference().child("missionaryDescription").child("description")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
        }
        else if passedSectionTitle == "HISTORIA DE LA REDENCIÓN" {
            titleLabel.text = "LIBRO HISTORIA DE LA SERIE DE REDENCIÓN"
            subTitleLabel.text = "POR REV. DR. ABRAHAM PARK"
            actionButton.setTitle("LIBROS", for: .normal)
            secondActionButton.alpha = 1
            secondActionButton.setTitle("INFORMACIÓN", for: .normal)
            
            // taking description text from server
            ref = Database.database().reference().child("historyOfRedemptionDescription").child("description")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
        }
    }
    
    private func initialAnimation() {
        scrollView.alpha = 0
        image.alpha = 0
        image.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 1.2) {
            self.image.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.image.alpha = 1
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.5 ,animations: {
            self.animationView.alpha = 0
            self.scrollView.alpha = 1
        })
    }
    
    private func layoutSetUp() {
        
        
        
        animationView.frame.size.width = view.frame.size.width
        animationView.frame.size.height = view.frame.size.height
        animationView.backgroundColor = .white
        view.addSubview(animationView)
        
        let url = URL(string: "https://drive.google.com/uc?export=view&id=\(passedImage2Url)")
        image.loadImage(from: url!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight).isActive = true
        image.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        image.heightAnchor.constraint(equalToConstant: CGFloat(Int(view.frame.size.height / 1.28))).isActive = true
        
        shareButtonImage.frame.size.height = 14
        shareButtonImage.frame.size.width = 13
        shareButton.center = shareButtonImage.center
        shareButton.frame.size.height = 30
        shareButton.frame.size.width = 30
        
        let navBarHeight = statusBarHeight +
           (navigationController?.navigationBar.frame.height ?? 0.0)
        actionButton.layer.borderWidth = 0.7
        actionButton.layer.borderColor = UIColor.black.cgColor
        secondActionButton.layer.borderWidth = 0.7
        secondActionButton.alpha = 0
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // if screen ratio is 16:9
        if view.frame.size.height <= view.frame.size.width * 2{
            print("screen ratio is 16:9 as iphone 8")
            scrollView.contentSize = CGSize(width: view.frame.size.width, height: paddingView.frame.size.height + contentView.frame.size.height - navBarHeight + ((statusBarHeight) * 3))
        }
        // if screen ratio is 21:9
        else if view.frame.size.height >= view.frame.size.width * 2{
            print("screen ratio is 21:9 as iphone x")
            scrollView.contentSize = CGSize(width: view.frame.size.width, height: paddingView.frame.size.height + contentView.frame.size.height - navBarHeight + ((statusBarHeight / 5) * 2))
        }
        scrollView.delegate = self
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.heightAnchor.constraint(equalToConstant: CGFloat(scrollView.frame.size.height)).isActive = true
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: paddingView.bottomAnchor).isActive = true
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowColor = UIColor.black.cgColor
        
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        paddingView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        paddingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paddingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paddingView.heightAnchor.constraint(equalToConstant: CGFloat(view.frame.size.height / 1.628)).isActive = true
        
        textViewLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor , constant: 10).isActive = true
        textViewLabel.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor).isActive = true
        textViewLabel.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor).isActive = true
        textViewLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        navBackground.backgroundColor = .white
        navBackground.frame.size.width = view.frame.size.width
        navBackground.frame.size.height = navBarHeight
        navBackground.alpha = 0
        view.addSubview(navBackground)
        
        statusBackground.backgroundColor = .white
        statusBackground.frame.size.width = view.frame.size.width
        statusBackground.frame.size.height = statusBarHeight
        view.addSubview(statusBackground)
    }
    
    @IBAction func actionButtonClicked(_ sender: UIButton) {
        if passedSectionTitle != "HISTORIA DE LA REDENCIÓN" {
            if !MFMailComposeViewController.canSendMail() {
                actionButton.shake()
            }
            sendEmail()
            AudioServicesPlaySystemSound(1519)
        }
        else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
            AudioServicesPlaySystemSound(1519)
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func secondActionButtonClicked(_ sender: UIButton) {
        if passedSectionTitle == "MISIONERO" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SectionTableViewController") as? SectionTableViewController
            vc?.passedParentSection = "seminarSection"
            AudioServicesPlaySystemSound(1519)
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if passedSectionTitle == "EVENTO" {
            AudioServicesPlaySystemSound(1519)
            let url = URL(string: "maps://?q=\(mapTitle)&ll=\(latitude),\(longitude)")!
            if (latitude == nil) || (longitude == nil) {
                let alert = UIAlertController(title: "No hay dirección para este evento", message: nil, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Hecho", style: UIAlertAction.Style.default, handler: {_ in
                }))
            alert.view.tintColor = UIColor.black
            self.present(alert, animated: true, completion: nil)
            }
            else if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            
        }
        else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else {
                return
            }
            vc.passedSectionTitle = passedSectionTitle
            vc.passedImage3Url = passedImage3Url
            AudioServicesPlaySystemSound(1519)
            present(vc, animated: true)
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        if passedSectionTitle == "SOBRE NOSOTROS" {
            shareButtonUrl = "http://nytreeoflife.com/"
        }
        if passedSectionTitle == "MISIONERO" {
            shareButtonUrl = "http://nytreeoflife.com/missions-2/"
        }
        if passedSectionTitle == "HISTORIA DE LA REDENCIÓN" {
            shareButtonUrl = "http://horaministries.com/about-the-books/"
        }
        if passedSectionTitle == "EVENTO" {
            shareButtonUrl = "https://drive.google.com/uc?export=view&id=\(passedImage2Url)"
        }
        let items = [shareButtonUrl]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        AudioServicesPlaySystemSound(1519)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alpha: CGFloat = abs(1 - ((scrollView.contentOffset.y + paddingView.frame.size.height) / paddingView.frame.size.height))
        let fade: CGFloat = abs(2 - ((scrollView.contentOffset.y + paddingView.frame.size.height) / paddingView.frame.size.height))
        image.transform = CGAffineTransform(scaleX: 0.8 + ((fade / 10) * 2), y: 0.8 + ((fade / 10) * 2))
        navBackground.alpha = alpha
        if (alpha >= 0.99 && alpha <= 1.00) || (alpha == 0) {
            AudioServicesPlaySystemSound(1519)
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info.ttolc@gmail.com"])
            mail.setSubject("Pedido")
            mail.setMessageBody("Hola iglesia árbol de la vida, ", isHTML: true)

            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Configure su correo electrónico en la aplicación de correo", message: nil, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Hecho", style: UIAlertAction.Style.default, handler: nil))
            alert.view.tintColor = UIColor.black
            present(alert, animated: true, completion: nil)
        }
    }

    private func mailComposeController(controller: MFMailComposeViewController,
                           didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SecondTypeMenuViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
}

