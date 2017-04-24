//
//  ViewController.swift
//  TwitterHashtagDemo
//
//  Created by Mac on 4/24/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var serviceWrapper: TwitterServiceWrapper = TwitterServiceWrapper()
    var hashTagImages = [TwitterImages]()
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var oneMonthBackDate = " "
    
    let activityIndicator = ActivityIndiactorView(text: "Searching")
    
    // A default location to use when location permission is not granted.
    var defaultLocation = CLLocation(latitude: +13.04003506, longitude: +80.21439496)
    let distance = "10mi"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceWrapper.delegate = self

        //CLLocation manager delegates and check authorization
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let result = formatter.string(from: currentDate)
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        oneMonthBackDate = formatter.string(from: oneMonthAgo!)
        print("Current Date: \(result) ; One Month Back: \(oneMonthBackDate)")
        
        let searchString = "#IPL"
        let encodedUrl = searchString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        serviceWrapper.getResponseForRequest("\(kTwitterSearchAPI)q=\(encodedUrl!)&geocode=\(defaultLocation.coordinate.latitude),\(defaultLocation.coordinate.longitude),\(distance)&count=100&since=\(oneMonthBackDate)")
        self.view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}


//------------------------------------------------------
// MARK: - TwitterImagesDelegate
//------------------------------------------------------


extension ViewController:TwitterImagesDelegate{
    func finishedDownloading(_ twitterImages: TwitterImages) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.hashTagImages.append(twitterImages)
            self.tableView.reloadData()
            self.activityIndicator.removeFromSuperview()
        })
    }
    
    func dataNotFound() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.activityIndicator.removeFromSuperview()
        })
    }
}

//------------------------------------------------------
// MARK: - UISearchBarDelegate
//------------------------------------------------------

extension ViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
        let encodedSearchTag = searchBar.text!.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        if let encodedSearchTag = encodedSearchTag {
            print(encodedSearchTag)
        }
        serviceWrapper.getResponseForRequest("\(kTwitterSearchAPI)q=\(encodedSearchTag!)&geocode=\(defaultLocation.coordinate.latitude),\(defaultLocation.coordinate.longitude),\(distance)&count=100&since=\(oneMonthBackDate)")
        self.hashTagImages.removeAll()
        self.view.addSubview(activityIndicator)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        view.endEditing(true)
    }
}


//------------------------------------------------------
// MARK: - UITableViewDelegate
//------------------------------------------------------

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Do Nothing")
    }
}

//------------------------------------------------------
// MARK: - UITableViewDataSource
//------------------------------------------------------

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableview: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hashTagImages.count == 0 {
            return 0
        }else{
            let numberOfRows = hashTagImages.count
            return numberOfRows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "photoCell"
        
        let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PhotoCell
        
        let hashTagImage = hashTagImages[indexPath.row] as TwitterImages
        cell.photoImageView.image = UIImage(data: hashTagImage.imageURL! as Data)

        return cell
    }
}


//------------------------------------------------------
// MARK: - CLLocationManagerDelegate
//------------------------------------------------------

extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            defaultLocation = location
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

