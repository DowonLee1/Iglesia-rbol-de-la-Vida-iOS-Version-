//
//  CollectionViewCell.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/29/21.
//

import Foundation

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var seriesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
