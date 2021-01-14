 //
//  ProfilePageVC.swift
//  ProjectX
//
//  Created by Akash Gujjar on 12/20/20.
//
 
import Foundation
import UIKit
import Firebase
import FirebaseStorage
import GoogleSignIn
 
 class ProfilePage: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var gender: UIPickerView!
    @IBOutlet weak var grade: UIPickerView!
    @IBOutlet weak var major: UITextField!
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
            imageView.layer.cornerRadius = 20
            imageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
        uploadMedia(completion: { (url) in
            self.ref.child("users").child(self.sceneDelegate.id).child("image").setValue(url)
            self.sceneDelegate.pic = URL(string: url!)
        })
    }
    
    func uploadMedia(completion: @escaping (_ url: String?) -> Void) {

        let storageRef = Storage.storage().reference().child(sceneDelegate.id + ".png")
        if let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.5) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {

                    storageRef.downloadURL(completion: { (url, error) in
                        completion(url?.absoluteString)
                    })
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController();
    
    var ref: DatabaseReference!
    
    var gradeOptions:Array = ["Freshman", "Sophomore", "Junior", "Senior"]
    var genderOptions:Array = ["Female", "Male", "Other"]
 
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        let storageRef = storage.reference()

        name.text = sceneDelegate.name
        getData(completion: { (abt) in
            self.about.text = abt
        }, branch: "about")
        
        getData(completion: { (loc) in
            self.location.text = loc
        }, branch: "location")
        
        getData(completion: { (maj) in
            self.major.text = maj
        }, branch: "major")
        
        getData(completion: { (grad) in
            let index = self.gradeOptions.firstIndex(of: grad)
            self.grade.selectRow(index ?? 0, inComponent: 0, animated: true)
        }, branch: "grade")
        
        getData(completion: { (gen) in
            print("Received \(gen)")
            let index = self.genderOptions.firstIndex(of: gen)
            self.gender.selectRow(index ?? 0, inComponent: 0, animated: true)
        }, branch: "gender")
        
        self.ref = Database.database().reference()
        self.ref.child("users").child(self.sceneDelegate.id).child("image").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.getData(completion: { (img) in
                    self.sceneDelegate.pic = URL(string: img)
                    self.setImage(from: img)
                }, branch: "image")
            }else{
                self.ref.child("users").child(self.sceneDelegate.id).child("image").setValue(self.sceneDelegate.pic?.absoluteString)
                let urlText = self.sceneDelegate.pic!.absoluteString
                self.setImage(from: urlText)
            }
        })
        
        self.ref.child("users").child(sceneDelegate.id).child("name").setValue(sceneDelegate.name)
        self.ref.child("users").child(sceneDelegate.id).child("email").setValue(sceneDelegate.email)
        
        self.about.delegate = self
        self.location.delegate = self
        self.major.delegate = self
        imagePicker.delegate = self
        
    }
      
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ref.child("users").child(sceneDelegate.id).child("location").setValue(location.text)
        self.ref.child("users").child(sceneDelegate.id).child("major").setValue(major.text)
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.ref.child("users").child(sceneDelegate.id).child("about").setValue(about.text)
 
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // use the row to get the selected row from the picker view
            // using the row extract the value from your datasource (array[row])
        var chosenGrade = "Freshman"
        var chosenGender = "Female"
        
        if (pickerView.tag == 1) {
            chosenGrade = gradeOptions[row]
            self.ref.child("users").child(sceneDelegate.id).child("grade").setValue(chosenGrade)
        }
        if (pickerView.tag == 2) {
            chosenGender = genderOptions[row]
            self.ref.child("users").child(sceneDelegate.id).child("gender").setValue(chosenGender)
        }
        
    }
    
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    func getData(completion: @escaping (String) -> (), branch: String) {
        let refrence = Database.database().reference().child("users").child(sceneDelegate.id)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return gradeOptions.count
        } else {
            return genderOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return gradeOptions[row]
        } else {
            return genderOptions[row]
        }
    }
}
 
 
 
 
 
 
 
 
 

