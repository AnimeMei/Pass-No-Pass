//
//  getStartedViewController.swift
//  Pass No Pass
//
//  Created by Adrian on 4/22/17.
//  Copyright © 2017 Adrian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class getStartedViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var myView: UIView!
    
    let rootRef = FIRDatabase.database().reference()
    let fbLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFacebookButtons()

    }
    
    //facebook button
    fileprivate func setupFacebookButtons() {
        //adding facebook sign in button
        let loginButton = FBSDKLoginButton()
        myView.addSubview(loginButton)      //added button to myView
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 205, width: view.frame.width - 32, height: 50)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
    }
    //facebook logoutbutton
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    //facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.myView.isHidden = true
        
       // SVProgressHUD.show()
        
        if error != nil {
            print(error)
            //SVProgressHUD.dismiss()
            self.myView.isHidden = false
            return
        } else if(result.isCancelled){
            //SVProgressHUD.dismiss()
            self.myView.isHidden = false
        }
        else if error == nil {
            showEmailAddress()
            
            //SVProgressHUD.dismiss()
            let userDefaults = UserDefaults.standard
            //notify onboarding screen already completed
            userDefaults.set(true, forKey: "onboardingComplete")
            userDefaults.synchronize()
            
            //go to nav
            self.performSegue(withIdentifier: "toNav", sender: nil)
        }
        
    }
    
    // get facebook user's basic info from social media account
    func showEmailAddress() {
        //setup facebook access token
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        //using access token to grab user credential
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            self.storeInfoFirstLogin()   //store new user's data
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        // --->        //Did not do anthing with this user's data
        // using credential to grab user's data
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err!)
                return
            }
            print(result!)
        }
    }
    
    //store user's basic info on the very first login
    func storeInfoFirstLogin() {
        guard let thisUserId = FIRAuth.auth()?.currentUser?.uid else { return }
        let profileNameRef = FIRDatabase.database().reference().child("user_profile").child(thisUserId).child("username")
        profileNameRef.observeSingleEvent(of: .value, with: {
            snapshot in
            //if the username is nil assuming the user profile needs to be reset
            if let somevalue = snapshot.value as? String {
                //acutally have something
            } else {
                print("Profile is empty.")
                self.setupNewprofile()
            }
        })
    }//end storeInfoFirstLogin


    
    private func setupNewprofile() {
        UIApplication.shared.beginIgnoringInteractionEvents() //disable user touch action while downloading image
        //SVProgressHUD.show()
        print("\nSetting up new users profile ...")
        //if user is not nil
        if let user = FIRAuth.auth()?.currentUser {
            
            //store the userID
            let userID = user.uid
            
            rootRef.child("Users").child("\(user.uid)/username").setValue(user.displayName?.components(separatedBy: " ")[0])
            if let email = user.email {
                rootRef.child("Users").child("\(user.uid)/email").setValue(email)
            } else {
                rootRef.child("Users").child("\(user.uid)/email").setValue("")
            }
        }//end if FIRAuth.auth()?.currentUser
    }


    
   
}
