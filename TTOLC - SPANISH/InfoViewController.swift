//
//  InfoViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import UIKit

import UIKit
import AudioToolbox
import Firebase
import SafariServices

class InfoViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var secondActionButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textViewLabel: UITextView!
    
    var appStoreId = ""
    var ref: DatabaseReference!
    var passedSectionTitle = ""
    var passedImage3Url = ""
    
    // MAP DIRECTION INFO
    var latitude = NSNumber()
    var longitude = NSNumber()
    var mapTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetUp()
        changbleObjects()
    }
    
    func checkLatestVersion() {
        ref = Database.database().reference().child("originalApp")
        ref.observe(DataEventType.childAdded, with: { [self](snapshot) in
                print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let appStoreIdString = dict["appStoreId"] as! String
                    appStoreId = appStoreIdString
                }
            })
        }
    
    private func layoutSetUp() {
        actionButton.layer.borderWidth = 0.7
        actionButton.layer.borderColor = UIColor.black.cgColor
        secondActionButton.layer.borderWidth = 0.7
        secondActionButton.layer.borderWidth = 0.7
    }
    
    private func changbleObjects() {
        if passedSectionTitle == "SOBRE NOSOTROS" {
            titleLabel.text = "INFORMACIÓN"
            subTitleLabel.text = "LA IGLESIA DEL ÁRBOL DE LA VIDA"
            actionButton.setTitle("APLICACIÓN", for: .normal)
            secondActionButton.setTitle("NUESTRO PASTOR", for: .normal)
            descriptionLabel.text = "INFORMACIÓN DE SERVICIO"
    
            // taking description text from server
            ref = Database.database().reference().child("aboutUsDescription").child("information")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
            
            // taking map direction from server
            ref = Database.database().reference().child("mapDirection")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let latitudeNS = dict["latitude"] as! NSNumber
                    self.latitude = latitudeNS
                    let longitudeNS = dict["longitude"] as! NSNumber
                    self.longitude = longitudeNS
                    let titleString = dict["titleString"] as! String
                    self.mapTitle = titleString
                    
                }
            })
        }
        else if passedSectionTitle == "HISTORIA DE LA REDENCIÓN" {
            secondActionButton.center = actionButton.center
            actionButton.alpha = 0
            titleLabel.text = "INFORMACIÓN"
            subTitleLabel.text = "LIBRO SERIRES HISTORIA DE REDENCIÓN"
            secondActionButton.setTitle("SOBRE EL AUTOR", for: .normal)
            descriptionLabel.text = "CONTENIDO DEL LIBRO SEIRES"
            
            // taking description text from server
            ref = Database.database().reference().child("historyOfRedemptionDescription").child("information")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
                if let dict = snapshot.value as? [String: Any] {
                    let spanish = dict["spanishText"] as! String
                    self.textViewLabel.text = spanish
                }
            })
        }
    }
    
    @IBAction func actionButtonClicked(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id" + appStoreId)
        if UIApplication.shared.canOpenURL(url! as URL) == true  {
            UIApplication.shared.open(url! as URL)
        }
    }
    
    @IBAction func secondActionButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailBookViewController") as? DetailBookViewController else {
            return
        }
        vc.passedViewController = passedSectionTitle
        vc.passedImage3Url = passedImage3Url
        AudioServicesPlaySystemSound(1519)
        present(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
