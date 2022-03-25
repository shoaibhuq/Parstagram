//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Shoaib Huq on 3/25/22.
//

import UIKit

import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTexField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        let username = userNameTexField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        PFUser.logInWithUsername(inBackground: username, password:password) {
            (user: PFUser?, error: Error?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                if let error = error {
                    let errorString = error.localizedDescription
                    print(errorString)
                }
            }
        }
        
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        let user = PFUser()
        user.username = userNameTexField.text
        user.password = passwordTextField.text
        
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                print(errorString)
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
