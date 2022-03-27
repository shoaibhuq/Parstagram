//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Shoaib Huq on 3/25/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()
        
        let imageData = imageView.image?.pngData()
        
        let file = PFFileObject(data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground() { (success, error) in
            if success {
                print("saved")
            } else {
                let alert = UIAlertController(title: "Error", message: "Could not save image, please try again", preferredStyle: UIAlertController.Style.alert)

                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        // show the alert
                        self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true
                , completion: nil)
        
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
