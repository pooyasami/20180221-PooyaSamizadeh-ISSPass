//
//  ViewController.swift
//  ISSPassTime
//
//  Created by Pooya Samizadeh on 2018-02-20.
//  Copyright © 2018 Pooya Samizadeh. All rights reserved.
//

import UIKit
import CoreLocation
import AFNetworking
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var resultsTableView: UITableView!
    var dataPoints: [DataPoint] = []
    
    /// refresh button action
    @IBAction func refreshAction(_ sender: Any) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        self.showProgress()
        delegate.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultsTableView.tableFooterView = UIView()
        self.showProgress()
        
        // registering for the location notification so we can monitor the location manager's notification
        NotificationCenter.default.addObserver(self, selector: #selector(locationReceived), name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
    }
    
    /// showing the progres bar
    func showProgress() {
        guard let navControllerView = self.navigationController?.view else { return }
        MBProgressHUD.showAdded(to: navControllerView, animated: true)
    }
    
    /// hiding the progress bar
    func hideProgress() {
        guard let navControllerView = self.navigationController?.view else { return }
        MBProgressHUD.hide(for: navControllerView, animated: true)
    }
    
    /// this function gets called when the location manager timer is done
    @objc func locationReceived(sender: Notification) {
        if sender.object == nil,
            let location = (UIApplication.shared.delegate as? AppDelegate)?.currentLocation {
            self.getISSData(location: location)
        } else if let error = sender.object as? AppDelegate.LocationManagerError {
            // fallback on error
            self.hideProgress()
            
            var alertMessage: String
            
            switch error {
            case .NoPremission:
                alertMessage = "The app has no location permission. Please enable it by going to the settings."
            case .NotFound:
                alertMessage = "Could not find the location, please try again."
            }
            
            self.showAlert(title: "Error", message: alertMessage)
        }
    }
    
    /// gets the ISS data and displays refreshes the tableview
    func getISSData(location: CLLocation) {
        let manager = AFHTTPSessionManager()
        
        let parameters = ["lat": location.coordinate.latitude,
                          "lon": location.coordinate.longitude,
                          "alt": location.altitude == 0 ? 0.000001 : location.altitude]
        
        manager.get("http://api.open-notify.org/iss-pass.json", parameters: parameters, progress: nil, success: { (dataTask, result) in
            
            if let response = (result as? [String: Any])?["response"] as? [[String: Any]] {
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: response, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let decoder = JSONDecoder()
                    let resultsArray = try decoder.decode([DataPoint].self, from: data)
                    
                    self.dataPoints = resultsArray
                    self.resultsTableView.reloadData()
                    
                    self.hideProgress()
                } catch {
                    // handle error here
                    self.hideProgress()
                }
            }
        }) { (data, error) in
            self.showAlert(title: "Error", message: "Could not retrieve data.")
        }
    }
    
    /// helper function for showing error the alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
        let dataPoint = self.dataPoints[indexPath.row]
        
        if let duration = dataPoint.duration {
            cell.textLabel?.text = "Duration: \(duration)"
        }
        
        cell.detailTextLabel?.text = dataPoint.riseTimeDate?.formatDataPointDate

        return cell
    }
}

