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
            exclude: ["en.lproj/",
                      "KOKeyboard-Info.plist",
                      "KOKeyboard-Prefix.pch",
                      "KOAppDelegate.h",
                      "KOAppDelegate.m",
                      "KOViewController.h",
                      "KOViewController.m",
                      "Regular Expression Keys/",
                      "gitignore.txt",
                      "main.m"],
            resources: [
              .process("key-blue@2x.png"),
              .process("hal-white.png"),
              .process("hal-black.png"),
              .process("key.png"),
              .process("key-pressed@2x.png"),
              .process("hal-black@2x.png"),
              .process("hal-blue@2x.png"),
              .process("hal-blue.png"),
              .process("key-blue.png"),
              .process("key-pressed.png"),
              .process("hal-white@2x.png"),
              .process("key@2x.png")
            ]
        )
    ]
)
