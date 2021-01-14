//
//  HomePageVC.swift
//  ProjectX
//
//  Created by Akash Gujjar on 12/20/20.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

class HomePage: UIViewController {
    
    @IBOutlet weak var signOut: UIButton!
    
    @IBAction func signOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MainPage") as! ViewController
        self.present(VC, animated: true, completion: nil)
    }
}
