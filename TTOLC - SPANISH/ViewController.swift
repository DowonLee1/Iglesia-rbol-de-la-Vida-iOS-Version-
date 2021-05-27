//
//  ViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/26/21.
//

import UIKit
import AudioToolbox
import Firebase
import AVFoundation
import AVKit
import SafariServices

class ViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var sectionTable: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sermonButton: UIButton!
    @IBOutlet weak var underBar: UIView!
    @IBOutlet weak var upperBar: UIView!
    @IBOutlet weak var upperLabel1: UILabel!
    @IBOutlet weak var upperLabel2: UILabel!
    @IBOutlet weak var upperLabel3: UILabel!
    @IBOutlet weak var upperButton1: UIButton!
    @IBOutlet weak var upperButton2: UIButton!
    @IBOutlet weak var upperButton3: UIButton!
    @IBOutlet weak var upperButtonBar: UIView!
    
    var mainMenu = [MainMenu]()
    var ref: DatabaseReference!
    let currentVersion = "v1.5"
    var bottom = UIView()
    let spinner = UIActivityIndicatorView(style: .gray)
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    let notification = UINotificationFeedbackGenerator()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetUp()
        checkLatestVersion()
        loadMainMenu()
        // Do any additional setup after loading the view.
    }

    // LATEST VERSION CHECK
    func checkLatestVersion() {
        ref = Database.database().reference().child("currentVersion")
        ref.observe(DataEventType.childAdded, with: { [self](snapshot) in
                print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let latestVersionString = dict["latestVersion"] as! String
                    let appStoreIdString = dict["appStoreId"] as! String
                    // The alert keeps popping up until the latest version is installed
                    if currentVersion != latestVersionString  {
                        self.mainView.alpha = 0
                        let alert = UIAlertController(title: "A new version has been released so please update it", message: nil, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: {_ in
                            let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id" + appStoreIdString)
                            if UIApplication.shared.canOpenURL(url! as URL) == true  {
                                UIApplication.shared.open(url! as URL)
                            }
                        }))
                    alert.view.tintColor = UIColor.black
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    // DOWNLOAD DATA FROM SERVER
    func loadMainMenu() {
            ref = Database.database().reference().child("mainMenu")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
                print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let titleString = dict["title"] as! String
                    let imageUrlString = dict["imageUrl"] as! String
                    let image2UrlString = dict["image2Url"] as! String
                    let image3UrlString = dict["image3Url"] as! String
                    let menu = MainMenu(titleString: titleString, imageUrlString: imageUrlString, image2UrlString: image2UrlString, image3UrlString: image3UrlString)
                    self.mainMenu.append(menu)
                    self.sectionTable.insertRows(at: [IndexPath(row: self.mainMenu.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
                    self.spinner.stopAnimating()
                }
            })
        }
    
    // LAYOUT SETUP
    private func layoutSetUp() {
        // TABLEVEIW PROPERTY
        sectionTable.dataSource = self
        sectionTable.delegate = self
        sectionTable.refreshControl = refresher
        spinner.startAnimating()
        sectionTable.backgroundView = spinner
        
        // PAGE CONTROL
        pageControl.transform = pageControl.transform.rotated(by: .pi/2)
        pageControl.numberOfPages = 3
        
        // 16:9 DISPLAY SCALE FRAME WORK
        if view.frame.size.height <= view.frame.size.width * 2{
            print("screen ratio is 16:9 as iphone 8")
            underBar.translatesAutoresizingMaskIntoConstraints = false
            underBar.heightAnchor.constraint(equalToConstant: underBar.frame.size.height).isActive = true
            underBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            underBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            underBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            sectionTable.translatesAutoresizingMaskIntoConstraints = false
            sectionTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sectionTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sectionTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sectionTable.bottomAnchor.constraint(equalTo: underBar.topAnchor).isActive = true
        }
        // 21:9 DISPLAY SCALE FRAME WORK
        else if view.frame.size.height >= view.frame.size.width * 2{
            print("screen ratio is 21:9 as iphone x")
            sectionTable.translatesAutoresizingMaskIntoConstraints = false
            sectionTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sectionTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sectionTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sectionTable.bottomAnchor.constraint(equalTo: underBar.topAnchor).isActive = true
            
            underBar.addSubview(bottom)
            bottom.backgroundColor = .white
            bottom.translatesAutoresizingMaskIntoConstraints = false
            bottom.topAnchor.constraint(equalTo: underBar.bottomAnchor).isActive = true
            bottom.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bottom.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bottom.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        // NAVIGATION PROPERTY
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.tintColor = .black
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "GillSans-SemiBold", size: 16)!]
        
        // UNDER BAR PROPERTY
        underBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        underBar.layer.shadowOpacity = 0.2
        underBar.layer.shadowColor = UIColor.black.cgColor
        
        // UPPER BAR FRAME WORK
        upperLabel1.sizeToFit()
        upperLabel1.text = ""
        upperButton1.setTitle("EVENTO", for: .normal)
        upperLabel1.center = upperButton1.center
        
        upperLabel2.sizeToFit()
        upperLabel2.center = upperButton2.center
        
        upperLabel3.sizeToFit()
        upperLabel3.center = upperButton3.center
        upperButtonBar.frame.size.width = upperLabel1.frame.size.width + 5
        upperButtonBar.frame.size.height = 3
        upperButtonBar.center.y = upperLabel1.center.y + (upperButton1.frame.size.height / 3)
        upperButtonBar.center.x = upperLabel1.center.x
    }
    
    // REFRESHER PROPERTY
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func requestData() {
        self.sectionTable.reloadData()
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    // UPPER BAR BUTTON
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = sectionTable.contentOffset.y / sectionTable.frame.height
        if page == 0 {
            UIView.animate(withDuration: 0.2) {
                self.upperLabel1.text = ""
                self.upperButton1.setTitle("EVENTO", for: .normal)
                self.upperLabel2.text = "SOBRE NOSOTROS"
                self.upperLabel3.text = "LIBRO H.O.R"
                self.upperButton2.setTitle("", for: .normal)
                self.upperButton3.setTitle("", for: .normal)
                self.upperButtonBar.frame.size.width = self.upperLabel1.frame.size.width + 5
                self.upperButtonBar.center.y = self.upperButton1.center.y + (self.upperButton1.frame.size.height / 3)
                self.upperButtonBar.center.x = self.upperButton1.center.x
            }
        }
        else if page == 1{
            UIView.animate(withDuration: 0.2) {
                self.upperLabel2.text = ""
                self.upperButton2.setTitle("SOBRE NOSOTROS", for: .normal)
                self.upperLabel1.text = "EVENTO"
                self.upperLabel3.text = "LIBRO H.O.R"
                self.upperButton1.setTitle("", for: .normal)
                self.upperButton3.setTitle("", for: .normal)
                self.upperButtonBar.frame.size.width = self.upperLabel2.frame.size.width + 8
                self.upperButtonBar.center.y = self.upperButton2.center.y + (self.upperButton2.frame.size.height / 3)
                self.upperButtonBar.center.x = self.upperButton2.center.x
            }
        }
        else if page == 2{
            UIView.animate(withDuration: 0.2) {
                self.upperLabel3.text = ""
                self.upperButton3.setTitle("LIBRO H.O.R", for: .normal)
                self.upperLabel1.text = "EVENTO"
                self.upperLabel2.text = "SOBRE NOSOTROS"
                self.upperButton1.setTitle("", for: .normal)
                self.upperButton2.setTitle("", for: .normal)
                self.upperButtonBar.frame.size.width = self.upperLabel3.frame.size.width + 5
                self.upperButtonBar.center.y = self.upperButton3.center.y + (self.upperButton3.frame.size.height / 3)
                self.upperButtonBar.center.x = self.upperButton3.center.x
            }
        }
        pageControl.currentPage = Int(page)
    }
    
    //THIS IS FOR BETTER BUTTON RESPONSE BECAUSE NAVIGATION BAR HIDE UPPER BUTTON PARTIALLY THOSE BUTTON FROM NAVIGATION BAR ITEM
    @IBAction func upperButton1Trigger(_ sender: UIButton) {
        upperButton1Clicked(upperButton1)
    }
    
    @IBAction func upperButton2Trigger(_ sender: UIButton) {
        upperButton2Clicked(upperButton2)
    }
    
    @IBAction func upperButton3Trigger(_ sender: UIButton) {
        upperButton3Clicked(upperButton3)
    }
    
    // UPPER BUTTON ACTION
    @IBAction func upperButton1Clicked(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        sectionTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        UIView.animate(withDuration: 0.3) {
            self.upperLabel1.text = ""
            self.upperButton1.setTitle("EVENTO", for: .normal)
            self.upperLabel2.text = "SOBRE NOSOTROS"
            self.upperLabel3.text = "LIBRO H.O.R"
            self.upperButton2.setTitle("", for: .normal)
            self.upperButton3.setTitle("", for: .normal)
            self.upperButtonBar.frame.size.width = self.upperLabel1.frame.size.width + 5
            self.upperButtonBar.center.y = self.upperButton1.center.y + (self.upperButton1.frame.size.height / 3)
            self.upperButtonBar.center.x = self.upperButton1.center.x
        }
    }
    
    @IBAction func upperButton2Clicked(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        sectionTable.setContentOffset(CGPoint(x: 0, y: sectionTable.frame.height), animated: true)
        UIView.animate(withDuration: 0.3) {
            self.upperLabel2.text = ""
            self.upperButton2.setTitle("SOBRE NOSOTROS", for: .normal)
            self.upperLabel1.text = "EVENTO"
            self.upperLabel3.text = "LIBRO H.O.R"
            self.upperButton1.setTitle("", for: .normal)
            self.upperButton3.setTitle("", for: .normal)
            self.upperButtonBar.frame.size.width = self.upperLabel2.frame.size.width + 5
            self.upperButtonBar.center.y = self.upperButton2.center.y + (self.upperButton2.frame.size.height / 3)
            self.upperButtonBar.center.x = self.upperButton2.center.x
        }
    }
    
    @IBAction func upperButton3Clicked(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        sectionTable.setContentOffset(CGPoint(x: 0, y: (sectionTable.frame.height * 2)), animated: true)
        UIView.animate(withDuration: 0.3) {
            self.upperLabel3.text = ""
            self.upperButton3.setTitle("LIBRO H.O.R", for: .normal)
            self.upperLabel1.text = "EVENTO"
            self.upperLabel2.text = "SOBRE NOSOTROS"
            self.upperButton1.setTitle("", for: .normal)
            self.upperButton2.setTitle("", for: .normal)
            self.upperButtonBar.frame.size.width = self.upperLabel3.frame.size.width + 5
            self.upperButtonBar.center.y = self.upperButton3.center.y + (self.upperButton3.frame.size.height / 3)
            self.upperButtonBar.center.x = self.upperButton3.center.x
        }
    }
    
    
    // TABLE VIEW PROPERTY
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomMainSectionTableViewCell
        let url = URL(string: "https://drive.google.com/uc?export=view&id=\(mainMenu[indexPath.row].imageUrl)")
        cell.sectionImage.loadImage(from: url!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Int(view.frame.size.height - underBar.frame.size.height - bottom.frame.size.height))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SecondTypeMenuViewController") as? SecondTypeMenuViewController else {
                        return
            }
            vc.passedMainMenu = mainMenu
            vc.passedSectionTitle = mainMenu[indexPath.row].title
            vc.passedImage2Url = mainMenu[indexPath.row].image2Url
            vc.passedImage3Url = mainMenu[indexPath.row].image3Url
            AudioServicesPlaySystemSound(1519)
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sermonButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SectionTableViewController") as? SectionTableViewController else {
            return
        }
        vc.passedParentSection = "spanishSection"
        AudioServicesPlaySystemSound(1519)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func missionaryButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SecondTypeMenuViewController") as? SecondTypeMenuViewController else {
                    return
        }
        vc.passedMainMenu = mainMenu
        vc.passedSectionTitle = "MISIONERO"
        vc.passedImage2Url = "1-ZvRUWtc1U8U-1FhHf_Bt8gU1tGoRJyA"
        vc.passedImage3Url = ""
        AudioServicesPlaySystemSound(1519)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func giveButtonClicked(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        if let url = URL(string: "https://donorbox.org/iglesia-arbol-de-la-vida") {
            UIApplication.shared.open(url)
        }
    }
}


// SHAKING ANIMATION EXTENTION
public extension UIView {
    
    func shake(count : Float = 4,for duration : TimeInterval = 0.2,withTranslation translation : Float = 7) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()
var task: URLSessionTask!
var spinner = UIActivityIndicatorView(style: .gray)

extension UIImageView {
    func loadImage(from url: URL) {
        image = nil
        addSpinner()
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            image = imageFromCache
            removeSpinner()
            return
        }
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let newImage = UIImage(data: data)
                else { return }
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            
            DispatchQueue.main.async() {
                self.image = newImage
                self.removeSpinner()
                self.alpha = 0
                UIView.animate(withDuration: 0.7) {
                    self.alpha = 1
                }
                
            }
            }
        task.resume()
    }
    func addSpinner() {
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.startAnimating()
    }
    
    func removeSpinner() {
        spinner.removeFromSuperview()
    }
}
