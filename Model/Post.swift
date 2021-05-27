//
//  Post.swift
//  TTOLC - SPANISH
//
//  Created by Dowon on 4/27/21.
//

import Foundation
class Post {
    var title: String
    var bibleVerse: String
    var pastorName: String
    var date: String
    var url: String
    var imageUrl: String
    
    init(titleString: String, bibleVerseString: String, pastorNameString: String, dateString: String, urlString: String, imageUrlString: String) {
        title = titleString
        bibleVerse = bibleVerseString
        pastorName = pastorNameString
        date = dateString
        url = urlString
        imageUrl = imageUrlString
    }
}
