//
//  DetailSectionTableViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import UIKit
import Firebase
import AudioToolbox

class DetailSectionTableViewController: UITableViewController {
    
    @IBOutlet var mainView: UITableView!

    var passedParentSection = ""
    var passedSection = ""
    var sectionDetail = [SectionDetail]()
    var ref: DatabaseReference!
    let notification = UINotificationFeedbackGenerator()
    let spinner = UIActivityIndicatorView(style: .gray)
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetUp()
        loadPosts()
    }
    
    private func layoutSetUp() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        spinner.startAnimating()
        tableView.backgroundView = spinner
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = passedSection
    }
    
    @objc func requestData() {
        self.tableView.reloadData()
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
        self.refresher.endRefreshing()
        }
    }
    
    func loadPosts() {
        ref = Database.database().reference().child("sermonDetailSection").child(passedParentSection).child(passedSection)
        print(passedParentSection)
        print(passedSection)
        ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
            if let dict = snapshot.value as? [String: Any] {
                let sectionTitle = dict["sectionTitle"] as! String
                let detailSection = SectionDetail(sectionTitle: sectionTitle)
                self.sectionDetail.append(detailSection)
                self.mainView.insertRows(at: [IndexPath(row: self.sectionDetail.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
                //                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }
        })
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width / 2.3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailSectionCell") as! CustomDetailSectionTableViewCell
        cell.sectionLable.text = sectionDetail[indexPath.row].section
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDetail.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController") as? TableViewController
        vc?.passedParentSection = passedParentSection
        vc?.passedSection = sectionDetail[indexPath.row].section
        AudioServicesPlaySystemSound(1519)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
