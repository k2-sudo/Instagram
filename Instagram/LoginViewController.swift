//
//  LoginViewController.swift
//  Instagram
//
//  Created by Kazuhiro Sudo on 16/4/10.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class LoginViewController: UIViewController {

    @IBOutlet var mailAddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var displayNameTextField: UITextField!
    
    var firebaseRef: Firebase!

    //Tap Sign in button
    @IBAction func handleLoginButton(sender: AnyObject) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
        // アドレスとパスワード名のいずれかでも入力されていない時はHUDを出して何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showErrorWithStatus("Please input required information.")
                return
            }
            
            // 処理中を表示
            SVProgressHUD.show()
            
            firebaseRef.authUser(address, password: password, withCompletionBlock: { error, authData in
                if error != nil {
                    SVProgressHUD.showErrorWithStatus("Error: Login Failed")
                    print(error)
                } else {
                    // Firebaseからログインしたユーザの表示名を取得してNSUserDefaultsに保存する
                    let usersRef = self.firebaseRef.childByAppendingPath(CommonConst.UsersPATH)
                    let uidRef = usersRef.childByAppendingPath(authData.uid)
                    uidRef.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                        if let displayName = snapshot.value.objectForKey("name") as? String {
                            self.setDisplayName(displayName)
                        }
                        // HUDを消す
                        SVProgressHUD.dismiss()
                        // 画面を閉じる
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        }
    }
    
    //Tap Sing up button
    @IBAction func handleCreateAcountButton(sender: AnyObject) {

        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
                
            // アドレスとパスワードと表示名のいずれかでも入力されていない時はHUDを出して何もしない
            if address.characters.isEmpty || password.characters.isEmpty || displayName.characters.isEmpty {
                SVProgressHUD.showErrorWithStatus("Please input required information.")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            firebaseRef.createUser(address, password: password, withValueCompletionBlock: { error, result in
                if error != nil {
                    SVProgressHUD.showErrorWithStatus("Error: Could not create user acount")
                    print(error)
                } else {
                    print("Sucessfully created the user account")
                    self.firebaseRef.authUser(address, password: password, withCompletionBlock:  { error, authData in
                        if error != nil {
                            SVProgressHUD.showErrorWithStatus("Error: Could not sign in")
                            print(error)
                        } else {
                            // Firebaseに表示名を保存する
                            let usersRef = self.firebaseRef.childByAppendingPath(CommonConst.UsersPATH)
                            let data = ["name": displayName]
                            usersRef.childByAppendingPath("/\(authData.uid)").setValue(data)
                                
                            // NSUserDefaultsに表示名を保存する
                            self.setDisplayName(displayName)
                            
                            // HUDを消す
                            SVProgressHUD.dismiss()
                            
                            // 画面を閉じる
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    // NSUserDefaultsに表示名を保存する
    func setDisplayName(name: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setValue(name, forKey: CommonConst.DisplayNameKey)
        ud.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize Firebase
        firebaseRef = Firebase(url: CommonConst.FirebaseURL)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
