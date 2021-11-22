// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KOKeyboard",
    products: [
        .library(
          name: "KOKeyboard",
          targets: ["KOKeyboard"]),
    ],
    targets: [
        .target(
            name: "KOKeyboard",
            dependencies: [],
            path: "KOKeyboard",
            exclude: ["KOKeyboard-Info.plist",
                      "KOKeyboard-Prefix.pch",
                      "KOAppDelegate.h",
                      "KOAppDelegate.m",
                      "KOViewController.h",
                      "KOViewController.m",
                      "Regular Expression Keys/",
                      "gitignore.txt",
                      "main.m"]
        )
    ]
)
