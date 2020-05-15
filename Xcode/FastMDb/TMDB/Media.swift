//
//  Media.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct Media: Codable {
    var id: Int

    var title: String?
    var original_title: String?

    var budget: Int?
    var revenue: Int?

    var vote_average: Double
    var vote_count: Int

    var belongs_to_collection: MediaCollection?
    var credits: Credits?
    var external_ids: ExternalIds?
    var genres: [Genre]?
    var homepage: String?
    var original_language: String?
    var overview: String
    var production_companies: [Production]?
    var poster_path: String?
    var recommendations: MediaSearch?
    var release_date: String?
    var runtime: Int?
    var similar: MediaSearch?
    var tagline: String?
    var videos: VideoSearch?

    // TV
    var original_name: String?
}

// TODO: genre and production should move to generic type?
// TODO: genre should move into its own file
struct Genre: Codable {
    var id: Int
    var name: String
}

// TODO: production should move into its own file
struct Production: Codable {
    var id: Int
    var name: String
}

extension Production {
    var listItem: Item {
        return Item(id: id, title: name, destination: .production)
    }
}

extension Media {
    var listItem: Item {
        var sub: [String] = []

        if release_date.yearDisplay != "" {
            sub.append(release_date.yearDisplay)
        }

        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }

        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .movie)
    }

    var titleDisplay: String? {
        var t = "\(title ?? original_name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }
}