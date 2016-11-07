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
        
        // Create image record
        let fileName = "titanium_mobile"
        let newRecord = CKRecord(recordType: "ImageRecord", recordID: CKRecordID(recordName: "test"))
        let image = UIImage(named: fileName)
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imageFilePath = (documentDirectory as NSString).appendingPathComponent(fileName)
        
        do {
            try UIImagePNGRepresentation(image!)?.write(to: URL(fileURLWithPath: imageFilePath), options: .atomicWrite)
        } catch {
            print("Could not write to filesystem")
        }
        
        let asset = CKAsset(fileURL: NSURL(fileURLWithPath: imageFilePath) as URL)
        newRecord.setObject(asset, forKey: "ProfilePicture")
        
        // Initialize cloud sharing
        let share: CKShare = CKShare(rootRecord: newRecord)
        share[CKShareTitleKey] = "\(fileName).png" as CKRecordValue?
        share[CKShareTypeKey] = "com.appsird.Touring-Engine" as CKRecordValue
        
        let container: CKContainer = CKContainer(identifier: "Test")
        let cloudSharingController: UICloudSharingController = UICloudSharingController(share: share, container: container)
        cloudSharingController.delegate = self
        
        // Set sharing permissions
        cloudSharingController.availablePermissions = [.allowPublic, .allowReadOnly]
        
        // Show cloud shareing dialog
        self.present(cloudSharingController, animated: true, completion: nil)
    }
    
    // MARK: CloudKit Delegates

    public func itemTitle(for csc: UICloudSharingController) -> String? {
        return "here"
    }

    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidSaveShare")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidStopSharing")
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failedToSaveShareWithError: \(error.localizedDescription)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

