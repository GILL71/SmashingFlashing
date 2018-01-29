//
//  AudioTableViewCell.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 18.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class AudioTableViewCell: MGSwipeTableCell  {
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWith(_ record: RealmRecord) {
        nameLabel!.text = record.name
        durationLabel!.text = String(format: "%.01f", record.duration)
    }
}
