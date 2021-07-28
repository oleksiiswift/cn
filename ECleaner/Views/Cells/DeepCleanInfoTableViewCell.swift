//
//  DeepCleanInfoTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import UIKit

class DeepCleanInfoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var similarTextLabel: UILabel!
    
    @IBOutlet weak var duplicateTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }    
}

extension DeepCleanInfoTableViewCell {
    
    func updateduplicate(duplicate: String) {
        duplicateTextLabel.text = duplicate
    }
    
    func updateSimilar(similar: String) {
        similarTextLabel.text = similar
    }
}
