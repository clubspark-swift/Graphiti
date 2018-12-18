// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Graphiti",
    
    products: [
        .library(name: "Graphiti", targets: ["Graphiti"]),
    ],

    dependencies: [
        .package(url: "git@github.com:SportlabsTechnology/GraphQL.git", .revision("2f16f9e81ca8ed47ff3e974f68dc98567e2b3898")),
    ],

    targets: [
        .target(name: "Graphiti", dependencies: ["GraphQL"]),
        
        .testTarget(name: "GraphitiTests", dependencies: ["Graphiti"]),
    ]
)
