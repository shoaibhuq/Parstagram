//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Shoaib Huq on 4/1/22.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
