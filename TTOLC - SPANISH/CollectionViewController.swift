//
//  CollectionViewController.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/29/21.
//

import UIKit
import Firebase
import AudioToolbox

struct Item {
    var imageName: String
}

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var animationView = UIView()
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "CollectionViewCell"
    let notification = UINotificationFeedbackGenerator()
    var passedSection = ""
    var ref: DatabaseReference!
    let spinner = UIActivityIndicatorView(style: .gray)
    
    var horBooksSpanish = [HorBooks]()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        
        animationView.frame.size.width = view.frame.size.width
        animationView.frame.size.height = view.frame.size.height
        animationView.backgroundColor = .white
        view.addSubview(animationView)
        UIView.animate(withDuration: 1.0) {
            self.animationView.alpha = 0
        }
        AudioServicesPlaySystemSound(1519)
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Libros"
        
        collectionView.refreshControl = refresher
        collectionView.backgroundView = spinner
        spinner.startAnimating()
        setupCollectionView()
        loadHorBooksSpanish()
    }
   
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCollectionViewItemSize()
    }
    
    func loadHorBooksSpanish() {
        ref = Database.database().reference().child("horBooks").child("horBooksSpanish")
            ref.observe(DataEventType.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as? [String: Any] {
                    let imageUrlString = dict["imageUrl"] as! String
                    let bookTitleString = dict["bookTitle"] as! String
                    let detailTitleString = dict["detailTitle"] as! String
                    let image2UrlString = dict["image2Url"] as! String
                    let descriptionString = dict["description"] as! String
                    let seriesTitleString = dict["seriesTitle"] as! String
                    let horBooks = HorBooks(imageUrlString: imageUrlString, bookTitleString: bookTitleString, detailTitleString: detailTitleString, image2UrlString: image2UrlString, descriptionString: descriptionString, seriesTitleString: seriesTitleString)
                    self.horBooksSpanish.append(horBooks)
                    //                self.posts.sort(by: {$0.caption > $1.caption})
    //                self.collectionView.insertItems(at: [IndexPath(row: self.posts.count-1, section: 0)], with: UICollectionView)
    //                self.collectionView.insertItems(at: [IndexPath(row: self.horBooksEnglish.count-1, section: 0)], with: UICollectionView)
                    self.collectionView.reloadData()
                    self.spinner.stopAnimating()
                }
            })
        }
    
    
    @objc func requestData() {
        UIView.animate(withDuration: 0.2) {
                self.collectionView.alpha = 0
        }
        self.collectionView.reloadData()
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
            UIView.animate(withDuration: 1.0, animations: {
                self.collectionView.alpha = 1
            })
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 40
            let interItemSpacing: CGFloat = 10
            
            let width = (collectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = width * 1.615
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(horBooksSpanish.count)
        return horBooksSpanish.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CollectionViewCell
        
        
        cell.imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.imageView.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        cell.imageView.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
        cell.imageView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        cell.imageView.bottomAnchor.constraint(equalTo: cell.titleLabel.topAnchor, constant: -10).isActive = true
        cell.clipsToBounds = true
        
        let url = URL(string: "https://drive.google.com/uc?export=view&id=\(horBooksSpanish[indexPath.item].imageUrl)")
        cell.imageView.loadImage(from: url!)
        cell.titleLabel.text = horBooksSpanish[indexPath.item].bookTitle
        cell.detailLabel.text = horBooksSpanish[indexPath.item].detailTitle
        cell.seriesLabel.text = horBooksSpanish[indexPath.item].seriesTitle

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailBookViewController") as? DetailBookViewController else {
                    return
        }
        //        let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
        vc.passedIndex = indexPath.row
        vc.passedHorBooks = horBooksSpanish
        
        AudioServicesPlaySystemSound(1519)
        present(vc, animated: true)
    }
    
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let collectionView = collectionView else {
//            return
//        }
//
//        let offset = collectionView.contentOffset.y
//        let height = collectionView.frame.size.height
//        let width = collectionView.frame.size.width
//        for cell in collectionView.visibleCells {
//            let left = cell.frame.origin.x
//            if left >= width / 2 {
//                let top = cell.frame.origin.y
//                let alpha = (top - offset) / height
//                cell.alpha = alpha
//            } else {
//                cell.alpha = 1
//            }
//        }
//    }
}

//extension CollectionViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        //        search = posts.filter({$0.prefix(searchText.count) == searchText})
//        //        search = test.filter({$0.prefix(searchText.count) == searchText})
//        filteredArray = posts.filter { $0.caption.prefix(searchText.count) == searchText }
//        searching = true
//        tableView.reloadData()
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searching = false
//        searchBar.text = ""
//        tableView.reloadData()
//    }
//}
