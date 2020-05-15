//
//  Section+Movie.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func movieSections(movie: Media?, limit: Int) -> [Section] {
        var list: [Section] = []

        if let section = metadataSection(movie: movie) {
            list.append(section)
        }

        if let section = boxOfficeSection(movie: movie) {
            list.append(section)
        }

        if let section = languageSection(movie: movie) {
            list.append(section)
        }

        if let section = moreSection(movie: movie, collection: movie?.belongs_to_collection) {
            list.append(section)
        }

        if let section = linksSection(movie: movie) {
            list.append(section)
        }

        let credits = movie?.credits
        if let section = directorSection(credits: movie?.credits) {
            list.append(section)
        }

        if let section = writerSection(credits: credits) {
            list.append(section)
        }

        if let section = castSection(credits: credits, limit: limit) {
            list.append(section)
        }

        if let section = creditsSection(credits: credits, limit: limit) {
            list.append(section)
        }

        return list
    }
}

private extension Section {
    static func boxOfficeSection(movie: Media?) -> Section? {
        if let revenue = movie?.revenue,
            revenue > 0 {

            let item = Item(title: revenue.display, subtitle: movie?.budgetDisplay, destination: .moviesSortedBy, sortedBy: "revenue.desc")
            return Section(header: "box office", items: [item])
        }

        guard
            let budget = movie?.budget,
            budget > 0 else { return nil }

        let i = Item(title: movie?.budget?.display)
        return Section(header: "budget", items: [i])
    }

    static func castSection(credits: Credits?, limit: Int) -> Section? {
        guard let credits = credits else { return nil }

        let cast = Array(credits.cast.prefix(limit))
        guard cast.count > 0 else { return nil }

        let items = cast.map { $0.listItemCast }

        var castTotal: String?
        if credits.cast.count > limit {
            castTotal = "Showing \(limit) of \(credits.cast.count)"
        }

        return Section(header: "starring", items: items, footer: castTotal, destination: .castList, destinationItems: credits.cast.map { $0.listItemCast })
    }

    static func creditsSection(credits: Credits?, limit: Int) -> Section? {
        guard let credits = credits else { return nil }

        var filtered = credits.crew
        for job in CrewJob.allCases {
            filtered = filtered.filter { $0.job != job.rawValue }
        }

        let uniqueNames = filtered
            .map { $0.name }
            .unique

        var items: [Item] = []
        for name in uniqueNames {
            let crew = filtered.filter { $0.name == name}

            var item = Item()
            if let c = crew.first {
                item = Item(id: c.id, title: c.name, destination: .person)
            }

            let jobs = crew.map { $0.job ?? "" }
            item.subtitle = jobs.joined(separator: ", ")

            items.append(item)
        }

        let crew = Array(filtered.prefix(limit))

        guard crew.count > 0 else { return nil }

        var crewTotal: String?

        if credits.crew.count > limit {
            crewTotal = "Showing \(limit) of \(credits.crew.count)"
        }

        let prefixed = Array(items.prefix(limit))

        return Section(header: "credits", items: prefixed, footer: crewTotal, destination: .crewList, destinationItems: items)
    }

    static func directorSection(credits: Credits?) -> Section? {
        guard let credits = credits else { return nil }

        let director = credits.crew.filter { $0.job == CrewJob.Director.rawValue }
        guard director.count > 0 else { return nil }

        let items = director.map { Item(id: $0.id, title: $0.name ?? "", destination: .person) }
        return Section(header: "directed by", items: items)
    }

    static func languageSection(movie: Media?) -> Section? {
        guard let lang = movie?.languageDisplay else { return nil }
        return  Section(header: "language", items: [Item(title: lang)])
    }

    static func linksSection(movie: Media?) -> Section? {
        var items: [Item] = []

        // homepage
        if
            let homepage = movie?.homepage,
            homepage != "" {
            let url = URL(string: homepage)
            let item = Item(title: movie?.homepageDisplay, url: url, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        // wikipedia
        if let name = movie?.title {
            let item = Item(title: "Wikipedia", url: name.wikipediaUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        // imdb
        if
            let id = movie?.external_ids?.validImdbId {
            let item = Item(title: "IMDb", url: Imdb.url(id: id, kind: .title), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        // justwatch
        if let name = movie?.title {
            let item = Item(title: "JustWatch", url: name.justWatchUrl, destination: .url, image: Item.videoImage)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return Section(header: "links", items: items)
    }

    static func metadataSection(movie: Media?) -> Section? {
        var metadata: [String] = []

        if let movie = movie {
            // year
            if movie.release_date.yearDisplay != "" {
                metadata.append(movie.release_date.yearDisplay)
            }

            // runTime
            if let r = movie.runTimeDisplay {
                metadata.append(r)
            }

            // rating
            if let rating = movie.ratingDisplay {
                metadata.append(rating)
            }

            // countries
            if let countries = movie.production_countries {
                metadata.append(countries.map{$0.name}.joined(separator: ", "))
            }
        }

        var items: [Item] = []

        items.append( Item(title:movie?.titleDisplay, subtitle: metadata.joined(separator: Tmdb.separator)) )

        if let release = movie?.releaseDateDisplay {
            let item = Item(title: release, subtitle: movie?.releaseDateSubtitle)
            items.append(item)
        }

        if
            let tagline = movie?.tagline,
            tagline.isEmpty == false {
            items.append(Item(title: tagline))
        }

        if
            let
            o = movie?.overview,
            o.isEmpty == false {
            let item = Item(title: o)
            items.append(item)
        }

        if
            let videos = movie?.videos?.results,
            videos.count > 0 {
            let item = Item(title: "Videos", destination: .videos, items: videos.map {$0.listItem})
            items.append(item)
        }

        return Section(items: items)
    }

    static func moreSection(movie: Media?, collection: MediaCollection?) -> Section? {
        var section = Section(header: "more")
        var moreItems: [Item] = []

        // collection
        if let c = collection {
            moreItems.append(Item(id: c.id, title: c.name, destination: .collection))
        }

        // genre
        if let genre = movie?.genres,
            genre.count > 0 {
            let items = genre.map { Item(id: $0.id, title: $0.name, destination: .genre) }
            moreItems.append(contentsOf: items)
        }

        // production companies
        if
            let companies = movie?.production_companies,
            companies.count > 0 {
            let names = companies.map { $0.name }
            let item = Item(title: names.joined(separator: ", "), subtitle: "Production", destination: .productionList, items: companies.map { $0.listItem })
            moreItems.append(item)
        }

        if
            let recs = movie?.recommendations?.results,
            recs.count > 0 {
            let titles = recs.map { $0.titleDisplay ?? "" }
            let top3 = Array(titles.prefix(3))
            let items: [Item] = recs.map { $0.listItem }
            let item = Item(title: top3.joined(separator: ", "), subtitle: "Recommendations", destination: .more, items: items)
            moreItems.append(item)
        }

        if
            let recs = movie?.similar?.results,
            recs.count > 0 {
            let titles = recs.map { $0.titleDisplay ?? "" }
            let top3 = Array(titles.prefix(3))
            let items: [Item] = recs.map { $0.listItem }
            let item = Item(title: top3.joined(separator: ", "), subtitle: "Similar", destination: .more, items: items)
            moreItems.append(item)
        }

        if moreItems.count > 0 {
            section.items = moreItems
            return section
        }

        return nil
    }

    static func writerSection(credits: Credits?) -> Section? {

        guard let credits = credits else { return nil }

        var writtenBy: [Credit] = []
        let screenplay = credits.crew.filter { $0.job == CrewJob.Screenplay.rawValue }
        writtenBy.append(contentsOf: screenplay)

        let writer = credits.crew.filter { $0.job == CrewJob.Writer.rawValue }
        writtenBy.append(contentsOf: writer)

        guard writtenBy.count > 0 else { return nil }

        let items = writtenBy.map { Item(id: $0.id, title: $0.name ?? "", destination: .person) }

        return  Section(header: "written by", items: items)

    }

}

private extension Media {

    var budgetDisplay: String? {
        guard
            let budget = budget,
            budget > 0 else { return nil }

        return "\(budget.display) budget"
    }

    var homepageDisplay: String? {
        guard
            let homepage = homepage,
            let url = URL(string: homepage) else { return nil }
        let host = url.host
        let display = host?.replacingOccurrences(of: "www.", with: "")

        return display
    }

    var languageDisplay: String? {
        guard
            let lang = original_language,
            lang != "en" else { return nil }

        guard let value = Languages.List[lang] else { return lang }

        return value
    }

    var ratingDisplay: String? {
        guard vote_count > 0 else { return nil }

        return "\(vote_average)/10 (\(vote_count) votes)"
    }

    var releaseDateDisplay: String? {
        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r),
            date.timeIntervalSinceNow > 0 else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        return formatter.string(from: date)
    }

    var releaseDateSubtitle: String? {
        let sub = "Release Date"

        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r) else { return sub }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return sub }

        let components = calendar.dateComponents([.day, .month, .year], from: Date(), to: interval.end)

        var sub2 = "To be released in"

        if let y = components.year,
            y > 0 {
            sub2 = "\(sub2) \(y) year\(y.pluralized)"
        }

        if let m = components.month,
            m > 0 {
            sub2 = "\(sub2) \(m) month\(m.pluralized)"
        }

        if let d = components.day,
            d > 0 {
            sub2 = "\(sub2) \(d) day\(d.pluralized)"
        }

        return sub2
    }

    var runTimeDisplay: String? {
        guard
            let unwrapped = runtime,
            unwrapped > 0 else { return nil }

        let (h,m) = unwrapped.duration

        if (h == 0) {
            return "\(m)m"
        }

        return "\(h)h \(m)m"
    }

}

private extension Video {
    var listItem: Item {
        let sub = [site, type]
        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator), url: url, destination: .url, image: Item.videoImage)
    }

    var url: URL? {
        guard site.lowercased() == "youtube" else { return nil }

        let baseUrl = YouTube.urlBase
        let url = URL(string: "\(baseUrl)/\(key)")

        return url
    }
}

private enum CrewJob: String, CaseIterable {
    case Director
    case Screenplay
    case Writer
}

private extension Int {

    var duration: (Int, Int) {
        let h = Int(self / 60)
        let m = Int(self % 60)

        return (h, m)
    }

    /// Credits: https://stackoverflow.com/questions/48371093/swift-4-formatting-numbers-into-friendly-ks
    var display: String {

        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        switch num {
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"

        case 0...:
            return "\(self)"

        default:
            return "\(sign)\(self)"

        }

    }

}

private extension Double {

    func truncate(places: Int) -> Double {

        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal

    }

}
