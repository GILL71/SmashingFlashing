//
// AudioRecordsViewController.swift
// SmashingFlashing
//
// Created by Vladimir Orlov on 09.02.2018.
// Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import UIKit
import RealmSwift

class AudioRecordsViewController: UITableViewController {
  
  //MARK: - Instance variables
  let records: Results<RealmRecord> = {
    let realm = try! Realm()
    return realm.objects(RealmRecord.self).sorted(byKeyPath: "name", ascending: true)
  }()
  var delegate : SavingViewControllerDelegate?
  var videoURL: URL?
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return records.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "popoverCell", for: indexPath)
    cell.textLabel?.text = records[indexPath.row].name
    
    return cell
  }
  
  //MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let videoURL = videoURL {
      let merger = TrueMerger(audioName: records[indexPath.row].name, video: videoURL)
      DispatchQueue.main.async {
//        if (self.delegate) != nil
//        {
//            delegate?.saveText(textField.text)
//            self.dismissViewControllerAnimated(true, nil)
//        }
        self.dismiss(animated: true)
        guard let url = merger.mergeMutableVideoWithAudio(completion: {
          print("Success")
        }) else { fatalError("Shit.") }
      }
    }
  }
  
}
