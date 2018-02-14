//
//  SlideButtonAction.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 31.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import Foundation
import UIKit

class SBAction {
    var storage = RecordRealmDataSource()
    let fileName = FileName()
    
    func delete(_ record: Record) {
        guard let url = URL(string: getUrl(for: record.name)) else {
            print("ERROR: INVALID DELETING URL")
            return
        }
        do {
            try FileManager().removeItem(at: url)
            //storage.deleteById(id: record.urlString)
            storage.deleteById(id: record.name)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func update(_ record: Record, on controller: RecordsList) {
        let actionSheetController = UIAlertController(title: "",
                                                      message: "Rename?",
                                                      preferredStyle: .alert)
        
        actionSheetController.addTextField(configurationHandler: self.configurationTextField)
        
        let renameAction = UIAlertAction(title: "Update", style: .default) { action -> Void in
            var name = actionSheetController.textFields?[0].text
            switch self.fileName.checkNewFile(name: &name) {
            case .finish:
                guard var url = URL(string: self.getUrl(for: record.name)) else {
                    print("ERROR: INVALID UPDATING URL")
                    return
                }
                var resourceValues = URLResourceValues.init()
                resourceValues.name = name
                do {
                    try url.setResourceValues(resourceValues)
                    //self.storage.update(by: record.urlString, with: name!)
                    //update old name and new name...???
                    self.storage.update(instead: record.name, by: name!)
                } catch {
                    print(error.localizedDescription)
                }
            case .cancel:
                print("ERROR: INVALID NAME")
            case .symbolValidation:
                let alert = UIAlertController(title: "Error: please enter name using latin characters!",
                                              message: "Filename contains invalid characters",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                controller.present(alert, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(renameAction)
        let cancelAction = UIAlertAction(title: "back", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "New file name"
    }
    //docsDir exchange to DocsDirectory.path
    private func getUrl(for name: String) -> String {
        let urlString = "file:"
        return urlString.appending(storage.documentsDirectory.appending("/" + name))
    }
}

