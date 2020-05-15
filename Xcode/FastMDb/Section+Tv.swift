//
//  Section+Tv.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func tvSections(_ tv: TV?, limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = nextEpisodeSection(tv) {
            sections.append(section)
        }

        if let section = overviewSection(tv) {
            sections.append(section)
        }

        if let section = recommendedSection(tv) {
            sections.append(section)
        }

        if let section = linksSection(tv) {
            sections.append(section)
        }

        if let section = createdBySection(tv) {
            sections.append(section)
        }

        if let section = networksSection(tv) {
            sections.append(section)
        }

        if let section = genresSection(tv) {
            sections.append(section)
        }

        if let section = productionSection(tv) {
            sections.append(section)
        }

        if let section = castSection(tv) {
            sections.append(section)
        }

        if let section = crewSection(tv) {
            sections.append(section)
        }

        return sections
    }
}

private extension Section {

    static func castSection(_ tv: TV?) -> Section? {
        guard
            let cast = tv?.credits?.cast,
            cast.count > 0 else { return nil }
        let items = cast.map { $0.castItem }
        return Section(header: "cast", items: items)
    }

    static func createdBySection(_ tv: TV?) -> Section? {
        guard
            let creators = tv?.created_by,
            creators.count > 0 else { return nil }

        let items = creators.map { $0.creatorItem }
        return Section(header: "created by", items: items)
    }

    static func crewSection(_ tv: TV?) -> Section? {
        guard let crew = tv?.credits?.crew else { return nil }

        let items = crew.map { $0.crewItem }
        guard items.count > 0 else { return nil }
        
        return Section(header: "crew", items: items)
    }

    static func genresSection(_ tv: TV?) -> Section? {
        guard
            let genres = tv?.genres,
            genres.count > 0 else { return nil }
        let items = genres.map { Item(id: $0.id, title: $0.name, destination: .genreTv) }
        return Section(header: "genres", items: items)
    }

    static func linksSection(_ tv: TV?) -> Section? {
        var items: [Item] = []

        if
            let homepage = tv?.homepage,
            homepage != "" {
            let item = Item(title: tv?.homepageDisplay, url: URL(string: homepage), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let instagram = tv?.external_ids?.validInstagramId {
            let item = Item(title: "Instagram", subtitle: instagram, url: Instagram.url(instagram), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let twitter = tv?.external_ids?.twitter_id,
            twitter != "" {
            let item = Item(title: "Twitter", subtitle: Twitter.username(twitter), url: Twitter.url(twitter), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let name = tv?.name {
            let item = Item(title: "Wikipedia", url: name.wikipediaUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let imdb = tv?.external_ids?.validImdbId {
            let item = Item(title: "IMDb", url: Imdb.url(id: imdb, kind: .title), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let name = tv?.name {
            let item = Item(title: "JustWatch", url: name.justWatchUrl, destination: .url, image: Item.videoImage)
            items.append(item)
        }

        return Section(header: "links", items: items)
    }

    static func networksSection(_ tv: TV?) -> Section? {
        guard
            let networks = tv?.networks,
            networks.count > 0 else { return nil }

        let items = networks.map { Item(id: $0.id, title: $0.name, destination: .networks) }
        return Section(header: "networks", items: items)
    }

    static func nextEpisodeSection(_ tv: TV?) -> Section? {
        guard var item = tv?.next_episode_to_air?.nextEpisodeItem else { return nil }

        item.episode = tv?.next_episode_to_air
        item.destination = .episode
        return Section(header: "next episode", items: [item])
    }

    static func overviewSection(_ tv: TV?) -> Section? {

        var items: [Item] = []

        if let display = tv?.displayName {

            var sub: [String] = []

            if
                let country = tv?.original_language,
                country != "en",
                let lang = Languages.List[country] {
                sub.append(lang)
            }
            else if let country = tv?.countryDisplay {
                sub.append(country)
            }

            if let aired = tv?.aired {
                sub.append(aired)
            }

            if
                let season = tv?.seasonDisplay,
                let s = tv?.seasons?.first,
                let c = s.episode_count,
                c > 0 {

                sub.append(season)
            }

            if let episodeCount = tv?.episodeCountDisplay {
                sub.append(episodeCount)
            }

            if
                let runtimes = tv?.episode_run_time,
                runtimes.count > 0,
                let runtime = runtimes.first {
                let item = "\(runtime)min"
                sub.append(item)
            }

            if let rating =
                tv?.ratingDisplay {
                sub.append(rating)
            }

            var item = Item(title: display, subtitle: sub.joined(separator: Tmdb.separator))

            if
                let s = tv?.seasons?.first,
                let c = s.episode_count,
                c > 0 {
                item.destination = .seasons

                item.items = Section.remappedSeasonItems(tv)
            }

            items.append(item)
        }

        if
            let o = tv?.overview,
            o != "" {
            items.append(Item(title: o))
        }

        return Section(header: "overview", items: items)
    }

    static func productionSection(_ tv: TV?) -> Section? {
        guard
            let companies = tv?.production_companies,
            companies.count > 0 else { return nil }

        let names = companies.map { $0.name }
        let item = Item(title: names.joined(separator: ", "), destination: .productionList, items: companies.map{ $0.listItem })
        return Section(header: "production", items: [item])
    }

    static func recommendedSection(_ tv: TV?) -> Section? {
        guard
            let recs = tv?.recommendations?.results,
            recs.count > 0 else { return nil }

        let titles = recs.map { $0.name }
        let items = recs.map { $0.listItem }
        let top3 = Array(titles.prefix(3))
        let item = Item.init(title: top3.joined(separator: ", "), destination: .more, items: items)
        return Section(header: "related", items: [item])
    }

}

private extension Section {
    static func remappedSeasonItems(_ tv: TV?) -> [Item] {
        var items: [Item] = []
        if let seasons = tv?.seasons {
            items = seasons.filter {
                let count = $0.episode_count
                return count ?? 0 > 0
            }.map { $0.listItem(tvId: tv?.id) }
        }

        return items
    }
}

private extension Credit {
    var castItem: Item {
        return Item(id: id, title: name, subtitle: character, destination: .person)
    }

    var creatorItem: Item {
        return Item(id: id, title: name, destination: .person)
    }

    var crewItem: Item {
        return Item(id: id, title: name, subtitle: job, destination: .person)
    }
}

private extension Season {
    func listItem(tvId: Int?) -> Item {
        var sub: [String] = []

        if let _ = air_date {
            sub.append(air_date.yearDisplay)
        }

        if let c = episode_count,
            c > 0 {
            let string = "\(c) episode\(c.pluralized)"
            sub.append(string)
        }

        return Item(id: tvId, title: name, subtitle: sub.joined(separator: Tmdb.separator), destination: .season, seasonNumber: season_number)
    }
}

private extension TV {

    var aired: String? {
        guard
            let _ = first_air_date,
            let _ =
            last_air_date else { return nil }

        if first_air_date.yearDisplay == endYearDisplay {
            return endYearDisplay
        }

        return ("\(first_air_date.yearDisplay) - \(endYearDisplay)")
    }

    var endYearDisplay: String {
        if status == "Returning Series" {
            return "present"
        }

        return last_air_date.yearDisplay
    }

    var episodeCountDisplay: String? {
        guard
            let count = number_of_episodes,
            count > 0 else { return nil }

        return "\(count) episode\(count == 1 ? "" : "s")"
    }

    var homepageDisplay: String? {
        guard
            let homepage = homepage,
            let url = URL(string: homepage) else { return nil }
        let host = url.host
        let display = host?.replacingOccurrences(of: "www.", with: "")

        return display
    }

    var ratingDisplay: String? {
        guard vote_count > 0 else { return nil }

        return "\(vote_average)/10 (\(vote_count) votes)"
    }

    var seasonDisplay: String? {
        guard
            let count = number_of_seasons,
            count > 0 else { return nil }

        return "\(count) season\(count == 1 ? "" : "s")"
    }

}
