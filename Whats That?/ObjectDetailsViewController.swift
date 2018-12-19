//
//  ObjectDetailsViewController.swift
//  Whats That?
//
//  Created by James Buckley on 09/09/2018.
//  Copyright © 2018 James Buckley. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ObjectDetailsViewController: UIViewController {
    
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var objectDetailsLabel: UILabel!
    
    
    var objectName: String?
    var objectImageURL: String?
    var objectDetailsExtract: String?
    
    override func viewDidLoad() {
        
        guard let objectName = self.objectName else {fatalError("Did not get object name.")}
        objectNameLabel.text = objectName
        
        guard let objectImageURL = self.objectImageURL else {fatalError("Did not get object image URL")}
        
        if let objectDetailsExtract = self.objectDetailsExtract {
            print("Extract found")
            objectDetailsLabel.text = objectDetailsExtract
        }
        
        print("IMAGE URL \(objectImageURL)")
        
        objectImageView.sd_setImage(with: URL(string: objectImageURL))
        
        
        
    }
    
}

