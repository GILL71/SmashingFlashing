//
//  FileName.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 30.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import Foundation

enum RecordingAction {
    case finish
    case cancel
    case symbolValidation
}

class FileName {
    
    var storage = RecordRealmDataSource()
    var fileName: String {
        var count = storage.getAll().count
        while true {
            if storage.checkBy(name: "audio" + String(count) + ".m4a") {
                print("this name exists")
                count += 1
            } else {
                return String(count) + ".m4a"
            }
        }
    }
    
    func checkNewFile(name: inout String?) -> RecordingAction {
        
        //пустое - cancel
        if name == nil || name == ""{
            return .cancel
        }
        //содержит недопустимые символы - cancel
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if name!.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            return .symbolValidation
        }
        //исключили выше наличие . в имени файла
        name!.append(".m4a")
        
        //такое существует - finish с заменой
        //верно - finish
        if storage.checkBy(name: name!) {
            name = fileName
            print("this name exists")
        }
        return .finish
    }
}
