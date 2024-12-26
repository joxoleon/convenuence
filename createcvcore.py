import os

# Base directory for the CVCore package
base_dir = "./CVCore"

# Define the folder structure for the package
folder_structure = [
    "Sources/CVCore/Networking",
    "Sources/CVCore/Persistence",
    "Sources/CVCore/Services",
    "Tests/CVCoreTests/Networking",
    "Tests/CVCoreTests/Persistence",
    "Tests/CVCoreTests/Services"
]

# Create the folder structure
for folder in folder_structure:
    os.makedirs(os.path.join(base_dir, folder), exist_ok=True)

# Initialize basic files for the package
files_to_create = {
    "Sources/CVCore/CVCore.swift": "// Entry point for the CVCore package\n\npublic struct CVCore {}",
    "Tests/CVCoreTests/CVCoreTests.swift": "// Entry point for CVCore tests\n\nimport XCTest\n@testable import CVCore\n\nfinal class CVCoreTests: XCTestCase {}",
    "Package.swift": """// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CVCore",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "CVCore",
            targets: ["CVCore"]),
    ],
    targets: [
        .target(
            name: "CVCore",
            dependencies: []),
        .testTarget(
            name: "CVCoreTests",
            dependencies: ["CVCore"]),
    ]
)
"""
}

# Write the initial files
for file_path, content in files_to_create.items():
    full_path = os.path.join(base_dir, file_path)
    with open(full_path, "w") as file:
        file.write(content)

base_dir
