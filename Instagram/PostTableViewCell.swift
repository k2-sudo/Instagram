//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Kazuhiro Sudo on 16/4/13.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

//class PostTableViewCell: UITableViewCell , UITableViewDataSource, UITableViewDelegate{
class PostTableViewCell: UITableViewCell{

    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var commentText: UITextField!
    
    @IBOutlet var commentButton: UIButton!

    @IBOutlet var commentAllView: UILabel!
    
    
    // ボタン関数はHomeViewController内でCode定義
    //（セルは複数存在するため、どのセルのボタンを押したかを判別する必要があるのでここでは定義できない）

    
    var postData: PostData?
    //var recivedData
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // 表示されるときに呼ばれるメソッドをオーバーライドしてデータをUIに反映する
    override func layoutSubviews() {
        
        postImageView.image = postData!.image
        captionLabel.text = "\(postData!.name!) : \(postData!.caption!)"
        
        let likeNumber = postData!.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(postData!.date!)
        dateLabel.text = dateString
        
        if postData!.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        }
        
        
        //print("# of comments: " + (String)(postData!.comments.count))
        
        commentAllView.text = ""
        
        var i = 0
        while i < postData!.comments.count{
            commentAllView.text = commentAllView.text! + postData!.commentUsers[i] + ": " + postData!.comments[i]
            if i != (postData!.comments.count - 1) {
                commentAllView.text = commentAllView.text! + "\n"
            }
            i++
        }
         
        super.layoutSubviews()
    }
    
    /*
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
    */

    
}
