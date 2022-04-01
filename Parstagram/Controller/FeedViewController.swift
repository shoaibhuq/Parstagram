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
    
    var posts = [PFObject]()
    
    var refreshControl: UIRefreshControl!
    
    var numberOfPosts = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 500
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
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
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginVC;
    }
    
    
    @objc func onRefresh(){
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        numberOfPosts += 20
        query.limit = numberOfPosts
        query.findObjectsInBackground{(newPosts, error) in
            if newPosts != nil {
                self.posts = newPosts!
                self.tableView.reloadData()
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.loadMorePosts()
                print("loading more posts")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "Comments")
        comment["content"] = "Testing comment"
        comment["post"] = post
        comment["author"] = PFUser.current()
        
        post.add(comment, forKey: "comments")
        post.saveInBackground { success, error in
            if success{
                print("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        post.saveInBackground{ (success, error) in
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
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
        } else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
            
            print(indexPath.row)
            let comment = comments[indexPath.row - 1]
            
            let user = comment["author"] as! PFUser
            cell.authorLabel.text = user.username
            cell.contentLabel.text = comment["content"] as? String
            
            return cell
        }
        
    }
}
