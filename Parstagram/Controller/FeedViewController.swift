//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Shoaib Huq on 3/25/22.
//

import UIKit
import Parse
import MessageInputBar

//MARK: - FeedViewController

class FeedViewController: UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    var refreshControl: UIRefreshControl!
    
    var numberOfPosts = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        //commentBar Configuration
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.delegate = self
        commentBar.inputTextView.textColor = UIColor.darkText
        
        //refreshControl Configuration
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        //Print current user (DEBUG)
        print("Current user: \(PFUser.current()?.username ?? "No user")")
        
    }
    
    //
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfPosts
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    //MARK: - Buttons
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginVC;
    }
    
    //MARK: - Refresh and Infinite Load
    
    
    @objc func onRefresh(){
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        numberOfPosts += 10
        query.limit = numberOfPosts
        query.findObjectsInBackground{(newPosts, error) in
            if newPosts != nil {
                self.posts = newPosts!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Could not load more tweets", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

//MARK: - TableView Configuration

extension FeedViewController:UITableViewDelegate, UITableViewDataSource {
    //Infinite Load
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.loadMorePosts()
                print("loading more posts")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1{
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell
            
            let user = post["author"] as! PFUser
            cell.authorLabel.text = user.username
            
            cell.commentLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
            cell.photoView.af.setImage(withURL: url!)
            
            return cell
        } else if indexPath.row <= comments.count{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            
            let user = comment["author"] as! PFUser
            cell.authorLabel.text = user.username
            cell.contentLabel.text = comment["content"] as? String
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")
            
            return cell!
        }
        
    }
}

//MARK: - Comment Bar Configuration

extension FeedViewController: MessageInputBarDelegate{
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showCommentBar
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["content"] = inputBar.inputTextView.text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { success, error in
            if success{
                print("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
}
