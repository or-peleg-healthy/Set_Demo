//
//  Theme.swift
//  Concentration_Demo
//
//  Created by Or Peleg on 14/04/2022.
//

import Foundation

enum Theme {
    static var emojiRanges = [
            "faces": 0x1F600...0x1F609,
            "gestures": 0x1F645...0x1F64E,
            "vehicles": 0x1F681...0x1F68A,
            "animals": 0x1F42A...0x1F433,
            "landscapes": 0x1F300...0x1F309,
            "stars": 0x1F311...0x1F320 ]
    
    static func randomTheme() -> [String] {
        let themeOptions = Array(emojiRanges.keys)
        let theme = themeOptions.randomElement() ?? "faces"
        var emojiChoices = [String]()
        for i in emojiRanges[theme]! {
            let char = String(Unicode.Scalar(i)!)
            emojiChoices.append(char)
        }
        return emojiChoices
    }
    
    static func createNew(theme: String, range: ClosedRange<Int>) {
        self.emojiRanges[theme] = range
    }
    
    static func make(themeName: String) -> [String] {
        var emojiChoices = [String]()
        for i in emojiRanges[themeName]! {
            let char = String(Unicode.Scalar(i)!)
            emojiChoices.append(char)
        }
        return emojiChoices
    }
}
