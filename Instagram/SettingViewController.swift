//
//  SettingViewController.swift
//  Instagram
//
//  Created by Kazuhiro Sudo on 16/4/10.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ESTabBarController


class SettingViewController: UIViewController {

    @IBOutlet var displayNameTextField: UITextField!
    
    @IBAction func handleChangeButton(sender: AnyObject) {
        if let name = displayNameTextField.text {
            // 表示名が入力されていない時はHUDを出して何もしない
            if name.characters.isEmpty {
                SVProgressHUD.showErrorWithStatus("Please input your name")
                return
            }
            
            // Firebaseに表示名を保存する
            let usersRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.UsersPATH)
            let data = ["name": name]
            usersRef.childByAppendingPath("/\(usersRef.authData.uid)").setValue(data)
            
            // NSUserDefaultsに表示名を保存する
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setValue(name, forKey: CommonConst.DisplayNameKey)
            ud.synchronize()
            
            // HUDで完了を知らせる
            SVProgressHUD.showSuccessWithStatus("Your name is updated")
            
            // キーボードを閉じる
            view.endEditing(true)
        }
    }
        
    
    @IBAction func handleLogoutButton(sender: AnyObject) {
        // ログアウトする
        let firebaseRef = Firebase(url: CommonConst.FirebaseURL)
        firebaseRef.unauth()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
        self.presentViewController(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        let tabBarController = parentViewController as! ESTabBarController
        tabBarController.setSelectedIndex(0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSUserDefaultsから表示名を取得してTextFieldに設定する
        let ud = NSUserDefaults.standardUserDefaults()
        let name = ud.objectForKey(CommonConst.DisplayNameKey) as! String
        displayNameTextField.text = name
    }
    
}
