//
//  Section+Person.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func personSections(credit: Credit?, limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = ageSection(credit) {
            sections.append(section)
        }

        if let section = bioSection(credit) {
            sections.append(section)
        }

        if let section = knownForSection(credit) {
            sections.append(section)
        }

        if let section = linksSection(credit) {
            sections.append(section)
        }

        sections.append(contentsOf: creditsSection(credit: credit, limit: limit))

        return sections
    }

}

private extension Section {

    static func knownForActingSections(credit: Credit?, limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = movieCastSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = tvCastSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = crewMovieSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = crewTvSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        return sections
    }

    static func knownForOtherSections(credit: Credit?, limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = crewMovieSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = crewTvSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = movieCastSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        if let section = tvCastSection(credit: credit, limit: limit) {
            sections.append(section)
        }

        return sections
    }

}

private extension Section {
    
    static func ageSection(_ credit: Credit?) -> Section? {
        guard
            credit?.deathday == nil,
            let birthday = credit?.birthday else { return nil }

        var sub: [String] = []

        if let bday = credit?.birthday?.dateDisplay {
            sub.append("Born \(bday)")
        }

        if let pob = credit?.place_of_birth {
            sub.append(pob.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        var item = Item(title: birthday.age, subtitle: sub.joined(separator: Tmdb.separator))

        if let url = credit?.place_of_birth?.mapUrl {
            item.url = url
            item.destination = .url
            item.image = Item.mapImage
        }

        return Section(header: "age", items: [item])
    }

    static func bioSection(_ credit: Credit?) -> Section? {
        // biography, imdb
        var bioSection = Section(header: "biography")
        var bioItems: [Item] = []
        if
            let biography = credit?.biography,
            biography.isEmpty == false {
            bioItems.append(Item(title: biography))
        }

        // born, died
        if
            let bday = credit?.birthday?.dateDisplay,
            let dday = credit?.deathday?.dateDisplay {

            var pob: String?
            if let p = credit?.place_of_birth {
                pob = p.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            var bornItem = Item(title: "Born \(bday)", subtitle: pob)

            if let url = credit?.place_of_birth?.mapUrl {
                bornItem.url = url
                bornItem.destination = .url
            }

            bioItems.append(bornItem)

            let item = Item(title: "Died \(dday)", subtitle: "Age \(credit?.ageAtDeath ?? "")")
            bioItems.append(item)
        }

        guard bioItems.count > 0 else { return nil }
        bioSection.items = bioItems

        return bioSection
    }

    static func creditsSection(credit: Credit?, limit: Int) -> [Section] {
        var sections: [Section] = []
        if let known = credit?.known_for_department {

            if known == "Acting" {
                let s = Section.knownForActingSections(credit: credit, limit: limit)
                if s.count > 0 {
                    sections.append(contentsOf: s)
                }
            } else {
                let s = Section.knownForOtherSections(credit: credit, limit: limit)
                if s.count > 0 {
                    sections.append(contentsOf: s)
                }
            }

        } else {

            let s = Section.knownForActingSections(credit: credit, limit: limit)
            if s.count > 0 {
                sections.append(contentsOf: s)
            }

        }

        return sections
    }

    static func crewMovieSection(credit: Credit?, limit: Int) -> Section? {

        guard let credits = credit?.movie_credits else { return nil }

        let crewSorted = credits.crew.sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})

        let uniqueTitles = crewSorted
            .map { $0.original_title }
            .unique

        var items: [Item] = []
        for title in uniqueTitles {
            let crews = crewSorted.filter { $0.original_title == title}

            var item = Item()
            var sub: [String] = []
            if let c = crews.first {
                item = Item(id: c.id, title: c.titleDisplay, destination: .movie)

                if c.release_date.yearDisplay != "" {
                  sub.append(c.release_date.yearDisplay)
                }
            }

            let jobs = crews.map { $0.job ?? "" }
            let jobString = jobs.joined(separator: ", ")

            sub.append(jobString)

            item.subtitle = sub.joined(separator: Tmdb.separator)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = "Showing \(limit) of \(items.count)"
        }

        return Section(header: "Movie Credits", items: Array(items.prefix(limit)), footer: total, destination: .crewMovies, destinationItems: items)

    }

    static func crewTvSection(credit: Credit?, limit: Int) -> Section? {

        guard let crew = credit?.tv_credits?.crew else { return nil }

        let crewSorted = crew.sorted(by: { $0.first_air_date ?? "" > $1.first_air_date ?? ""})

        let uniqueTitles = crewSorted
            .map { $0.name }
            .unique

        var items: [Item] = []
        for title in uniqueTitles {
            let crews = crewSorted.filter { $0.name == title}

            var item = Item()
            var sub: [String] = []
            if let c = crews.first {
                item = Item(id: c.id, title: c.titleDisplay, destination: .tv)
                sub.append(c.first_air_date.yearDisplay)
            }

            let jobs = crews.map { $0.job ?? "" }
            let jobString = jobs.joined(separator: ", ")

            sub.append(jobString)

            item.subtitle = sub.joined(separator: Tmdb.separator)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = "Showing \(limit) of \(items.count)"
        }

        return Section(header: "TV Credits", items: Array(items.prefix(limit)), footer: total, destination: .crewTv, destinationItems: items)
    }

    static func knownForSection(_ credit: Credit?) -> Section? {

        var creditCount: Int = 0

        if let c = credit?.movie_credits?.cast.count {
            creditCount += c
        }
        if let c = credit?.movie_credits?.crew.count {
            creditCount += c
        }
        if let c = credit?.tv_credits?.cast.count {
            creditCount += c
        }
        if let c = credit?.tv_credits?.crew.count {
            creditCount += c
        }

        guard
            creditCount > 10,
            let known = credit?.known_for_department else { return nil }

        // TODO: have dedicated Directing, Writing section

        let limit = 2
        var items: [Item] = []

        if known == "Acting" {

            if let media = credit?.movie_credits?.cast.prefix(limit) {
                items = Array(media).map { $0.movieItem }
            }

            if
                items.count == 0,
                let media = credit?.tv_credits?.cast.first {
                var sub: String?
                if media.first_air_date.yearDisplay != "" {
                    sub = media.first_air_date.yearDisplay
                }
                let item = Item(id: media.id, title: media.titleDisplay, subtitle: sub, destination: .tv)
                items.append(item)
            }

        }
        else {

            if let media = credit?.movie_credits?.crew.prefix(limit) {
                items = Array(media).map { $0.movieCrewItem }
            }

            if
                items.count == 0,
                let media = credit?.tv_credits?.crew.first {
                var sub: [String] = []
                if media.first_air_date.yearDisplay != "" {
                    sub.append(media.first_air_date.yearDisplay)
                }
                if let job = media.job {
                    sub.append(job)
                }

                let item = Item(id: media.id, title: media.titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .tv)
                items.append(item)
            }

        }

        guard items.count > 0 else { return nil }

        return Section(header: "known for", items: items)
    }

    static func linksSection(_ credit: Credit?) -> Section? {
        var items: [Item] = []

        if let instagram = credit?.external_ids?.validInstagramId {
            let item = Item(title: "Instagram", subtitle: instagram, url: Instagram.url(instagram), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let twitter = credit?.external_ids?.validTwitterId {
            let item = Item(title: "Twitter", subtitle: Twitter.username(twitter), url: Twitter.url(twitter), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let name = credit?.name {
            let item = Item(title: "Wikipedia", url: name.wikipediaUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let id = credit?.external_ids?.validImdbId {        
            let item = Item(title: "IMDb", url: Imdb.url(id: id, kind: .person), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        return Section(header: "links", items: items)
    }

    static func movieCastSection(credit: Credit?, limit: Int) -> Section? {
        guard let credits = credit?.movie_credits else { return nil }

        let sorted = credits.cast.sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})
        let cast = Array(sorted.prefix(limit))

        guard cast.count > 0 else { return nil }

        let items = cast.map { $0.movieItem }

        var castTotal: String?
        if credits.cast.count > limit {
            castTotal = "Showing \(limit) of \(credits.cast.count)"
        }

        return  Section(header: "Movies", items: items, footer: castTotal, destination: .castMovies, destinationItems: credits.cast.map { $0.listItemCast })
    }

    static func tvCastSection(credit: Credit?, limit: Int) -> Section? {
        guard let c = credit?.tv_credits ,
            c.cast.count > 0 else { return nil }
        let items = c.cast
            .sorted { $0.episode_count ?? 0 > $1.episode_count ?? 0 }
            .map { $0.tvListItem }

        guard items.count > 0 else { return nil }
        var total: String?
        if items.count > limit {
            total = "Showing \(limit) of \(items.count)"
        }

        let prefix = Array(items.prefix(limit))

        return Section(header: "TV", items: prefix, footer: total, destination: .castTv, destinationItems: c.cast.map { $0.tvListItem })
    }

}

private extension Credit {
    var movieItem: Item {
        return Item(id: id, title: titleDisplay, subtitle: subtitle, destination: .movie)
    }

    var movieCrewItem: Item {
        var sub: [String] = []
        if release_date.yearDisplay != "" {
            sub.append(release_date.yearDisplay)
        }
        if let j = job {
            sub.append(j)
        }
        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .movie)
    }
}

private extension String {
    var age: String? {
        let formatter = Tmdb.dateFormatter
        guard let date = formatter.date(from: self) else { return nil }

        guard let age = date.yearDifferenceWithDate(Date()) else { return nil }

        return String(age)
    }

    var mapUrl: URL? {
        let baseUrl = Map.urlBase
        guard let encodedName = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

        let finalUrl = baseUrl + encodedName
        return URL(string: finalUrl)
    }
}

private extension Credit {
    var ageAtDeath: String? {
        let formatter = Tmdb.dateFormatter

        guard
            let bday = birthday,
            let date = formatter.date(from: bday) else { return nil }

        guard let dday = deathday,
            let date2 = formatter.date(from: dday) else { return nil }

        guard let age = date.yearDifferenceWithDate(date2) else { return nil }

        return String(age)
    }
}

private extension Date {
    func yearDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .year, for: date) else { return nil }

        let components = calendar.dateComponents([.year], from: self, to: interval.end)

        return components.year
    }
}
