//
//  TableViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import UIKit
import Firebase
import AudioToolbox
import MediaPlayer
import youtube_ios_player_helper

class TableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var mainView: UITableView!
    
    
    var passedParentSection = ""
    var passedSection = ""
    var posts = [Post]()
    var ref: DatabaseReference!
    let notification = UINotificationFeedbackGenerator()
    let spinner = UIActivityIndicatorView(style: .gray)
    var searching = false
    var filteredArray = [Post]()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetUp()
        toolBarSetUp()
        loadPosts()
//        tableView.reloadData()
    }
    
    private func toolBarSetUp() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        doneButton.tintColor = UIColor.black
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        searchBar.inputAccessoryView = toolbar
    }
    
    private func layoutSetUp() {
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
//        self.navigationItem.title = "SERMONS"
        self.navigationItem.title = passedSection
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    @objc func doneClicked() {
        tableView.endEditing(true)
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    @objc func requestData() {
        self.tableView.reloadData()
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    func loadPosts() {
        ref = Database.database().reference().child("sermon").child(passedParentSection).child(passedSection)
        ref.observe(DataEventType.childAdded, with: {(snapshot) in
            print(Thread.isMainThread)
            if let dict = snapshot.value as? [String: Any] {
                let titleString = dict["title"] as! String
                let bibleVerseString = dict["bibleVerse"] as! String
                let pastorNameString = dict["pastorName"] as! String
                let dateString = dict["date"] as! String
                let urlString = dict["url"] as! String
                let imageUrlString = dict["imageUrl"] as! String
                let post = Post(titleString: titleString, bibleVerseString: bibleVerseString, pastorNameString: pastorNameString, dateString: dateString, urlString: urlString, imageUrlString: imageUrlString)
                self.posts.append(post)
//                self.posts.sort(by: {$0.caption > $1.caption})
                self.mainView.insertRows(at: [IndexPath(row: self.posts.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
                self.spinner.stopAnimating()
            }
        })
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let safeArea = UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
//        let safeAreaTop: CGFloat = safeArea + (navigationController?.navigationBar.frame.height ?? 0)
//
//        let offset = scrollView.contentOffset.y + safeAreaTop
//
//        let alpha: CGFloat = 1 - ((scrollView.contentOffset.y + safeAreaTop) / safeAreaTop)
//        navigationController?.navigationBar.alpha = alpha
//        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
//    }
    
    // TableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func countLabelLines(label: UILabel) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = label.text! as NSString

        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        // LAYOUT FRAME WORK
        cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.topAnchor.constraint(equalTo: cell.cellView.topAnchor, constant: 0).isActive = true
        cell.titleLabel.leftAnchor.constraint(equalTo: cell.thumbnailImage.rightAnchor, constant: 9).isActive = true
        cell.titleLabel.rightAnchor.constraint(equalTo: cell.cellView.rightAnchor).isActive = true
        cell.titleLabel.heightAnchor.constraint(equalToConstant: cell.titleLabel.frame.size.height).isActive = true
        
        cell.bibleVerseLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.bibleVerseLabel.topAnchor.constraint(equalTo: cell.titleLabel.bottomAnchor, constant: 1).isActive = true
        cell.bibleVerseLabel.leftAnchor.constraint(equalTo: cell.titleLabel.leftAnchor).isActive = true
        cell.bibleVerseLabel.rightAnchor.constraint(equalTo: cell.cellView.rightAnchor).isActive = true
        cell.bibleVerseLabel.heightAnchor.constraint(equalToConstant: cell.bibleVerseLabel.frame.size.height).isActive = true
        
        cell.pastorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.pastorNameLabel.topAnchor.constraint(equalTo: cell.bibleVerseLabel.bottomAnchor, constant: 1).isActive = true
        cell.pastorNameLabel.leftAnchor.constraint(equalTo: cell.titleLabel.leftAnchor).isActive = true
        cell.pastorNameLabel.rightAnchor.constraint(equalTo: cell.cellView.rightAnchor).isActive = true
        cell.pastorNameLabel.heightAnchor.constraint(equalToConstant: cell.pastorNameLabel.frame.size.height).isActive = true
        
        cell.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.dateLabel.topAnchor.constraint(equalTo: cell.pastorNameLabel.bottomAnchor, constant: 1).isActive = true
        cell.dateLabel.leftAnchor.constraint(equalTo: cell.titleLabel.leftAnchor).isActive = true
        cell.dateLabel.rightAnchor.constraint(equalTo: cell.cellView.rightAnchor).isActive = true
        cell.dateLabel.heightAnchor.constraint(equalToConstant: cell.dateLabel.frame.size.height).isActive = true
        
        // SEARCH BAR CHECKING
        if searching {
            let url = URL(string: "https://drive.google.com/uc?export=view&id=\(filteredArray[indexPath.row].imageUrl)")
            cell.thumbnailImage.loadImage(from: url!)
            cell.titleLabel.text = filteredArray[indexPath.row].title
            cell.bibleVerseLabel.text = filteredArray[indexPath.row].bibleVerse
            cell.pastorNameLabel.text = filteredArray[indexPath.row].pastorName
            cell.dateLabel.text = filteredArray[indexPath.row].date
        }
        else {
            let url = URL(string: "https://drive.google.com/uc?export=view&id=\(posts[indexPath.row].imageUrl)")
            cell.thumbnailImage.loadImage(from: url!)
            cell.titleLabel.text = posts[indexPath.row].title
            cell.bibleVerseLabel.text = posts[indexPath.row].bibleVerse
            cell.pastorNameLabel.text = posts[indexPath.row].pastorName
            cell.dateLabel.text = posts[indexPath.row].date
        }
//        let url = "https://img.youtube.com/vi/\(posts[indexPath.row].url)/0.jpg"
//        let url = "https://drive.google.com/uc?export=view&id=\("1-hgQrXxb8E_iw0BZDX7BgvamJcfXBxSv")"
//        cell.thumbnailImage.downloaded(from: url)
//        cell.dateImage.frame.size.width = 72
//        cell.dateImage.frame.size.height = 70
//        cell.dateImage.image = UIImage(named: "date")
//        cell.dateImage.downloaded
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            spinner.stopAnimating()
            return 0
        }
        
        else if searching {
            return filteredArray.count
        }
        else {
            return posts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainView.deselectRow(at: indexPath, animated: true)
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController else {
            return
        }
//        let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
        if searching {
            let searchCaption = filteredArray[indexPath.row].title
            var index = 0
            while index < posts.count {
                if searchCaption == posts[index].title {
                    break
                }
                index += 1
            }
            vc.passedUrl = filteredArray[indexPath.row].url
            vc.passedCaption = filteredArray[indexPath.row].title
            vc.passedBibleVerse = filteredArray[indexPath.row].bibleVerse
            vc.passedPastorName = filteredArray[indexPath.row].pastorName
            vc.passedDate = filteredArray[indexPath.row].date
            vc.passedIndex = index
            vc.passedPost = posts
        }
        else {
            vc.passedUrl = posts[indexPath.row].url
            vc.passedCaption = posts[indexPath.row].title
            vc.passedBibleVerse = posts[indexPath.row].bibleVerse
            vc.passedPastorName = posts[indexPath.row].pastorName
            vc.passedDate = posts[indexPath.row].date
            vc.passedIndex = indexPath.row
            vc.passedPost = posts
        }
        AudioServicesPlaySystemSound(1519)
//        self.navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
    }
}

extension TableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArray = posts.filter { ($0.title.lowercased().contains(searchText.lowercased())) || ($0.bibleVerse.lowercased().contains(searchText.lowercased())) || ($0.pastorName.lowercased().contains(searchText.lowercased())) || ($0.date.lowercased().contains(searchText.lowercased()))}
        searching = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
