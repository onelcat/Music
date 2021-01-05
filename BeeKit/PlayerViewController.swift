//
//  PlayerViewController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit
import ObjectMapper


let songList = """
[
    {
        "assetURL": "http://x-kpop.xyz/loadfiles/58420453/bWFtYW1vbyDrs4TsnbQg67mb64KY64qUIOuwpCBzdGFycnkgbmlnaHQ,",
        "title": "Gogobebe",
        "artist":"Mamamoo",
        "artwork":"https://upload.wikimedia.org/wikipedia/en/9/93/Mamamoo_-_White_Wind.png",
        "albumTitle":"White Wind",
        "albumArtist":"Mamamoo"
    },
    {
        "assetURL": "http://x-kpop.xyz/loadfiles/59160839/ZnJvbWlzIDkg67OE7J2YIOuwpCBzdGFycnkgbmlnaHQ,",
        "title": "Starry Night",
        "artist":"Mamamoo",
        "artwork":"https://upload.wikimedia.org/wikipedia/en/thumb/f/fb/Yellow_Flower_EP.jpg/220px-Yellow_Flower_EP.jpg",
        "albumTitle":"Yellow Flower",
        "albumArtist":"Mamamoo"
    },
    {
        "assetURL": "http://x-kpop.xyz/loadfiles/59158554/bWFtYW1vbyBiZSBjYWxt",
        "title": "Be Calm",
        "artist":"Hwasa",
        "artwork":"https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/%ED%99%94%EC%82%AC_%EA%B0%80%EC%98%A8_%EB%AE%A4%EC%A7%81_%EC%96%B4%EC%9B%8C%EC%A6%88_200108_%28cropped%29.jpg/220px-%ED%99%94%EC%82%AC_%EA%B0%80%EC%98%A8_%EB%AE%A4%EC%A7%81_%EC%96%B4%EC%9B%8C%EC%A6%88_200108_%28cropped%29.jpg",
        "albumTitle":"Yellow Flower",
        "albumArtist":"Mamamoo"
    }
]

"""

class PlayerViewController: BeeViewController {

    
    var player: AssetPlayer?
    
    var dataSource: [AssetItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = Mapper<AssetItemModel>().mapArray(JSONString: songList) ?? []
        assert(dataSource.count != 0)
        
        try! player = AssetPlayer(assets: self.dataSource)

        
        // Do any additional setup after loading the view.
    }
    


}
