//
//  Episode.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

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

private extension Date {
    func daysDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return nil }

        let components = calendar.dateComponents([.day], from: self, to: interval.end)

        return components.day
    }
}
