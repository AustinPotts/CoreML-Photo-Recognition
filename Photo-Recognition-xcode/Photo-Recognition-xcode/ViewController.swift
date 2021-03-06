//
//  ViewController.swift
//  Photo-Recognition-xcode
//
//  Created by Austin Potts on 1/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imager: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    
    
    var model: SqueezeNet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model = SqueezeNet()
    }
    
    

    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
           picker.allowsEditing = false
           picker.delegate = self
           picker.sourceType = .photoLibrary
           present(picker, animated: true)
    }
    
    @IBAction func camera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
              return
          }
          
          let cameraPicker = UIImagePickerController()
          cameraPicker.delegate = self
          cameraPicker.sourceType = .camera
          cameraPicker.allowsEditing = false
          
          present(cameraPicker, animated: true)
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            photoLabel.text = "Analyzing Image..."
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 227, height: 227), true, 2.0)
            image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else {
                return
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
            
            context?.translateBy(x: 0, y: newImage.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            imager.image = newImage
        
        //Core ML
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
             
            photoLabel.text = "I think this is a \(prediction.classLabel)."
        }
    
    
    
    
}
