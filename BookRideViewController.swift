//
//  BookRideViewController.swift
//  
//
//  Created by Biko Pougala on 30/06/2018.
//
// Copyright ® 2018 goCab. Registered trademark. All rights reserved. 

// WHAT NEEDS TO BE DONE: Change colour of pin to green for drop-off and fix the bugs concerning the "go" button which needs to be clicked a few times before it works. 
// Change the value of the fare estimate based on the time of the day, the taxi size chosen...
// Implement an INFO bubble to help guide the user for what size of taxi to choose
// Add a View to implement the button "Order a cab for later or more than 3 people" 
// Add a button to go back to the initial view to change the origin address 

import UIKit
import MapKit 
import CoreLocation

class BookRideViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIPickerViewDelegate {
   
    
    
    
    @IBOutlet weak var originAddress: UITextField!
    @IBOutlet weak var destinationAddress: UITextField!
    @IBOutlet weak var origin_icon: UIImageView!
    @IBOutlet weak var destination_icon: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var TripMapView: MKMapView!
    @IBOutlet weak var estimatedTime: UILabel!
    @IBOutlet weak var estimatedFare: UILabel!
    @IBOutlet weak var fareInformation: UILabel!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var goCabPiccoloView: UIImageView!
    @IBOutlet weak var goCabGrandeView: UIImageView!


   
    // HomeModelProtocol properties
    var feedItems: NSArray = NSArray() 
    var selectedLocation: LocationModel = LocationModel() 
    var originCoordinate: CLLocationCoordinate2D? 
    var destinationCoordinate: CLLocationCoordinate2D? 
    
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        
    }
    

    var pickUpAddress:String = "" // pick-up address gotten from ViewController
    
    var geocoder = CLGeocoder()
    var center:CLLocationCoordinate2D! 
    var currentPlacemark:CLPlacemark? // pick-up point placemark 
    var recentPlacemark:CLPlacemark! // optional destination placemark
    var delta: Double? 
    var cost = 0.0
    var taxiType = "goCab Piccolo" // default selection for goCab size 
    
    var dates = Array<String>() 
    var frenchDates = DateComponents() 
    var brightOrange = UIColor(displayP3Red: 236, green: 138, blue: 2, alpha: 1.0) // brand colour in P3 space 
    var pinTintColour: UIColor? 
    var tapGesture = UITapGestureRecognizer() 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinationAddress.resignFirstResponder()
        return true 
    }
    
    //@IBAction func geocode(_sender: UITextField) {
    
    // }

    @IBAction func geocode(_ sender: Any) {
        guard let address = destinationAddress.text else { return }
        
        if recentPlacemark != nil { // clear any annotation from map in case user changes destination
            TripMapView.removeAnnotation(self.TripMapView.annotations[1])
            TripMapView.removeOverlays(self.TripMapView.overlays)
        }
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in 
            guard let placemarks = placemarks else { return }
            guard let location = placemarks.first?.location else { return }
            let dest:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            let myAnnotation: MKPointAnnotation = MKPointAnnotation() 
            myAnnotation.coordinate = CLLocationCoordinate2DMake(dest.latitude, dest.longitude)
            myAnnotation.title = "Pick-Up"
            self.TripMapView.addAnnotation(myAnnotation)
            // handle no location found 
        }
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in 
            guard let placemarks = placemarks else { return }
            guard let location = placemarks.first?.location else { return }
            let dest:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            self.recentPlacemark = placemarks[0]
            let myAnnotation: MKPointAnnotation = MKPointAnnotation() 
            myAnnotation.coordinate = CLLocationCoordinate2DMake(dest.latitude, dest.longitude)
            myAnnotation.title = "Drop-off"
            self.destinationCoordinate = myAnnotation.coordinate
            print(self.destinationCoordinate!)
            
            self.TripMapView.addAnnotation(myAnnotation)
            self.TripMapView.showAnnotations(self.TripMapView.annotations, animated: true)
            
            guard let currentPlacemark = self.currentPlacemark else { return }
            print(currentPlacemark.location)
            let directionRequest = MKDirectionsRequest() // hold all information concerning our route (distance, time, route steps...)
            let destinationPlacemark = MKPlacemark(placemark: self.recentPlacemark!) // placemark for the optional destination pinpoint
            let originPlacemark = MKPlacemark(placemark: currentPlacemark)
            directionRequest.source = MKMapItem(placemark: originPlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (directionsResponse, error) in 
                guard let directionsResponse = directionsResponse else { return }
                let route = directionsResponse.routes[0]
                self.TripMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                let number = route.expectedTravelTime/60
                let minutes = Int(number)
                self.estimatedTime.text = "Estimated travel time: \(minutes) mn."
                
                let jsonUrlString = "https://gocab.app/service.php"
                
                guard let url = URL(string: jsonUrlString) else { return }
                
                URLSession.shared.dataTask(with: url) { (data, response, err) in 
                    
                    guard let data = data else { return }
                    
                    do {
                        let fares = try JSONDecoder().decode(Array<Fares>.self, from: data)
                        let fare = fares[0]
                        self.cost = round(Double(fare.floor_price)!) + round(Double(fare.kilometer_day)!) * round((route.distance/1000))
                        
                        //  self.estimatedFare.text = "\(self.cost) €"
                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)
                    }
                    }
                    .resume()
                let cost_up = round(self.cost * 1.3) // add 30% to the floor price to get an estimate of real cost  
                self.estimatedFare.text = "\(self.cost)-\(cost_up) €"
            }
        }
    }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        originAddress.text = pickUpAddress
        
        TripMapView.delegate = self 
        
        let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.center.latitude, longitude: self.center.longitude ), span: MKCoordinateSpan(latitudeDelta: self.delta!, longitudeDelta: self.delta!))
        self.TripMapView.setRegion(newRegion, animated: true)
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation() 
        myAnnotation.coordinate = CLLocationCoordinate2DMake(self.center.latitude, self.center.longitude)
        myAnnotation.title = "Pick-Up"
        self.TripMapView.addAnnotation(myAnnotation)
        
        self.estimatedFare.text = "See taxi meter"
        frenchDates.calendar = Calendar.current
        
        
        self.goCabPiccoloView.layer.borderWidth = 4
        self.goCabPiccoloView.layer.borderColor = #colorLiteral(red: 1, green: 0.5072636008, blue: 0, alpha: 1)
        
        self.goCabGrandeView.layer.borderWidth = 1
        self.goCabGrandeView.layer.borderColor = UIColor.gray.cgColor
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(BookRideViewController.picTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.goCabPiccoloView.addGestureRecognizer(tapGesture)
        self.goCabPiccoloView.isUserInteractionEnabled = true
        
        self.goCabGrandeView.addGestureRecognizer(tapGesture)
        self.goCabGrandeView.isUserInteractionEnabled = true 
        
//        addTouchGestureRecogniser(view: self.goCabPiccoloView)
//        addTouchGestureRecogniser(view: self.goCabGrandeView)
//        
//        
    }
    
    @objc func picTapped(_ sender: UITapGestureRecognizer) {
        
        let pic = sender.view 
                
        if pic == self.goCabPiccoloView {
            self.goCabPiccoloView.layer.borderWidth = 4
            self.goCabPiccoloView.layer.borderColor = #colorLiteral(red: 1, green: 0.5072636008, blue: 0, alpha: 1)
            
            self.goCabGrandeView.layer.borderWidth = 1
            self.goCabGrandeView.layer.borderColor = UIColor.gray.cgColor
                    
            self.taxiType = "goCab Piccolo"
            } else if pic == self.goCabGrandeView {
            self.goCabGrandeView.layer.borderWidth = 4
            self.goCabGrandeView.layer.borderColor = #colorLiteral(red: 1, green: 0.5072636008, blue: 0, alpha: 1)
                    
            self.goCabPiccoloView.layer.borderWidth = 1
            self.goCabPiccoloView.layer.borderColor = UIColor.gray.cgColor 
                    
            self.taxiType = "goCab Grande"
        } else {
            return 
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        print("hello")
        guard let address = destinationAddress.text else { return }
        if recentPlacemark != nil { // clear any annotation from map in case user changes destination
            TripMapView.removeAnnotation(self.TripMapView.annotations[1])
            TripMapView.removeOverlays(self.TripMapView.overlays)
        }
        print("how")
        geocoder.geocodeAddressString(address) { (placemarks, error) in 
            guard let placemarks = placemarks else { return }
            guard let location = placemarks.first?.location else { return }
            print("are")
            let dest:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            self.recentPlacemark = placemarks[0]
            let myAnnotation: MKPointAnnotation = MKPointAnnotation() 
            myAnnotation.coordinate = CLLocationCoordinate2DMake(dest.latitude, dest.longitude)
            self.destinationCoordinate = myAnnotation.coordinate
            print(self.destinationCoordinate!)
            myAnnotation.title = "Drop-off"
            print("you")
            self.TripMapView.addAnnotation(myAnnotation)
            self.TripMapView.showAnnotations(self.TripMapView.annotations, animated: true)
            
            guard let currentPlacemark = self.currentPlacemark else { return }
            let directionRequest = MKDirectionsRequest() // hold all information concerning our route (distance, time, route steps...)
            let destinationPlacemark = MKPlacemark(placemark: self.recentPlacemark!) // placemark for the optional destination pinpoint
            let originPlacemark = MKPlacemark(placemark: currentPlacemark)
            directionRequest.source = MKMapItem(placemark: originPlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (directionsResponse, error) in 
                guard let directionsResponse = directionsResponse else { return }
                let route = directionsResponse.routes[0]
                self.TripMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                let number = route.expectedTravelTime/60
                let minutes = Int(number)
                self.estimatedTime.text = "Estimated travel time: \(minutes) mn."
                
                let jsonUrlString = "https://gocab.app/service.php"
                
                guard let url = URL(string: jsonUrlString) else { return }
                
                URLSession.shared.dataTask(with: url) { (data, response, err) in 
                    
                    guard let data = data else { return }
                    
                    do {
                        let fares = try JSONDecoder().decode(Array<Fares>.self, from: data)
                        let fare = fares[0]
                        self.cost = round(Double(fare.floor_price)!) + round(Double(fare.kilometer_day)!) * round((route.distance/1000))
                                            //  self.estimatedFare.text = "\(self.cost) €"
                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)
                    }
                    }
                    .resume()
                let cost_up = round(self.cost * 1.3) // add 30% to the floor price to get an estimate of real cost  
                self.estimatedFare.text = "\(self.cost)-\(cost_up) €"
                // Do any additional setup after loading the view, typically from a nib.
                
                //calling the functoin that will fetch the data
                
                // let item: LocationModel = self.feedItems[0] as! LocationModel
                // let cost = item.floor_price! + item.kilometer_day! * (route.distance/1000)
                // self.estimatedFare.text = "\(cost) €" 
            } 
            
            
            
            // handle no location found 
        }
        
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 1, green: 0.5072636008, blue: 0, alpha: 1) //UIColor.orange 
        renderer.lineWidth = 4.0 
        
        return renderer 
    }
    
    // the JSON file URL a
    let cost_URL = "https://gocab.app/service.php"
    
    // a string array to save all the prices
    var costArray = [String]()
    
    struct Fares: Decodable {
        let city: String 
        let floor_price: String 
        let kilometer_day: String 
        let kilometer_night: String 
        let hourly: String 
        let luggage_supplement: String 
        let fourth_person_supplement: String 
        let airport: String 
        let approach: String 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC: SignUpView = segue.destination as! SignUpView
        destVC.originAddress = originAddress.text 
        destVC.destinationAddress = destinationAddress.text 
        destVC.taxiType = taxiType
        destVC.originCoordinate = self.originCoordinate!
        destVC.destinationCoordinate = self.destinationCoordinate! 
       
    }

    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
