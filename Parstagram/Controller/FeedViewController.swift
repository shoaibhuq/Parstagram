//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Shoaib Huq on 3/25/22.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 500
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    }
    
    @objc func onRefresh(){
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell
        
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.authorLabel.text = user.username
        
        cell.commentLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)
        cell.photoView.af.setImage(withURL: url!)
        
        return cell
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
