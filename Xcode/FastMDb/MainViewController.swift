//
//  ViewController.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SafariServices // TODO: swap out safari controller with custom image controller

// TODO: list pagination!

enum ScreenType {
    case landing, list, detail, search
}

struct DataSource {
    var screen: ScreenType
    var kind: Tmdb.MoviesType?
    var sections: [Section] = []
}

class MainViewController: UIViewController {

    // List
    var collectionId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            guard let url = Tmdb.collectionURL(collectionId: collectionId) else { return }

            spinner.startAnimating()

            url.apiGet(type: MediaCollection.self) { (result) in
                guard
                    case .success(let collection) = result,
                    let list = collection.parts?
                        .sorted(by: { $0.release_date ?? "" > $1.release_date ?? "" })
                        .map({ $0.listItem }) else { return }

                let buttonUrl = Tmdb.mediaPosterUrl(path: collection.poster_path, size: .xl)
                self.imageButton.url = buttonUrl

                let url = Tmdb.mediaPosterUrl(path: collection.poster_path, size: .large)
                self.getImage(url: url) { (image) in
                    self.dataSource.sections = [ Section(items: list) ]
                    self.updateUI(image)
                    // TODO: change updateUI and more to support showing backdrop (variable height)
                }
            }
        }
    }

    var genreTvId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            guard let url = Tmdb.tvURL(genreId: genreTvId) else { return }

            spinner.startAnimating()

            url.apiGet(type: TvSearch.self) { (result) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var genreId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            guard let url = Tmdb.moviesURL(genreId: genreId) else { return }

            spinner.startAnimating()

            url.apiGet(type: MediaSearch.self) { (result) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var networkId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            guard let url = Tmdb.tvURL(networkId: networkId) else { return }

            spinner.startAnimating()

            url.apiGet(type: TvSearch.self) { (result) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var productionId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)
            spinner.startAnimating()
            updateProduction(productionId)
        }
    }

    var seasonItem: Item? {
        didSet {
            dataSource = DataSource(screen: .list)

            spinner.startAnimating()

            guard let season = seasonItem else { return }

            let url = Tmdb.tvURL(tvId: season.id, seasonNumber: season.seasonNumber)
            url?.apiGet(type: EpisodeList.self, completion: { (result) in
                guard
                    case .success(let r) = result,
                    let episodes = r.episodes else { return }

                let items = episodes.map { $0.listItem }
                let section = Section(items: items)
                self.dataSource.sections = [section]
                self.updateUI()
            })
        }
    }

    var items: [Item]? {
        didSet {
            let section = Section(items: items)
            let sections = [section]
            dataSource = DataSource(screen: .list, sections: sections)
            self.updateUI()
        }
    }

    var sortedBy: String? {
        didSet {
            dataSource = DataSource(screen: .list)

            guard let url = Tmdb.moviesURL(sortedBy: sortedBy) else { return }

            spinner.startAnimating()

            url.apiGet(type: MediaSearch.self) { (result) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    // Detail
    var movieId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updateMovie(movieId)
        }
    }

    var personId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updatePerson(personId)
        }
    }

    var tvId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updateTv(tvId)
        }
    }

    var episode: Episode? {
        didSet {
            dataSource = DataSource(screen: .detail)
            updateEpisode(episode)
        }
    }

    // Data
    var dataSource = DataSource(screen: .landing, kind: .popular)
    var search = TableSearch()

    // UI
    fileprivate var imageButton = ImageButton()
    let spinner = UIActivityIndicatorView(style: .large)
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
        config()
        loadContent(dataSource.kind)
    }

    deinit {
        print("deinit")
    }

}

private extension MainViewController {

    func setup() {
        tableView.register(MainListCell.self, forCellReuseIdentifier: MainListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.delegate = self
        navigationItem.searchController = search

        navigationController?.navigationBar.tintColor = .systemTeal

        let interaction = UIContextMenuInteraction(delegate: self)
        imageButton.addInteraction(interaction)
        // TODO: change bounds of image button, right now width is full
    }

    func config() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        if dataSource.screen == .landing {
            let image = UIImage(systemName: "shuffle")
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBarButton))
            navigationItem.rightBarButtonItem = barButtonItem
        }
        else {
            let image = UIImage(systemName: "house")
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goHome))
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }

}

private class ImageButton: UIButton {
    var url: URL?
}

extension MainViewController {
    func loadContent(_ kind: Tmdb.MoviesType?) {

        guard let kind = kind else { return }

        spinner.startAnimating()

        dataSource.kind = kind
        title = kind.title

        self.dataSource.sections = []
        self.updateUI()

        let provider = ContentDataProvider()
        provider.get(kind) { (movie, tv, people) in
            self.dataSource.sections = Section.contentSections(kind: kind, movie: movie, tv: tv, people: people)
            self.updateUI()
        }
    }

    func updateUI(_ image: UIImage? = nil) {
        // TODO: show banner instead? looks better on ipad
        // TODO: ipad should have bigger margins
        if let image = image {
            tableView.tableHeaderView = header
            self.imageButton.setImage(image, for: .normal)
        }

        spinner.stopAnimating()

        tableView.reloadData()
    }

}

private extension MainViewController {

    @objc
    func goHome() {
        navigationController?.popToRootViewController(animated: true)

        // TODO: fix crash when searching

        // TODO: seeing assert warning

        /**
         steps
         launch app
         tap on movie
         tap on box office
         tap on movie
         tap on box office
         tap on movie
         tap on home

         2020-05-10 21:09:14.775267-0700 FastMDb[78921:13778251] [Assert] Unexpected configuration of navigation stack. viewControllers = (
         "<FastMDb.MainViewController: 0x7f821b81ea00>"
         ), stack.items = (
         "<UINavigationItem: 0x7f821a40d8a0> title='Popular' rightBarButtonItems=0x600003520750 searchController=0x7f821b848e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a62f3e0> title='Ad Astra' rightBarButtonItems=0x600003521260 searchController=0x7f821b02b200 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a5433c0> title='Highest Grossing' rightBarButtonItems=0x60000352d1b0 searchController=0x7f821c016400 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a63f730> title='Titanic' rightBarButtonItems=0x600003527270 searchController=0x7f821b019e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a72a570> title='Highest Grossing' rightBarButtonItems=0x60000352d5c0 searchController=0x7f821c02ca00 hidesSearchBarWhenScrolling"
         )*/
    }

    @objc
    func handleBarButton() {
        if let kind = dataSource.kind {
            let list = Tmdb.MoviesType.allCases.filter { $0.rawValue != kind.rawValue }
            let random = list.randomElement() ?? .popular

            loadContent(random)
        }
    }

    @objc func imageTap(sender: ImageButton) {
        guard let url = sender.url else { return }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet
        present(sfvc, animated: true, completion: nil)
    }

    var header: UIView {
        let headerView = UIView()

        var frame = view.bounds
        let inset: CGFloat = 20
        frame.size.height = 278 + (2 * inset)
        headerView.frame = frame

        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(imageTap), for: .touchUpInside)

        headerView.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: inset),
            imageButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: inset),
            imageButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -inset),
            imageButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -inset),
        ])

        return headerView
    }

}

private extension MainViewController {
    func getImage(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let image = UIImage(data: data)

            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

private extension MainViewController {

    func updateEpisode(_ episode: Episode?) {
        self.dataSource.sections = Section.episodeSections(episode)
        self.updateUI()
    }

    func updateMovie(_ movieId: Int?, limit: Int = Constant.numberOfEntries) {
        let provider = MovieDataProvider()
        provider.get(movieId) { (movie) in
            guard let movie = movie else { return }

            self.dataSource.sections = Section.movieSections(movie: movie, limit: limit)

            let buttonUrl = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .xxl)
            self.imageButton.url = buttonUrl

            let url = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .large)
            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

    func updatePerson(_ personId: Int?, limit: Int = Constant.numberOfEntries) {
        let provider = PersonDataProvider()
        provider.get(personId) { (credit) in
            guard let credit = credit else { return }

            self.dataSource.sections = Section.personSections(credit: credit, limit: Constant.numberOfEntries)

            let buttonUrl = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            self.imageButton.url = buttonUrl

            let url = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

    func updateProduction(_ productionId: Int?) {
        let provider = ProductionDataProvider()
        provider.get(productionId) { (movie, tv) in
            var sections: [Section] = []

            if let section = Section.sectionForMovieSearch(movie) {
                sections.append(section)
            }

            if let section = Section.sectionForTvSearch(tv) {
                sections.append(section)
            }

            self.dataSource.sections = sections
            self.updateUI()
        }
    }

    func updateTv(_ id: Int?, limit: Int = Constant.numberOfEntries) {
        let provider = TvDataProvider()
        provider.get(id) { (tv) in
            guard let tv = tv else { return }

            self.dataSource.sections = Section.tvSections(tv, limit: limit)

            let buttonUrl = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .xxl)
            self.imageButton.url = buttonUrl

            let url = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .large)

            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

}

private struct Constant {
    static let numberOfEntries = 10
}

private extension Episode {
    var listItem: Item {
        var sub: [String] = []

        if let episodeNumber = episode_number {
            sub.append("Episode \(episodeNumber)")
        }

        if let airDate = air_date?.dateDisplay {
            sub.append(airDate)
        }

        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator), destination: .episode, episode: self)
    }
}

private extension Section {
    static func contentSections(kind: Tmdb.MoviesType, movie: MediaSearch?, tv: TvSearch?, people: PeopleSearch?) -> [Section] {
        var sections: [Section] = []

        if let movie = movie {
            let items = movie.results.map { $0.listItem }
            let section = Section(header: "movies\(Tmdb.separator)\(kind.title)", items: items)
            sections.append(section)
        }

        if let tv = tv {
            let items = tv.results.map { $0.listItem }
            let section = Section(header: "tv\(Tmdb.separator)\(kind.tv.title)", items: items)
            sections.append(section)
        }

        if let people = people {
            let items = people.results.map { $0.listItem }
            let section = Section(header: "people\(Tmdb.separator)\(kind.title)", items: items)
            sections.append(section)
        }

        return sections
    }
}

extension MainViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: sfvc, actionProvider: nil)
    }

    private func sfvc() -> UIViewController? {
        guard let url = imageButton.url else { return nil }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet

        return sfvc
    }
}
