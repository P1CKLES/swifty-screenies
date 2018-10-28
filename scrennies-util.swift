//
//  screenies.swift
//  Screenies
//
//  Created by Shannon Lucas on 8/18/18.
//  Copyright © 2018 Pickles. All rights reserved.
//

import Foundation
import Cocoa

public class screenShot {
    
    func screenie(path: String) {
        
        var displayCount: UInt32 = 0
        var result = CGGetActiveDisplayList(3, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
        }
        
        for i in 1...displayCount {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let unixTimeStamp = formatter.string(from: date)
            let fileUrl = URL(fileURLWithPath: path + "/" + "\(unixTimeStamp)" + "_" + "\(i)" + ".txt", isDirectory: true)
            let screenShot: CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            let b64jpeg = jpegData.base64EncodedString()
            
            do {
                try b64jpeg.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch {print("error: \(error)")}
        }
    }
    
    func decodeImage(path: String, cmdArg2: String) {
        if cmdArg2 != "-d" {
            print("Unknown option, use '-d' to decode file")
            exit(0)
        } else {
        }
        let outPath = path.replacingOccurrences(of: ".txt", with: ".jpg")
        let fileURL = URL(fileURLWithPath: path)
        let outURL = URL(fileURLWithPath: outPath)
        
        do {
            let text = try String(contentsOf: fileURL)
            let decoded = Data(base64Encoded: text)
            try decoded?.write(to: outURL, options: .atomic)
            let fileManager = FileManager.default
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Oooops, something went wrong!")
        }
    }
    
    func displayUsage() {
        print("\u{001B}[0;35m[*] Usage: \u{001B}[0;32m'./Screenies /Users/tester/Pictures/screenies' \n\u{001B}[0;35m[*] To Decode: \u{001B}[0;32m'./Screenies /Users/tester/Pictures/screenies/2018-08-18_165730_1.txt -d'\u{001B}[0;0m")
    }
}