//
//  SongListViewController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

final
class SongListViewController: BeeViewController {

    @IBOutlet weak var tableView: BeeTableView!
    
    private var dataSource = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: SongTableViewCell.cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongTableViewCell.cellReuseIdentifier)
        
        // 这里实现广告的加载
        
        // 通知请求数据
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
        return cell
    }
    
}

extension SongListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

