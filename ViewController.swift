//
//  ViewController.swift
//  goCab3
//
//  Created by Biko Pougala on 27/06/2018.
//  Copyright © 2018 goCab. Registered trademark. All rights reserved.
//

import UIKit
import MapKit 
import CoreLocation 



class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    // default coordinates of the center of Cannes, France, in case the user disables location services 
    //var longitude = -157.829444 //7.017369
    //var latitude = 21.282778 //43.552849
    

  
    @IBOutlet weak var MainMapView: MKMapView!
    
    @IBOutlet weak var pinPoint: UIImageView!
    
    @IBOutlet weak var addressBar: UITextField!
    
    @IBOutlet weak var setPickUpButton: UIButton!
    
    
    
    var locationManager = CLLocationManager() 


    
    var geocoder = CLGeocoder() 
    var center:CLLocationCoordinate2D! 
    var automaticAddress: String? 
    var originPlacemark:CLPlacemark? 
    var delta = 0.02 
    
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] 
        let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        self.MainMapView.setRegion(coordinateRegion, animated: true)
        
        
        /**
 **/
    }
    
    // keyboard shows
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: addressBar, moveDistance: -250, up: true)
        locationManager.startUpdatingLocation()
    }
    
    // keyboard is hidden
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: addressBar, moveDistance: -250, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressBar.resignFirstResponder()
        return true 
    }
    @IBAction func setPickUpLocation(_ sender: Any) {
        performSegue(withIdentifier: "setPickUp", sender: self)
    }
    
    @IBAction func geocode(_ sender: UITextField) {
        guard let address = addressBar.text else { return }
      
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in 
            guard let placemarks = placemarks else { return }
            guard let location = placemarks.first?.location else { return }
            self.center.latitude = location.coordinate.latitude
            self.center.longitude = location.coordinate.longitude 
            let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.center.latitude, longitude: self.center.longitude ), span: MKCoordinateSpan(latitudeDelta: self.delta, longitudeDelta: self.delta))
            self.MainMapView.setRegion(newRegion, animated: true)
           
                    // handle no location found 
        }
        locationManager.stopUpdatingLocation()
    }
    

    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        /** case when location services are disabled or the user refuses to share its location with the app ;
             default coordinates of Cannes are displayed instead 
        **/
        let coordinateRegion  = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.552849, longitude: 21.282778), span: MKCoordinateSpan(latitudeDelta: self.delta*10, longitudeDelta: self.delta*10))
        print("Unable to access your location. Instead, here's a map of our beautiful hometown of Cannes, France.")
        self.MainMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        center = MainMapView.centerCoordinate
        delta = MainMapView.region.span.longitudeDelta
        let newLocation = CLLocation.init(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(newLocation) { (placemark, error) in 
            if error != nil 
            {
                print("there was an error")
                self.addressBar.text = "No address found"
            } else 
            {
                if let place = placemark?[0]
                {
                    self.originPlacemark = place
                    if place.thoroughfare != nil && place.subThoroughfare != nil {
                        self.addressBar.text = place.subThoroughfare! + " " + place.thoroughfare! + ", " + place.locality! 
                    } else if place.thoroughfare != nil && place.subThoroughfare == nil { // place.locality != nil otherwise fatal error 
                        self.addressBar.text = place.thoroughfare! + ", " + place.locality! 
                    } else {
                         self.addressBar.text = ""
                    }
                }
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC: BookRideViewController = segue.destination as! BookRideViewController
        destVC.pickUpAddress = addressBar.text! 
        destVC.center = self.center 
        destVC.delta = self.delta 
        destVC.currentPlacemark = self.originPlacemark
        destVC.originCoordinate = self.center 
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.locationManager.requestWhenInUseAuthorization() 
        //self.MainMapView.delegate = self 
        //let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        MainMapView.delegate = self 
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
             // center the map on Cannes 
            } else {
                locationManager.delegate = self 
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        } else {
            print("please turn on location services or GPS")
        }
        
        //locationManager.stopUpdatingLocation()
        
        //centerMapOnLocation(location: initialLocation)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool) {
        // when the keyboard shows up, we want the text field to be "out of the way" 
        let moveDuration = 0.3 
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

