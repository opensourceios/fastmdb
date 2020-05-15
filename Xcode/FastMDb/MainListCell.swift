//
//  MainListCell.swift
//
//  Created by Daniel on 5/6/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class MainListCell: UITableViewCell {

    static let reuseIdentifier = "MovieListCell"

    var item: Item? {
        didSet {
            textLabel?.text = item?.title
            detailTextLabel?.text = item?.subtitle
            accessoryType = item?.destination == nil ? .none : .disclosureIndicator
            imageView?.image = item?.image
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
    }

}

private extension MainListCell {
    func setup() {
        imageView?.tintColor = .systemGray
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .systemGray
    }
}
