//
//  PrivacyManifest.swift
//  swift-create-xcframework
//

import Foundation

enum PrivacyManifest {
    static let filename = "PrivacyInfo.xcprivacy"

    static func discover(in resources: [URL]) throws -> URL? {
        let manifests = try resources.flatMap { try PrivacyManifest.manifests(in: $0) }

        if manifests.isEmpty {
            return nil
        }

        if manifests.count == 1 {
            return manifests[0]
        }

        throw Error.multipleManifests(manifests)
    }

    private static func manifests(in resource: URL) throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resource.path, isDirectory: &isDirectory) else {
            return []
        }

        if !isDirectory.boolValue {
            return resource.lastPathComponent == filename ? [resource] : []
        }

        guard let enumerator = FileManager.default.enumerator(
            at: resource,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return enumerator
            .compactMap { $0 as? URL }
            .filter { $0.lastPathComponent == filename }
    }

    enum Error: Swift.Error, LocalizedError {
        case multipleManifests([URL])

        var errorDescription: String? {
            switch self {
            case let .multipleManifests(manifests):
                return "Found multiple \(filename) resources: \(manifests.map(\.path).joined(separator: ", "))"
            }
        }
    }
}
