//
//  MainViewController+TableView.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = dataSource.sections[section]
        return s.header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = dataSource.sections[section]
        return s.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: MainListCell.reuseIdentifier, for: indexPath) as! MainListCell

        let s = dataSource.sections[indexPath.section]
        guard let items = s.items else { return c }
        let item = items[indexPath.row]

        c.item = item

        return c
    }

}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let s = dataSource.sections[indexPath.section]
        if let items = s.items {
            let item = items[indexPath.row]
            if let _ = item.destination {
                return true
            }
        }

        return false
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let s = dataSource.sections[section]

        guard let title = s.footer else { return nil }

        var fr = view.bounds
        fr.size.height = 30
        let button = DestinationButton(frame: fr)

        button.section = s
        button.autoresizingMask = [.flexibleWidth]
        button.addTarget(self, action: #selector(handleFooterButton), for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        button.setTitleColor(.systemGray, for: .normal)

        return button
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationItem.searchController?.searchBar.resignFirstResponder()

        let s = dataSource.sections[indexPath.section]
        guard let items = s.items else { return }
        let item = items[indexPath.row]

        loadDestination(item)
    }

}

private extension MainViewController {

    func loadDestination(_ item: Item) {
        guard let destination = item.destination else { return }

        switch destination {
        case .episode:
            let controller = MainViewController()
            controller.title = item.title
            controller.episode = item.episode
            navigationController?.pushViewController(controller, animated: true)
        case .moviesSortedBy:
            // TODO: able to load more than one page of highest grossing
            let controller = MainViewController()
            controller.title = "Highest Grossing"
            controller.sortedBy = item.sortedBy
            navigationController?.pushViewController(controller, animated: true)
        case .collection:
            let controller = MainViewController()
            controller.title = item.title
            controller.collectionId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .genre:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .genreTv:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreTvId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .networks:
            let controller = MainViewController()
            controller.title = item.title
            controller.networkId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .url:
            guard let url = item.url else { return }
            UIApplication.shared.open(url)
        case .more:
            let controller = MainViewController()
            controller.items = item.items
            controller.title = "More"
            navigationController?.pushViewController(controller, animated: true)
        case .movie:
            let controller = MainViewController()
            controller.movieId = item.id
            controller.title = item.title
            navigationController?.pushViewController(controller, animated: true)
        case .person:
            let controller = MainViewController()
            controller.personId = item.id
            controller.title = item.title
            navigationController?.pushViewController(controller, animated: true)
        case .production:
            let list = MainViewController()
            list.productionId = item.id
            list.title = item.title
            navigationController?.pushViewController(list, animated: true)
        case .season:
            let controller = MainViewController()
            controller.seasonItem = item
            controller.title = item.title
            navigationController?.pushViewController(controller, animated: true)
        case .seasons:
            let controller = MainViewController()
            controller.items = item.items
            controller.title = "Seasons"
            navigationController?.pushViewController(controller, animated: true)
        case .tv:
            let controller = MainViewController()
            controller.tvId = item.id
            controller.title = item.title
            navigationController?.pushViewController(controller, animated: true)
        case
        .productionList,
        .videos:
            let controller = MainViewController()
            controller.items = item.items
            controller.title = item.title
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("did select not implemented for \(destination)")
        }
    }

}


private class DestinationButton: UIButton {
    var section: Section?
}

private extension MainViewController {

    @objc
    func handleFooterButton(_ button: DestinationButton) {

        guard
            let section = button.section,
            let s = section.destination else { return }

        switch s {
        case .castList:
            let list = MainViewController()
            list.title = "Cast"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)
        case .castTv:
            let list = MainViewController()
            list.title = "TV"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)
        case .castMovies:
            let list = MainViewController()
            list.title = "Movies"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)
        case .crewList:
            let list = MainViewController()
            list.title = "Credits"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)
        case .crewMovies:
            let list = MainViewController()
            list.title = "Movies"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)
        case .crewTv:
            let list = MainViewController()
            list.title = "TV"
            list.items = section.destinationItems
            navigationController?.pushViewController(list, animated: true)

        default:
            print("handle button not implemented for \(s)")

        }

    }

}
