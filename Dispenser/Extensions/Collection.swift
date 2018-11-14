import Foundation

extension Collection where Element: Hashable {
    var orderedSet: [Element] {
        var set: Set<Element> = []
        return reduce(into: []) { set.insert($1).inserted ? $0.append($1) : () }
    }
}
