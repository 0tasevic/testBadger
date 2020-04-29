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
    let deviceCellID = "deviceTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.register( UINib(nibName: "DeviceTableViewCell", bundle: nil) , forCellReuseIdentifier: deviceCellID)
        self.connection.searchingDelegate = self
    }

    @IBAction func buttonPressed(_ sender: Any) {
        self.connection.writeValue()
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
