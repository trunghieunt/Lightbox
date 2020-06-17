// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Lightbox",
    // platforms: [.iOS("8.0"), .macOS("10.10"), .tvOS("9.0"), .watchOS("2.0")],
    dependencies: [
        .package(url: "https://github.com/kientux/Imaginary.git", .upToNextMajor(from: "4.4.1")),
    ],
    products: [
        .library(name: "Lightbox", targets: ["Lightbox"])
    ],
    targets: [
        .target(
            name: "Lightbox",
            path: "Source",
            dependencies: [
                "Imaginary",
            ],
        )
    ]
)
