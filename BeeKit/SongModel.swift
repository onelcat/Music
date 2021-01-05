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
        
    }
    
    
    var metadata: NowPlayableStaticMetadata {
        return NowPlayableStaticMetadata(assetURL: assetURL!, mediaType: .audio, isLiveStream: isLiveStream, title: title!, artist: artist, artwork: nil, artworkURL: artwork, albumArtist: albumArtist, albumTitle: albumTitle)
    }
    
    var assetURL: URL?
    
    var isLiveStream: Bool = true
    
    var title: String?
    
    var artist: String?
    var artwork: URL?
    
    var albumArtist: String?
    var albumTitle: String?
    
}
