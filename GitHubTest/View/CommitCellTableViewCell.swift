//
//  CommitCellTableViewCell.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 04/03/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit

class CommitCellTableViewCell: UITableViewCell {

    @IBOutlet weak var hashLbl: UILabel!
    @IBOutlet weak var commitMessageLbl: UILabel!
    @IBOutlet weak var commiterLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
//    private var hash: String?
//    private var message: String?
//    private var commiter: String?
//    private var date: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateView(hash: String?, message: String?, commiter: String?, date: String?) {

        hashLbl.text = "Hash: " + (hash ?? "")
        commitMessageLbl.text = "Message: " + (message ?? "")
        commiterLbl.text = "Author: " + (commiter ?? "")
        
        if var dateLocal = date {
            dateLocal = dateLocal.replacingOccurrences(of: "T", with: " ")
            dateLocal = dateLocal.replacingOccurrences(of: "Z", with: "")
            dateLbl.text = "Date: " + dateLocal
        } else {
            dateLbl.text = "Date: "
        }
    }
}
