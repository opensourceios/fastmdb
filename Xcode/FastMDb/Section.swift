//
//  Section.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

struct Section {
    var header: String?
    var items: [Item]?
    var footer: String?
    var destination: Destination?

    var destinationItems: [Item]?
}

struct Item {
    var id: Int?
    var title: String?
    var subtitle: String?
    var url: URL?
    var destination: Destination?

    var sortedBy: String?
    var episode: Episode?
    var seasonNumber: Int?
    var items: [Item]?
    var image: UIImage?
}

enum Destination {
    case
    movie,
    person,
    episode,
    tv,

    collection,
    genre,
    genreTv,
    more, // similar, recommendations
    moviesSortedBy,
    networks,
    production,
    castMovies,
    crewMovies,
    crewTv,
    castTv,
    castList,
    crewList,
    productionList,

    season, seasons,

    videos,

    url
}

extension Item {
    static var linkImage: UIImage? {
        return UIImage(systemName: "link.circle.fill")
    }

    static var mapImage: UIImage? {
        return UIImage(systemName: "mappin.circle.fill")
    }

    static var videoImage: UIImage? {
        return UIImage(systemName: "play.circle.fill")
    }
}
