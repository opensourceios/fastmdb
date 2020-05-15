//
//  Section+Search.swift
//
//  Created by Daniel on 5/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

// TODO: have tappable footers to show single list of results when more than what is displayed + later on allow paging
extension Section {
    static func searchSection(_ movie: MediaSearch?, _ tv: TvSearch?, _ people: PeopleSearch?) -> [Section] {
        var sections: [Section] = []

        if let section = movieSection(movie) {
            sections.append(section)
        }

        if let section = tvSection(tv) {
            sections.append(section)
        }

        if let section = peopleSection(people) {
            sections.append(section)
        }

        if sections.count == 0 {
            sections.append(Section.noResultsSection)
        }

        return sections
    }
}

private extension Section {

    static func movieSection(_ movie: MediaSearch?) -> Section? {
        guard let movie = movie else { return nil }

        let items = movie.results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = movie.total_results

        return Section(header: "Movies (\(count))", items: items)
    }

    static func peopleSection(_ people: PeopleSearch?) -> Section? {
        guard let people = people else { return nil }

        let items = people.results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = people.total_results

        return Section(header: "People (\(count))", items: items)
    }

    static func tvSection(_ tv: TvSearch?) -> Section? {
        guard let tv = tv else { return nil }

        let items = tv.results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = tv.total_results

        return Section(header: "TV (\(count))", items: items)
    }

}

private extension Section {
    static var noResultsSection: Section {
        let item = Item(title: "Nothing found for your search 😅")
        let section = Section(header: "Results", items: [item])

        return section
    }
}
