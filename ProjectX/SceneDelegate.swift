import Firebase
import GoogleSignIn
import FirebaseAuth

// conform to the google sign in delegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var name = "temp"
    var email = "mail"
    var id = "id"
    var accepted = [String]()
    var ref: DatabaseReference!
    var pic = URL(string: "api" + "endpoint")
    
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

    // when the app launches, it checks if the user is signed in, and redirect to the correct view controller
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            if Auth.auth().currentUser != nil {
                // redirect to the home controller
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainPage")
                self.window!.makeKeyAndVisible()
            } else {
                // redirect to the login controller
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainPage")
                self.window!.makeKeyAndVisible()
            }
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    // handle the sign in to redirect to the home controller
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.databaseGather(user: user)
            let storyboard =  UIStoryboard(name: "Main", bundle: nil)
            self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomePage")
            self.window!.makeKeyAndVisible()
        }
    }
    
    func databaseGather(user: GIDGoogleUser!) {
        //let idToken = user.authentication.idToken! // Safe to send to the server
        self.name = user.profile.name
        self.email = user.profile.email
        self.id = user.userID
        
        if user.profile.hasImage
        {
            self.pic = user.profile.imageURL(withDimension: 100)
        }
        getExistingMatch(completion: { (match) in
            self.accepted = match
        }, user: id, branch: "potentialMatch")
        
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...

    }
}
