//
//  AudioTableViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 18.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import RealmSwift
import UIKit

class AudioTableViewController: UITableViewController {
    
    let records: Results<RealmRecord> = {
        let realm = try! Realm()
        return realm.objects(RealmRecord.self).sorted(byKeyPath: "urlString", ascending: true)
    }()
    var token: NotificationToken?
    //var player = Player()
    //let buttonActions = SBAction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        token = records.observe {[unowned self] (changes: RealmCollectionChange) in
            guard let tableView = self.tableView else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(let results, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                //CHANGE!
                for row in modifications {
                    let indexPath = IndexPath(row: row, section: 0)
                    let record = results[indexPath.row]
                    if let cell = tableView.cellForRow(at: indexPath) as? AudioTableViewCell {
                        cell.configureWith(record)
                    } else {
                        print("cell not found for \(indexPath)")
                    }
                }
                tableView.endUpdates()
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! AudioTableViewCell
        
        return cell
    }
}
