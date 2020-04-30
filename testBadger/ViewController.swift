//
//  ViewController.swift
//  testBadger
//
//  Created by Milos Otasevic on 29/04/2020.
//  Copyright © 2020 Milos Otasevic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ConnectionRequirement {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var galleryButton: UIButton!

    let deviceCellID = "deviceTableViewCell"
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.register( UINib(nibName: "DeviceTableViewCell", bundle: nil) , forCellReuseIdentifier: deviceCellID)
        self.connection.searchingDelegate = self
    }

    @IBAction func buttonPressed(_ sender: Any) {
        self.connection.writeValue(image: self.image)
    }
    
    
      @IBAction func addPhotosButtonPressed(_ sender: Any) {
            let image = UIImagePickerController()
            image.delegate = self
            image.allowsEditing = false

            let actionSheet = UIAlertController(title: "Photo Sourec", message: "Choose a source", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
                image.sourceType = .camera

                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    self.present(image, animated:  true, completion: nil)
                }else{
                    print("Camera not avaliable")
                }
            }))
                actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
                    image.sourceType = .photoLibrary
                    self.present(image, animated:  true, completion: nil)

                }))
            self.present(actionSheet, animated: true, completion: nil)
    //        image.sourceType = .photoLibrary
    //        image.allowsEditing = true
    //
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connection.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.deviceCellID, for: indexPath)
        guard let deviceCell = cell as? DeviceTableViewCell else {return cell}
        deviceCell.deviceNameLabel.text = self.connection.peripherals[indexPath.row].name ?? "no name"
        return deviceCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connection.connectToPeriferal(position: indexPath.row)
        self.table.isHidden = true
        self.button.isHidden = false
        self.galleryButton.isHidden = false

    }
}

extension ViewController: ConnectionSearchingDelegate{
    func searchStart() {
        return
    }
    
    func searchEnd(userDeviceFound: Bool) {
        self.table.reloadData()
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.image = image 
        }else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.image = image
        }else{
            print("GRESKA")
        }
        self.dismiss(animated: true) {
        }
    }
}
