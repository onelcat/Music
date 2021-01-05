//
//  SongListViewController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit
import ObjectMapper

final
class SongListViewController: BeeViewController {

    @IBOutlet weak var tableView: BeeTableView!
    
    var dataSource: [AssetItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: SongTableViewCell.cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongTableViewCell.cellReuseIdentifier)
        
        self.dataSource = Mapper<AssetItemModel>().mapArray(JSONString: songList) ?? []
        assert(dataSource.count != 0)
           
    }
    
}

extension SongListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.cellReuseIdentifier, for: indexPath) as? SongTableViewCell else {
            fatalError()
        }
        let item = self.dataSource[indexPath.item]
        cell.artistLabel.text = item.artist
        cell.titleLabel.text = item.title
        debugPrint("加载图片", item.artworkURL)
        cell.artworImageView.kf.setImage(with: item.artworkURL)
        return cell
    }
    
}

extension SongListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
}

