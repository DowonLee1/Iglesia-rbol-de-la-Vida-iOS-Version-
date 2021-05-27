//
//  HorBooks.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/29/21.
//

import Foundation

class HorBooks {
    var imageUrl: String
    var bookTitle: String
    var detailTitle: String
    var image2Url: String
    var description: String
    var seriesTitle: String
    
    init(imageUrlString: String, bookTitleString: String, detailTitleString: String, image2UrlString: String, descriptionString: String, seriesTitleString: String) {
        imageUrl = imageUrlString
        bookTitle = bookTitleString
        detailTitle = detailTitleString
        image2Url = image2UrlString
        description = descriptionString
        seriesTitle = seriesTitleString
    }
}
