//
//  RecordsList.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 30.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift

class RecordsList: UITableViewController {
    
    let records: Results<RealmRecord> = {
        let realm = try! Realm()
        return realm.objects(RealmRecord.self).sorted(byKeyPath: "name", ascending: true)
    }()
    var token: NotificationToken?
    var player = Player()
    let buttonActions = SBAction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cell.configureWith(records[indexPath.row])
        
        cell.rightButtons =
            [MGSwipeButton(title: "Delete", backgroundColor: .red) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.buttonActions.delete(self.records[indexPath.row].entity)
                return true
                },
             MGSwipeButton(title: "Rename", backgroundColor: .green) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.buttonActions.update(self.records[indexPath.row].entity, on: self)
                return true
                }]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? WalkmanViewController {
            destinationViewController.sendedIndex = (self.tableView.indexPathForSelectedRow?.row)!
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

