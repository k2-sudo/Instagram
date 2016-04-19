//
//  commentCell.swift
//  Instagram
//
//  Created by Kazuhiro Sudo on 16/4/15.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit

//class commentCell: UITableViewCell {
class commentCell: UITableViewCell , UITableViewDataSource, UITableViewDelegate{

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath)
        
        // Cellに値を設定する.
        cell.textLabel?.text = "Test"
        cell.detailTextLabel?.text = "Test!Test!"
        return cell
    }
}
