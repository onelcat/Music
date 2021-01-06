//
//  SongModel.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//  Copyright © 2021 onelcat.github.io. All rights reserved.
//

import Foundation
import MediaPlayer
import ObjectMapper



let songList = """
[
    {
        "assetURL": "http://192.168.0.173:8888/i.mp3",
        "title": "Gogobebe",
        "artist":"Mamamoo",
        "artwork":"https://ilkpop.com/images/59158046.jpg",
        "albumTitle":"White Wind",
        "albumArtist":"Mamamoo"
    },
    {
        "assetURL": "http://192.168.0.173:8888/ii.mp3",
        "title": "Starry Night",
        "artist":"Mamamoo",
        "artwork":"https://ilkpop.com/images/58420453.jpg",
        "albumTitle":"Yellow Flower",
        "albumArtist":"Mamamoo"
    },
    {
                
        "assetURL": "http://192.168.0.173:8888/iii.mp3",
        "title": "Be Calm",
        "artist":"Hwasa",
        "artwork":"https://ilkpop.com/images/59158554.jpg",
        "albumTitle":"Yellow Flower",
        "albumArtist":"Mamamoo"
    },
    {
        "assetURL": "http://192.168.0.173:8888/iv.mp3",
        "title": "Maria",
        "artist":"Hwasa",
        "artwork":"https://ilkpop.com/images/59159946.jpg",
        "albumTitle":"Maria",
        "albumArtist":"Hwasa"
    }
]

"""

//
//let songList = """
//[
//    {
//        "assetURL": "http://x-kpop.xyz/loadfiles/59158046/bWFtYW1vbyDqs6Dqs6DrsqDrsqAgZ29nb2JlYmU,",
//        "title": "Gogobebe",
//        "artist":"Mamamoo",
//        "artwork":"https://ilkpop.com/images/59158046.jpg",
//        "albumTitle":"White Wind",
//        "albumArtist":"Mamamoo"
//    },
//    {
//        "assetURL": "http://x-kpop.xyz/loadfiles/58420453/bWFtYW1vbyDrs4TsnbQg67mb64KY64qUIOuwpCBzdGFycnkgbmlnaHQ,",
//        "title": "Starry Night",
//        "artist":"Mamamoo",
//        "artwork":"https://ilkpop.com/images/58420453.jpg",
//        "albumTitle":"Yellow Flower",
//        "albumArtist":"Mamamoo"
//    },
//    {
//        "assetURL": "http://x-kpop.xyz/loadfiles/59158554/bWFtYW1vbyBiZSBjYWxt",
//        "title": "Be Calm",
//        "artist":"Hwasa",
//        "artwork":"https://ilkpop.com/images/59158554.jpg",
//        "albumTitle":"Yellow Flower",
//        "albumArtist":"Mamamoo"
//    },
//    {
//        "assetURL": "http://x-kpop.xyz/loadfiles/59159946/aHdhc2EgbWFtYW1vbyDrp4jrpqzslYQgbWFyaWE,",
//        "title": "Maria",
//        "artist":"Hwasa",
//        "artwork":"https://ilkpop.com/images/59159946.jpg",
//        "albumTitle":"Maria",
//        "albumArtist":"Hwasa"
//    }
//]
//
//"""

struct AssetItemModel: Mappable {
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        assetURL <- (map["assetURL"],URLTransform())
        title <- map["title"]
        artist <- map["artist"]
        artworkURL <- (map["artwork"],URLTransform())
        albumArtist <- map["albumArtist"]
        albumTitle <- map["albumTitle"]
    }
    
    
    var metadata: NowPlayableStaticMetadata {
        
        guard let url = assetURL,let title = title else {
            fatalError()
        }
        
        return NowPlayableStaticMetadata(assetURL: url, mediaType: .audio, isLiveStream: isLiveStream, title: title, artist: artist, artwork: nil, artworkURL: artworkURL, albumArtist: albumArtist, albumTitle: albumTitle)
    }
    
    var assetURL: URL?
    var isLiveStream: Bool = false
    var title: String?
    var artist: String?
    var artworkURL: URL?
    var albumArtist: String?
    var albumTitle: String?
    
}
