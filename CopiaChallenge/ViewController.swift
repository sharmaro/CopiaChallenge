//
//  ViewController.swift
//  CopiaChallenge
//
//  Created by Rohan Sharma on 6/19/17.
//  Copyright © 2017 Zin. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var animationControlButton: UIButton!
    
    let regionRadius: CLLocationDistance = 1000
    var counter = 1
    
    // Parsing JSON file
    var path = String()
    var jsonData = NSData()
    var jsonResult = NSArray()
    
    var mapAnnotations = [CustomAnnotation]()
    
    // Images for faster loading
    var armImage1 = UIImage(named: "arm1")
    var armImage2 = UIImage(named: "arm2")
    let playImage = UIImage(named: "play")
    let stopImage = UIImage(named: "stop")
    
    var animationTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Parsing JSON file
        let fileName = "coordinates"
        path = Bundle.main.path(forResource: fileName, ofType: "json")!
        jsonData = try! NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
        jsonResult = try! JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        // Close up of initial location on map
        let initialCoordArray = jsonResult[0] as! NSArray
        let initialLat = initialCoordArray[0] as! CLLocationDegrees
        let initialLong = initialCoordArray[1] as! CLLocationDegrees
        let initialLocation = CLLocation(latitude: initialLat, longitude: initialLong)
        
        centerMapOnLocation(location: initialLocation)
        
        // Adding all the CustomAnnotations to an array for easy use
        for i in 0...jsonResult.count - 1 {
            let tempJsonArray = jsonResult[i] as! NSArray
            
            let tempLat = tempJsonArray[0] as! CLLocationDegrees
            let tempLong = tempJsonArray[1] as! CLLocationDegrees
            let tempLoc = CLLocationCoordinate2D(latitude: tempLat, longitude: tempLong)
            
            let tempTitle = String(tempLat)
            let tempSubtitle = String(tempLong)
            let tempAnnot = CustomAnnotation(title: tempTitle, subtitle: tempSubtitle, coordinate: tempLoc)
            
            mapAnnotations.append(tempAnnot)
        }
        
        mapView.addAnnotation(mapAnnotations[0])
        
        // Resizing animation images for appearence
        armImage1 = resizeImage(image: armImage1!, newWidth: 100)
        armImage2 = resizeImage(image: armImage2!, newWidth: 100)        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Moving from one coordinate to another
    // Will restart the movement once last coordinate from JSON file has been reached
    func changeLocations() {
        if(counter == jsonResult.count) {
            counter = 0
        }
        mapView.removeAnnotations(mapAnnotations)
        
        mapView.addAnnotation(mapAnnotations[counter])
        counter += 1
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Beginning/Stopping animation
    @IBAction func animationButtonPressed(_ sender: Any) {
        if(animationControlButton.backgroundImage(for: .normal) == playImage) {
            animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(changeLocations), userInfo: nil, repeats: true)
            animationControlButton.setBackgroundImage(stopImage, for: .normal)
        } else {
            animationTimer.invalidate()
            animationControlButton.setBackgroundImage(playImage, for: .normal)
        }
    }
    
    // Resetting animation
    @IBAction func resetButtonPressed(_ sender: Any) {
        counter = 1
        mapView.removeAnnotations(mapAnnotations)
        mapView.addAnnotation(mapAnnotations[0])
        
        animationControlButton.setBackgroundImage(stopImage, for: .normal)
        
        let initialCoordArray = jsonResult[0] as! NSArray
        let initialLat = initialCoordArray[0] as! CLLocationDegrees
        let initialLong = initialCoordArray[1] as! CLLocationDegrees
        
        let initialLocation = CLLocation(latitude: initialLat, longitude: initialLong)
        centerMapOnLocation(location: initialLocation)
        
        animationTimer.invalidate()
        animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(changeLocations), userInfo: nil, repeats: true)
    }
    
    // MARK: Custom Annotation Pin Image
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Animating the walking doodle
        if(counter % 2 == 0) {
            annotationView?.image = armImage1
        } else {
            annotationView?.image = armImage2
        }
        
        return annotationView
    }
}
