//
//  PlayerViewController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit
import ObjectMapper




class PlayerViewController: BeeViewController {

    
    var player: Player?
    
    var dataSource: [AssetItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = Mapper<AssetItemModel>().mapArray(JSONString: songList) ?? []
        assert(dataSource.count != 0)
        
        try! player = Player(assets: self.dataSource)

        // Do any additional setup after loading the view.
    }
    


}
