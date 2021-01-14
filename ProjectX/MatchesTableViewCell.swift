//
//  MatchesTableViewCell.swift
//  ProjectX
//
//  Created by Scotty Singh on 12/27/20.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

   
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personMajor: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
