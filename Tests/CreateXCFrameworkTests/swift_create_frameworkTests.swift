import Foundation
import XCTest

final class swift_create_frameworkTests: XCTestCase {
    func testGeneratedFrameworkHasNoSignatureMetadata() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

        let sourceDirectory = temporaryDirectory.appendingPathComponent("Fixture")
        let sourcesDirectory = sourceDirectory.appendingPathComponent("Sources/Fixture")
        let outputDirectory = temporaryDirectory.appendingPathComponent("Output")
        try FileManager.default.createDirectory(at: sourcesDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        try """
        // swift-tools-version:5.9
        import PackageDescription

        let package = Package(
            name: "Fixture",
            platforms: [.macOS(.v12)],
            products: [.library(name: "Fixture", targets: ["Fixture"])],
            targets: [.target(name: "Fixture")]
        )
        """.write(to: sourceDirectory.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        try "public func example() {}\n".write(
            to: sourcesDirectory.appendingPathComponent("Fixture.swift"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("swift-create-xcframework")
        process.arguments = [
            "--package-path", sourceDirectory.path,
            "--build-path", ".build",
            "--output", outputDirectory.path,
            "--platform", "macos",
            "--xc-setting", "MACOSX_DEPLOYMENT_TARGET=12.0",
            "Fixture",
        ]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()

        XCTAssertEqual(process.terminationStatus, 0)

        let framework = outputDirectory.appendingPathComponent("Fixture.xcframework/macos-arm64_x86_64/Fixture.framework")
        XCTAssertTrue(FileManager.default.fileExists(atPath: framework.path))
        let signatureDirectories = FileManager.default.enumerator(at: framework, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { $0.lastPathComponent == "_CodeSignature" } ?? []
        XCTAssertTrue(signatureDirectories.isEmpty)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testGeneratedFrameworkHasNoSignatureMetadata", testGeneratedFrameworkHasNoSignatureMetadata),
    ]
}
