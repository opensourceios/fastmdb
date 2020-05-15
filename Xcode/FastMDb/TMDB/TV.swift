//
//  TV.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct TV: Codable {
    var id: Int

    var name: String
    var original_name: String

    var first_air_date: String?
    var last_air_date: String?
    var next_episode_to_air: Episode?

    var number_of_episodes: Int?
    var number_of_seasons: Int?

    var vote_average: Double
    var vote_count: Int

    var created_by: [Credit]?
    var episode_run_time: [Int]?
    var genres: [Genre]?
    var homepage: String?
    var original_language: String?
    var overview: String?
    var networks: [TvNetwork]?
    var poster_path: String?
    var production_companies: [Production]?
    var recommendations: TvSearch?

    var seasons: [Season]?
    var status: String?

    var credits: Credits?

    var external_ids: ExternalIds?
}

struct EpisodeList: Codable {
    var air_date: String?
    var episodes: [Episode]?
}

struct Episode: Codable {
//    var id: Int?

    var air_date: String?
    var episode_number: Int?
    var season_number: Int?

    var name: String?
    var overview: String?

    var crew: [Credit]?
    var guest_stars: [Credit]?
}

struct Season: Codable {
    var id: Int

    var air_date: String?
    var episode_count: Int
    var name: String
    var season_number: Int
}

struct TvNetwork: Codable {
    var name: String?
    var id: Int
//       "logo_path": "/o3OedEP0f9mfZr33jz2BfXOUK5.png",
    var origin_country: String?
}

extension Episode {
    var nextEpisodeItem: Item? {
        guard
            let airdate = air_date,
            let display = airdate.dateDisplay else { return nil }

        var inNumberOfDays: String?
        let formatter = Tmdb.dateFormatter
        if let date = formatter.date(from: airdate),
            let days = Date().daysDifferenceWithDate(date),
            days > 0 {
            if days == 0 {
                inNumberOfDays = "Today"
            } else if days == 1 {
                inNumberOfDays = "Tomorrow"
            } else {
                inNumberOfDays = "In \(days) days"
            }
        }

        return Item(title: display, subtitle: inNumberOfDays)
    }
}

extension TV {
    var displayName: String {
        if name != original_name {
            return "\(name) (\(original_name))"
        }
        return name
    }
    
    var listItem: Item {
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

        return Item(id: id, title: displayName, subtitle: sub.joined(separator: Tmdb.separator), destination: .tv)
    }
}

private extension Date {
    func daysDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return nil }

        let components = calendar.dateComponents([.day], from: self, to: interval.end)

        return components.day
    }
}
