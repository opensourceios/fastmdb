//
//  Extensions.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension String {
    
    var dateDisplay: String? {
        let formatter = Tmdb.dateFormatter

        guard let date = formatter.date(from: self) else { return nil }

        formatter.dateFormat = "MMM d, yyyy"

        return formatter.string(from: date)
    }

    var justWatchUrl: URL? {
        let baseUrl = "https://www.justwatch.com/us/search?q="
        let item = self.replacingOccurrences(of: " ", with: "+")

        return URL(string: "\(baseUrl)/\(item)")
    }

    var wikipediaUrl: URL? {
        let baseUrl = "https://en.wikipedia.org/wiki"
        let item = self.replacingOccurrences(of: " ", with: "_")
        
        return URL(string: "\(baseUrl)/\(item)")
    }

}

extension Optional where Wrapped == String {

    var yearDisplay: String {
        guard
            let date = self,
            let index = date.firstIndex(of: "-") else { return "" }

        return String(date[..<index])
    }

}

/// Credits: https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
extension Sequence where Iterator.Element: Hashable {

    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }

}
