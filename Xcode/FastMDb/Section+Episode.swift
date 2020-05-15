
//
//  Section+Episode.swift
//
//  Created by Daniel on 5/12/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func episodeSections(_ episode: Episode?) -> [Section] {
        var sections: [Section] = []

        sections.append(mainSection(episode))

        if let section = Section.writingSection(episode) {
            sections.append(section)
        }

        if let section = Section.directorSection(episode) {
            sections.append(section)
        }

        if let section = Section.guestStarsSection(episode) {
            sections.append(section)
        }

//        if let section = Section.crewSection(episode) {
//            sections.append(section)
//        }

        return sections
    }
}

private extension Section {

    static func directorSection(_ episode: Episode?) -> Section? {
        guard let crew = episode?.crew else { return nil }

        let directors = crew.filter { $0.job == "Director"}
        guard directors.count > 0 else { return nil }

        let items = directors.map { $0.listItemCrew }

        return Section(header: "directed by", items: items)
    }

    static func guestStarsSection(_ episode: Episode?) -> Section? {
        guard let guests = episode?.guest_stars else { return nil }

        let items = guests.map { $0.listItemCast }
        
        guard items.count > 0 else { return nil }

        let section = Section(header: "Guest Stars", items: items)

        return section
    }

    static func mainSection(_ episode: Episode?) -> Section {
        var items: [Item] = []

        if let name = episode?.name {
            var sub: String?
            if let e = episode?.episode_number,
                let s = episode?.season_number {
                sub = "Season \(s), Episode \(e)"
            }
            let item = Item(title: name, subtitle: sub)
            items.append(item)
        }

        if let item = episode?.nextEpisodeItem {
            items.append(item)
        }

        if let o = episode?.overview,
            o != "" {
            let item = Item(title: o)
            items.append(item)
        }

        return Section(items: items)
    }

    // TODO: show or delete crew?
//    static func crewSection(_ episode: Episode?) -> Section? {
//        guard let crew = episode?.crew else { return nil }
//
//        let items = crew.map { $0.listItemCrew }
//
//        return Section(items: items)
//    }

    static func writingSection(_ episode: Episode?) -> Section? {
        guard let crew = episode?.crew else { return nil }

        let directors = crew.filter { $0.job == "Teleplay" || $0.job == "Writer" }
        guard directors.count > 0 else { return nil }

        let items = directors.map { $0.listItemCrew }

        return Section(header: "written by", items: items)
    }

}

private extension Credit {
    var listItemCrew: Item {
        return Item(id: id, title: name, subtitle: job, destination: .person)
    }
}
