//
//  DataStore.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 18.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import Foundation
import RealmSwift
import AVFoundation

struct Record {
    var audio: Data
    var name: String
    var urlString: String
    var duration: Double
}

enum RealmError: Error {
    case existingName
}

class RealmRecord: Object {
    @objc dynamic var audio = Data()
    @objc dynamic var name = ""
    @objc dynamic var urlString = ""
    @objc dynamic var duration: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "urlString"
    }
    
    convenience init(_ record: Record) {
        self.init()
        audio = record.audio
        name = record.name
        urlString = record.urlString
        duration = record.duration
    }
    
    var entity: Record {
        return Record(audio: audio,
                      name: name,
                      urlString: urlString,
                      duration: duration)
    }
}

class RecordRealmDataSource: DataSource {
    typealias T = Record
    private let realm = try! Realm()
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    
    func getAll() -> [T] {
        return realm.objects(RealmRecord.self).map {$0.entity}
    }
    func getById(id: String) -> T {
        return Record(audio: Data(), name: "", urlString: "", duration: 0.0 as Double)
    }
    func insert(item: T) {
        try! realm.write {
            realm.add(RealmRecord(item))
        }
    }
    func update(by id: String, with name: String) {
        try! realm.write {
            let predicate = NSPredicate(format: "urlString = %@", id)
            let targetRecord = realm.objects(RealmRecord.self).filter(predicate)
            targetRecord[0].name = name
        }
    }
    func clean() {
        try! realm.write {
            realm.delete(realm.objects(RealmRecord.self))
        }
    }
    func delete(item: T) {
        //realm.delete(RealmRecord(item))
    }
    func deleteById(id: String) {
        try! realm.write {
            let predicate = NSPredicate(format: "urlString = %@", id)
            let targetRecord = realm.objects(RealmRecord.self).filter(predicate)
            realm.delete(targetRecord)
        }
    }
    func checkBy(name: String) -> Bool {
        let predicate = NSPredicate(format: "name = %@", name)
        let targetRecord = realm.objects(RealmRecord.self).filter(predicate)
        if targetRecord.count == 0 {
            return false
        }
        return true
    }
    
    func getUrlByName(name: String) -> String? {
        let predicate = NSPredicate(format: "name = %@", name)
        let targetRecord = realm.objects(RealmRecord.self).filter(predicate)
        if targetRecord.count == 0 {
            return nil
        }
        return targetRecord.first?.urlString
    }
}

protocol DataSource {
    associatedtype T
    
    func getAll() -> [T]
    func getById(id: String) -> T
    func insert(item: T)
    func update(by id: String, with name: String)
    func clean()
    func delete(item: T)
    func deleteById(id: String)
    
    func getUrlByName(name: String) -> String?
}

