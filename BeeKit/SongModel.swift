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
