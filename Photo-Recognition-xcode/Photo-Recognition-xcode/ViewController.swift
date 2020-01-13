//
//  ViewController.swift
//  Photo-Recognition-xcode
//
//  Created by Austin Potts on 1/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imager: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
}
