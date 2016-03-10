//
//  HistorialTableViewCell.swift
//  Quiero Taxi
//
//  Created by Doctor on 11/30/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class HistorialTableViewCell: UITableViewCell {
    
    
    @IBOutlet var imagenHistorial: UIImageView!
    @IBOutlet var descripcionHistorial: UILabel!
    @IBOutlet var fechaHistorial: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
