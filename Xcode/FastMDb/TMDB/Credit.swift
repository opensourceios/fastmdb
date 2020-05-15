//
//  Credit.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct Credit: Codable {
    var id: Int

    var name: String?
    var original_name: String?

    var title: String?
    var original_title: String?

    var poster_path: String?
    var profile_path: String?

    var episode_count: Int?
    var first_air_date: String?

    var known_for_department: String?
    var known_for: [Media]?

    var movie_credits: Credits?
    var tv_credits: Credits?

    var biography: String?
    var birthday: String?
    var place_of_birth: String?
    var character: String?
    var deathday: String?
    var external_ids: ExternalIds?
    var genre_ids: [Int]?
    var original_language: String?
    var release_date: String?

    // Crew
    var job: String?
}

extension Credit {

    var listItem: Item {
        var sub: [String] = []

        if let dept = known_for_department {
            sub.append(dept)
        }

        if
            let known = known_for,
            known.count > 0 {
            let movies = Array(known.prefix(3))
                .map { $0.titleDisplay ?? "" }
                .filter { $0.isEmpty == false }

            if movies.count > 0 {
                sub.append(movies.joined(separator: ", "))
            }
        }

        return Item(id: id, title: name, subtitle: sub.joined(separator: ": "), destination: .person)
    }

    var listItemCast: Item {
        return Item(id: id, title: name, subtitle: character, destination: .person)
    }

    var titleDisplay: String? {
        var t = "\(title ?? name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }
    
    var tvListItem: Item {
        var sub: [String] = []

        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }

        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }

        if let c = character, c != "" {
            sub.append(c)
        }

        if let episodes = episode_count {
            let epString = "\(episodes) episode\(episodes > 1 ? "s" : "")"
            sub.append(epString)
        }

        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .tv)
    }


    var subtitle: String {
        var sub: [String] = []

        if release_date.yearDisplay.isEmpty == false {
            sub.append(release_date.yearDisplay)
        }

        if
            let character = character,
            character.isEmpty == false {
            sub.append(character)
        }

        return sub.joined(separator: Tmdb.separator)
    }

}
