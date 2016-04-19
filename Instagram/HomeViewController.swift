//
//  HomeViewController.swift
//  Instagram
//
//  Created by Kazuhiro Sudo on 16/4/10.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import Firebase

//class HomeViewController: UIViewController {
class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var firebaseRef:Firebase!
    var postArray: [PostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableViewを準備する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Firebaseの準備をする
        firebaseRef = Firebase(url: CommonConst.FirebaseURL)
        
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            self.postArray.insert(postData, atIndex: 0)
            
            // TableViewを再表示する
            self.tableView.reloadData()
        })
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildChanged, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            
            // 保持している配列からidが同じものを探す
            var index: Int = 0
            for post in self.postArray {
                if post.id == postData.id {
                    index = self.postArray.indexOf(post)!
                    break
                }
            }
            
            // 差し替えるため一度削除する
            self.postArray.removeAtIndex(index)
            
            // 削除したところに更新済みのでデータを追加する
            self.postArray.insert(postData, atIndex: index)
            
            // TableViewの該当セルだけを更新する
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        cell.postData = postArray[indexPath.row]
        
        // セル内のボタンのアクションをソースコードで設定する（Storyboardを使わない方法）
        cell.likeButton.addTarget(self, action:"handleButton:event:", forControlEvents:  UIControlEvents.TouchUpInside)
        cell.commentButton.addTarget(self, action: "handleCommentButton:event:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //TODO
        
        // UILabelの行数が変わっている可能性があるので再描画させる
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // セル内のPostボタン（Comment）がタップされた時に呼ばれるメソッド
    func handleCommentButton(sender: UIButton, event:UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        // Firebaseに保存するデータの準備
        let uid = firebaseRef.authData.uid

        postData.comments.append("Nice!!")
        postData.commentUids.append(uid)
        
        print("Commented on the post " + (String)(indexPath!.row))
        print("Post id: " + postData.id!)
        
        
        let comments = postData.comments
        let commentUids = postData.commentUids

        // 辞書を作成してFirebaseに保存する
        //let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "comments": comments]
        let post = ["comments": comments, "commentUids":commentUids]
        let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)

        postRef.childByAppendingPath(postData.id).updateChildValues(post)
        
    }

    // セル内のLikeボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event:UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        let uid = firebaseRef.authData.uid
        
        if postData.isLiked {
            // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
            var index = -1
            for likeId in postData.likes {
                if likeId == uid {
                    // 削除するためにインデックスを保持しておく
                    index = postData.likes.indexOf(likeId)!
                    break
                }
            }
            postData.likes.removeAtIndex(index)
        } else {
            postData.likes.append(uid)
        }
        
        let imageString = postData.imageString
        let name = postData.name
        let caption = postData.caption
        let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
        let likes = postData.likes
        
        // 辞書を作成してFirebaseに保存する
        let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes]
        let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)
        postRef.childByAppendingPath(postData.id).setValue(post)
    }
}
