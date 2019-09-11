//
//  SubtitleTableViewCell.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import UIKit

public class SubtitleTableViewCell: UITableViewCell {
    static let identifier = "SubtitleTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
