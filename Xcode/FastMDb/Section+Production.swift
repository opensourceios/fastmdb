//
//  Section+Production.swift
//  FastMDb
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func sectionForMovieSearch(_ movie: MediaSearch?) -> Section? {
        guard let movie = movie else { return nil }

        let items = movie.results
            .sorted { $0.release_date ?? "" > $1.release_date ?? "" }
            .map { $0.listItem }

        guard items.count > 0 else { return nil }

        return Section(header: "movies", items: items)
    }

    static func sectionForTvSearch(_ tv: TvSearch?) -> Section? {
        guard let tv = tv else { return nil }

        let items = tv.results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        return Section(header: "tv", items: items)
    }
}
