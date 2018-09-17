//
//  ConfirmBookingController.swift
//  goCab3
//
//  Created by Biko Pougala on 30/07/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree
import Mapbox 
import Alamofire 
import SwiftyJSON
import PassKit 


class ConfirmBookingController: UIViewController, MGLMapViewDelegate, UIActionSheetDelegate {
    
    var originAddress: String? 
    var destinationAddress: String? 
    var taxiType: String? 
    var originCoordinate: CLLocationCoordinate2D? 
    var destinationCoordinate: CLLocationCoordinate2D? 
    var paymentMethod: String? 
    
    
    var braintreeClient: BTAPIClient? 
    
    @IBOutlet weak var mapView: MQMapView!
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!
    @IBOutlet weak var originModify: UIButton!
    @IBOutlet weak var destModify: UIButton!
    @IBOutlet weak var tipIncrement: UIStepper!
    @IBOutlet weak var tipValue: UILabel!
    @IBOutlet weak var dateTextField: UILabel!
    
    let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIzOWMzMjg1N2Y3MjBjZjZiM2JhNmYyNTNjYWFhODMyZmE0YzE4N2IyMDE0ZDJmOTI1NTA4ZTA1OTQzOTRhNTgxfGNyZWF0ZWRfYXQ9MjAxOC0wOC0wNFQxNjo1NTowMC44NTQ1MDc0MDUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vb3JpZ2luLWFuYWx5dGljcy1zYW5kLnNhbmRib3guYnJhaW50cmVlLWFwaS5jb20vMzQ4cGs5Y2dmM2JneXcyYiJ9LCJ0aHJlZURTZWN1cmVFbmFibGVkIjp0cnVlLCJwYXlwYWxFbmFibGVkIjp0cnVlLCJwYXlwYWwiOnsiZGlzcGxheU5hbWUiOiJBY21lIFdpZGdldHMsIEx0ZC4gKFNhbmRib3gpIiwiY2xpZW50SWQiOm51bGwsInByaXZhY3lVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vcHAiLCJ1c2VyQWdyZWVtZW50VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3RvcyIsImJhc2VVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImFzc2V0c1VybCI6Imh0dHBzOi8vY2hlY2tvdXQucGF5cGFsLmNvbSIsImRpcmVjdEJhc2VVcmwiOm51bGwsImFsbG93SHR0cCI6dHJ1ZSwiZW52aXJvbm1lbnROb05ldHdvcmsiOnRydWUsImVudmlyb25tZW50Ijoib2ZmbGluZSIsInVudmV0dGVkTWVyY2hhbnQiOmZhbHNlLCJicmFpbnRyZWVDbGllbnRJZCI6Im1hc3RlcmNsaWVudDMiLCJiaWxsaW5nQWdyZWVtZW50c0VuYWJsZWQiOnRydWUsIm1lcmNoYW50QWNjb3VudElkIjoiYWNtZXdpZGdldHNsdGRzYW5kYm94IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sIm1lcmNoYW50SWQiOiIzNDhwazljZ2YzYmd5dzJiIiwidmVubW8iOiJvZmYifQ=="
    
    @IBAction func didTapToShowDropIn(_ sender: UIButton) {
        let request = BTDropInRequest() 
        let dropIn = BTDropInController(authorization: clientToken, request: request)
        { (controller, result, error) in 
            if let error = error {
                print(error.localizedDescription)
            } else if (result?.isCancelled == true) {
                print("Transaction cancelled")
            } else if let nonce = result?.paymentMethod?.nonce {
                self.postNonceToServer(nonce)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
        performSegue(withIdentifier: "choosePayment", sender: self)
    }
    
    var annotation_1: MGLPointAnnotation? 
    var annotation_2: MGLPointAnnotation? 
  
    @IBAction func stepperValueDidChange(_ sender: Any) {
        self.tipValue.text = String(self.tipIncrement.value) + " €"
    }
    
    fileprivate func addAnnotation(_ coordinates: CLLocationCoordinate2D) -> MGLPointAnnotation {
        let originPoint = MGLPointAnnotation()
        originPoint.coordinate = coordinates
        mapView?.addAnnotation(originPoint)
        
        return originPoint 
        
        
        }
        
    
    
    fileprivate func getCoordinates(_ address: String) -> Array<Double> {
        var coordinates: [Double] = [] 
        let key = "VJtpFCP5ZOpMAymke0ZKRGGliMUonPd4"
        let MapQuestGeocoderString = "https://open.mapquestapi.com/geocoding/v1/address?key=" + key + "&location=" + address.removeWhiteSpace()
        let MapQuestGeocoder = URL(string: MapQuestGeocoderString) 
        
        URLSession.shared.dataTask(with: MapQuestGeocoder!) { (data, response, err) in 
            
            guard let data = data else { return }
            
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) 
                let json = JSON(object)
                if let result = json["results"][0]["locations"][0]["latLng"]["lat"].double {
                    coordinates.append(result) 
                    coordinates.append(result) 
                }
               // 
              //  
            
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            // let dataAsString = String(data: data, encoding: .utf8)
            //print(dataAsString)
            
            
            
            }
            .resume()
        
        return coordinates
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        braintreeClient = BTAPIClient(authorization: clientToken)

        mapView?.mapType = .normal 
        mapView.delegate = self 
        
        print(originCoordinate!)
        print(destinationCoordinate!)
        
        if let coordinateOrigin = originCoordinate {
            annotation_1 = addAnnotation(coordinateOrigin)
        }
        
        if let coordinateDest = destinationCoordinate {
            annotation_2 = addAnnotation(coordinateDest)
        }
        
        // careful, this is dangerous variable unwrapping 
        mapView.showAnnotations([annotation_1!, annotation_2!], animated: true)
        
        originTextField.text = originAddress!
        destTextField.text = destinationAddress!
        
        dateTextField.text = "Now"
        tipIncrement.wraps = true // stepping beyond maximum value will set it to the minValue 
        tipIncrement.minimumValue = 0
        tipIncrement.maximumValue = 10
        tipIncrement.stepValue = 1
        tipValue.text = "0 €"
     
        if let payment = paymentMethod {
            print(payment)
        }
    }
    
    
    func showDropIn(_ clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest() 
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        {(controller, result, error) in 
        if (error != nil) {
            print("Error: \(error)")
        } else if (result?.isCancelled == true) {
            print("Cancelled")
        } else if let result = result {
            // use the BTDropInResult properties to update the UI 
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func postNonceToServer(_ paymentMethodNonce: String) {
        let paymentURL = URL(string: "https://gocab.app/payments.rb")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in 
            guard let data = data else {
                print(error!.localizedDescription)
                return 
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                print("Transaction failed. Please try again.")
                return 
            }
            
            print("Successfully charged. Thanks so much :)")
        }.resume()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func showDropIn(clientToken: String) {
//        let request = BTDropInRequest()
//        let dropIn = BTDropInController(authorization: clientToken, request: request)
//        {(controller, result, error) in 
//            if(error != nil){
//                print(error)
//            } else if(result?.isCancelled == true) {
//                print("Cancelled")
//            } else if let result = result {
//                // do stuff with the result 
//            }
//            controller.dismiss(animated: true, completion: nil)
//        }
//        self.present(dropIn!, animated: true, completion: nil)
//    }
    
    
    
}
