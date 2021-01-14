//
//  validMatchesVC.swift
//  ProjectX
//
//  Created by Akash Gujjar on 12/27/20.
//
 
import Foundation
import UIKit
import Firebase
import GoogleSignIn
 
class ValidMatch: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var matches = ["Person1", "Person2", "Person3"]
    var count = 0
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MatchesTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "MatchesTableViewCell")
        table.delegate = self
        table.dataSource = self
    }
    
    func getData2(completion: @escaping (String) -> (), user: String, branch: String) {
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
    
    func getData1(completion: @escaping ([String]) -> (), user: String, branch: String){
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
}
 
extension ValidMatch: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("I was selected")
    }
}
 
extension ValidMatch: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sceneDelegate.accepted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as! MatchesTableViewCell
        let index = indexPath.row
        getData1(completion: { (match) in
            self.matches = match
            let matchID = self.matches[index]
            
            self.getData2(completion: { (matchName) in
                cell.personName.text = matchName
            }, user: matchID, branch: "name")
            
            self.getData2(completion: { (major) in
                cell.personMajor.text = major
            }, user: matchID, branch: "major")
            
            self.getData2(completion: { (img) in
                guard let imageURL = URL(string: img) else { return }
                DispatchQueue.global().async {
                    guard let imageData = try? Data(contentsOf: imageURL) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        cell.personImage.image = image
                    }
                }
            }, user: matchID, branch: "image")
            
        }, user: sceneDelegate.id, branch: "potentialMatch")

        return cell
    }
    

}
 
 

