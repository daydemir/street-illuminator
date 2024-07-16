//
//  extensions.swift
//
//
//  Created by Deniz Aydemir on 7/5/24.
//

import Foundation

public extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


//from https://digitalbunker.dev/converting-codable-models-to-csv/
public extension Collection where Element: Codable {
    func toCSV() -> String {
        var csvString = ""

        // Reflection to get property names for the header row
        if let firstItem = self.first {
            let mirror = Mirror(reflecting: firstItem)
            let headers = mirror.children.compactMap { $0.label }
            csvString += headers.joined(separator: ",") + "\n"
        }

        // Convert each instance to a CSV row
        for item in self {
            let mirror = Mirror(reflecting: item)
            let values = mirror.children.map { child -> String in
                let value = "\(child.value)"

                // Basic escaping; handles potential commas and quotes in values
                if value.contains(",") || value.contains("\"") {
                    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return value
            }

            // This trailing newline is required for a valid .csv file
            csvString += values.joined(separator: ",") + "\n"
        }

        return csvString
    }
}

// Usage
// convertToCSV(employees)
//
// Output
// id,name,department
// 1,Alice,HR
// 2,Bob,IT
// 3,Charlie,Finance
//
