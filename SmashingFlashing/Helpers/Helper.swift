//
//  Helper.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 09.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import Foundation

class Helper {
    func removeFileAtURLIfExists(url: URL) { 
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let urlNew = NSURL(fileURLWithPath: path)
        if let pathComponent = urlNew.appendingPathComponent(url.lastPathComponent) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                do{
                    try fileManager.removeItem(atPath: filePath)
                } catch let error as NSError {
                    print("-----Couldn't remove existing destination file: \(error)")
                }
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
}

struct DocsDirectory {
    static let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

