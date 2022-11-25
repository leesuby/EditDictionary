//
//  KeyPath.swift
//  EditDictionary
//
//  Created by LAP15335 on 25/11/2022.
//

import Foundation

struct KeyPath{
    var segments: [String]

        var isEmpty: Bool { return segments.isEmpty }
        var path: String {
            return segments.joined(separator: ".")
        }

        /// Strips off the first segment and returns a pair
        /// consisting of the first segment and the remaining key path.
        /// Returns nil if the key path has no segments.
        func headAndTail() -> (head: String, tail: KeyPath)? {
            guard !isEmpty else { return nil }
            var tail = segments
            let head = tail.removeFirst()
            return (head, KeyPath(segments: tail))
        }
}

extension KeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}


//Using for generate plain string
extension KeyPath: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}
