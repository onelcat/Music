//
//  SongModel.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//  Copyright © 2021 onelcat.github.io. All rights reserved.
//

import Foundation
import MediaPlayer

struct AssetItemModel {
    
    var metadata: NowPlayableStaticMetadata {
        return NowPlayableStaticMetadata(assetURL: assetURL, mediaType: .audio, isLiveStream: isLiveStream, title: title, artist: artist, artwork: nil, albumArtist: albumArtist, albumTitle: albumTitle)
    }
    
    let assetURL: URL
    
    let isLiveStream: Bool = true
    
    let title: String
    
    let artist: String?
    let artwork: URL?
    
    let albumArtist: String?
    let albumTitle: String?
    
}
