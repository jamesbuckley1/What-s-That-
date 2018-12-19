//
//  ViewController.swift
//  Whats That?
//
//  Created by James Buckley on 09/09/2018.
//  Copyright © 2018 James Buckley. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    
    var initialButtonAnimationTimer: Timer!
    var buttonAnimationTimer: Timer!
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    var detectedObjectName: String?
    var objectImageURL: String?
    var objectDetailsExtract: String?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        
        photoLibraryButton.layer.borderWidth = 2
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.layer.masksToBounds = true
        photoLibraryButton.titleEdgeInsets.bottom = 10
        photoLibraryButton.titleEdgeInsets.left = 10
        photoLibraryButton.titleEdgeInsets.right = 10
        photoLibraryButton.titleEdgeInsets.top = 10
        
        guard let photoLibraryButtonColor = UIColor(hexString: "2AA6F9") else {
            fatalError("Error setting UIColor")
        }
        
        photoLibraryButton.layer.borderColor = photoLibraryButtonColor.cgColor
        
        
        
        // Initialise animation timers
        
        initialButtonAnimationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pulsateCameraButton), userInfo: nil, repeats: true)
        
        buttonAnimationTimer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(pulsateCameraButton), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //buttonAnimationTimer.invalidate()
    }
    
    @objc func pulsateCameraButton() {
        initialButtonAnimationTimer.invalidate()
        cameraButton.pulsate()
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        SVProgressHUD.show()
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let ciImage = CIImage(image: selectedImage) else {
                fatalError("Could not convert image to CIImage")
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.detectImageContents(image: ciImage)
            }
            //detectImageContents(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImageContents(image: CIImage) {
        
        
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results?.first as? VNClassificationObservation else {fatalError("Could not classify image.")}
            
            self.detectedObjectName = results.identifier.capitalized
            
            //print(self.detectedObjectName)
            
            guard let objectName = self.detectedObjectName else {fatalError()}
            
            
            
            
            self.getObjectDataFromWikipedia(objectName: objectName)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func getObjectDataFromWikipedia(objectName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : objectName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let objectJSON: JSON = JSON(response.result.value!)
                self.updateObjectData(json: objectJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    //MARK: - Parse JSON
    
    func updateObjectData(json: JSON) {
        let pageId = json["query"]["pageids"][0].stringValue
        
        objectImageURL = json["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
        
        if json[0]["extract"].exists() {
            print("EXTRACT DOESNT EXIST") // This makes no sense.
            
        } else {
            objectDetailsExtract = json["query"]["pages"][pageId]["extract"].stringValue
            print("EXTRACT EXIST")
        }
        
        
        
        
        //photoImageView.sd_setImage(with: URL(string: flowerImageURL))
        //flowerInfoLabel.text = extract
        
        print(json)
        
        SVProgressHUD.dismiss()
        
        performSegue(withIdentifier: "goToObjectDetails", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToObjectDetails" {
            let destinationVC = segue.destination as! ObjectDetailsViewController
            
            guard let objectName = detectedObjectName else {fatalError()}
            
            destinationVC.objectName = objectName
            destinationVC.objectImageURL = objectImageURL
            
            //print("EXTRACT FROM VIEW \(objectDetailsExtract)")
            
            if let extract = self.objectDetailsExtract {
                destinationVC.objectDetailsExtract = extract
            }
            
        }
    }
    
    
    
    
    
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        //buttonAnimationTimer.invalidate()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    
}


