//
//  MatchPageVC.swift
//  ProjectX
//
//  Created by Akash Gujjar on 12/24/20.
//
 
import Foundation
import UIKit
import Firebase
import GoogleSignIn
 
class MatchPage: UIViewController {
        
    let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    
    @IBOutlet weak var matchImage: UIImageView!
    @IBOutlet weak var matchName: UILabel!
    @IBOutlet weak var matchMajor: UILabel!
    @IBOutlet weak var matchAbout: UITextView!
    
    
    var ref: DatabaseReference!
    var matched = [DataSnapshot]()
    var count = 0
    var matchCount = 1
    var accepted = [String]()
    var temp = ""
    var domain = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getExistingMatch(completion: { (match) in
            self.accepted = match
        }, user: sceneDelegate.id, branch: "potentialMatch")
        
        getDataMatch(completion: { (email) in
            self.domain = email.components(separatedBy: "@")[1]
            print(self.domain)
        }, branch: "email", user: sceneDelegate.id)
        
        getDataMatch(completion: { (index) in
            self.count = (index as NSString).integerValue
        }, branch: "currentIndex", user: sceneDelegate.id)
        
        self.matchAbout.isEditable = false
        
        self.matchAbout.layer.borderWidth = 2
        self.matchAbout.layer.borderColor = UIColor.black.cgColor
        self.matchAbout.layer.cornerRadius = 15
 
    }
 
    @IBAction func reject(_ sender: Any) {
        if(accepted.contains(temp)){
            if let index = accepted.firstIndex(of: temp) {
                accepted.remove(at: index)
            }
            if let index1 = sceneDelegate.accepted.firstIndex(of: temp) {
                sceneDelegate.accepted.remove(at: index1)
            }
        }
        nextMatch()
    }
    
    @IBAction func accept(_ sender: Any) {
        if(!accepted.contains(temp)){
            sceneDelegate.accepted.append(temp)
            accepted.append(temp)
        }
        nextMatch()
    }
    
    func nextMatch(){
        getDataMine(completion: { (match) in
            self.matched = match
            if self.count < self.matched.count {
                self.userMatch(count: self.count)
                self.count += 1
                self.count = self.count % self.matchCount
            }else{
                self.count = 0
                self.userMatch(count: self.count)
                self.count += 1
                self.count = self.count % self.matchCount
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ref = Database.database().reference()
        self.ref.child("users").child(sceneDelegate.id).child("currentIndex").setValue(String(count % self.matchCount))
        self.ref.child("users").child(sceneDelegate.id).child("potentialMatch").setValue(accepted)
    }
    
    func getDataMine(completion: @escaping (Array<DataSnapshot>) -> ()) {
        getDataMatch(completion: { (gend) in
            let ref = Database.database().reference().child("users")
            let query = ref.queryOrdered(byChild: "gender").queryEqual(toValue: gend)
            var matches = [DataSnapshot]()
            query.observe(.value, with: { (snapshot) in
                if (snapshot.value as? [String: AnyObject]) != nil
                {
                    for childSnapshot in snapshot.children {
                        let pMatch = childSnapshot as! DataSnapshot
                        let mDomain = (pMatch.childSnapshot(forPath: "email").value! as! String).components(separatedBy: "@")[1]
                        if(mDomain == self.domain){
                            matches.append(pMatch)
                        }
                    }
                    completion(matches)
                } else {
                    completion(Array<DataSnapshot>())
                }
            })
        }, branch: "gender", user: sceneDelegate.id)
    }
    
    func getExistingMatch(completion: @escaping ([String]) -> (), user: String, branch: String){
        var match = [String]()
        let refrence = Database.database().reference().child("users").child(user).child(branch)
        refrence.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let value = (child as AnyObject).value as String
                match.append(value)
            }
            completion(match)
        })
    }
    
    func getDataMatch(completion: @escaping (String) -> (), branch: String, user: String) {
        let refrence = Database.database().reference().child("users").child(user)
        refrence.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject]
            {
                var myName = ""
                if snapshot.hasChild(branch){
                    myName = (value[branch] as? String)!
                }else{
                    myName = "placeholder for " + branch
                }
                completion(myName)
            } else {
                completion("")
            }
        })
    }
    
    func userMatch(count: Int) {
        matchCount = matched.count
        let matchUID = matched[count].key
        temp = matchUID
        if matchUID != sceneDelegate.id{
            getDataMatch(completion: { (link) in
                self.setImage(from: link)
            }, branch: "image", user: matchUID)
            
            getDataMatch(completion: { (name) in
                self.matchName.text = name
            }, branch: "name", user: matchUID)
            
            getDataMatch(completion: { (major) in
                self.matchMajor.text = major
            }, branch: "major", user: matchUID)
            
            getDataMatch(completion: { (about) in
                self.matchAbout.text = about
            }, branch: "about", user: matchUID)
        }else{
            nextMatch()
        }
    }
    
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.matchImage.image = image
            }
        }
    }
}
