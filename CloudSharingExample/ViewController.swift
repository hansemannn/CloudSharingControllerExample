//
//  ViewController.swift
//  CloudSharingExample
//
//  Created by Hans Knöchel on 14.06.16.
//  Copyright © 2016 Appcelerator. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UICloudSharingControllerDelegate {

    @IBAction func didTapCloudSharingButton() {
        
        let cloudSharingController = UICloudSharingController(preparationHandler: { controller, preparationCompletionHandler in
            
            // Create image record
            let fileName = "titanium_mobile"
            let newRecord = CKRecord(recordType: "ImageRecord", recordID: CKRecordID(recordName: "test"))
            let image = UIImage(named: fileName)

            // Write to filesystem
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let imageFilePath = (documentDirectory as NSString).appendingPathComponent(fileName)
            let myUrl = URL(fileURLWithPath: imageFilePath)
            
            do {
                let data = UIImagePNGRepresentation(image!)
                try data?.write(to: myUrl, options: .atomicWrite)
                let asset = CKAsset(fileURL: myUrl)
                
                newRecord["image"] = asset
            } catch {
                print("Could not write to filesystem")
            }
            
            // Initialize cloud sharing
            let share: CKShare = CKShare(rootRecord: newRecord)
            share[CKShareTitleKey] = "\(fileName).png" as CKRecordValue
            share[CKShareTypeKey] = "com.appcelerator.CloudSharingExample" as CKRecordValue
            
            // Prepare records
            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [newRecord, share], recordIDsToDelete: nil)
            
            modifyRecordsOperation.timeoutIntervalForRequest = 15
            modifyRecordsOperation.timeoutIntervalForResource = 15
            
            modifyRecordsOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
                if error != nil {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
                preparationCompletionHandler(share, CKContainer.default(), error)
            }
            
            OperationQueue().addOperation(modifyRecordsOperation)
        })
        
        // Set sharing delegate
        cloudSharingController.delegate = self
        
        // Set sharing permissions
        cloudSharingController.availablePermissions = [.allowPublic, .allowReadOnly]
        
        // Show cloud shareing dialog
        self.present(cloudSharingController, animated: true, completion: nil)
    }
    
    // MARK: CloudKit Delegates
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "titanium_mobile.png"
    }
    
    @available(iOS 10.0, *)
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failedToSaveShareWithError: \(error.localizedDescription)")
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidSaveShare")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidStopSharing")
    }
}

