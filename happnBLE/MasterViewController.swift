//
//  MasterViewController.swift
//  happnBLE
//
//  Created by Julien SECHAUD on 05/12/2018.
//  Copyright © 2018 Moana et Archibald. All rights reserved.
//

import UIKit
import CoreBluetooth


struct Peripheral {
    var cbPeripheral: CBPeripheral
    var advertisementData: [String : Any]
}


extension MasterViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print("service : \(service)")
        }
    }
    
}

extension MasterViewController: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard discoveredPeripherals.filter({$0.cbPeripheral == peripheral}).count == 0 else {return}
        print("didDiscover : \(peripheral.name ?? "UNKNOWN")")
        discoveredPeripherals.append(Peripheral(cbPeripheral: peripheral, advertisementData: advertisementData))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        present(UIAlertController(title: "OK", message: nil, preferredStyle: .alert), animated: true, completion: nil)
        print("didConnect : \(peripheral.name ?? "UNKNOWN")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        present(UIAlertController(title: "OK", message: error.debugDescription, preferredStyle: .alert), animated: true, completion: nil)
        print("didFailToConnect : \(error.debugDescription)")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        discoveredPeripherals = []
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

}

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var centralManager: CBCentralManager?
    var discoveredPeripherals: [Peripheral] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)

        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let peripheral = discoveredPeripherals[indexPath.row]
        cell.textLabel!.text = peripheral.cbPeripheral.name == nil ? "UNKNOWN" : peripheral.cbPeripheral.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager?.connect(discoveredPeripherals[indexPath.row].cbPeripheral, options: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
    }


}

