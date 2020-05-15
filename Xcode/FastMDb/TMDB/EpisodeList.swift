//
//  EpisodeList.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct EpisodeList: Codable {
    var air_date: String?
    var episodes: [Episode]?
}
