//
//  ViewController.swift
//  currentLocation
//
//  Created by Liseth Cardozo Sejas on 9/14/17.
//  Copyright © 2017 Liseth Cardozo Sejas. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation

//added this class to stop updating the score when the user pressed the pin again and to keep the images when the user zoom in- zoom out

class BerryAnotation : MKPointAnnotation {
    var pressed = false
    
    func isPoison() -> Bool {
        return self.title == "You found a poison berry 🤢!";
    }
    
    func getScore() -> Int {
        return isPoison() ? -3 : 5;
    }
    
    func getImage() -> UIImage? {
        if !pressed {
            return UIImage(named: "berry")
        } else {
            if isPoison() {
                return UIImage(named: "poisonberry")
            } else {
                return UIImage(named: "boysenberry")
            }
        }
    }
    
    func getStatus() -> UIImage? {
        if isPoison() {
            return UIImage(named: "sad")
        } else {
            return UIImage(named: "yummy")
        }
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //    var annotations: [MKAnnotation] = Array()
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startScreenView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    // Upper status bar
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreTitle: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var upperLogo: UIImageView!
    
    
    // Lower status bar
    @IBOutlet weak var lowerLogo: UIImageView!
    @IBOutlet weak var barryStatus: UIImageView!
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        startScreenView.isHidden = true
        upperLogo.isHidden = true
//        timerTitle.isHidden = false
//        timerLabel.isHidden = false
//        scoreTitle.isHidden = false
//        scoreLabel.isHidden = false
//        lowerLogo.isHidden = false
//        barryStatus.isHidden = false
        startGame()
        runTimer()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        startGame()
        onFirstLocationUpdate(self.region!)
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    var currentLocation: CLLocation?
    var seconds = 30    // timer length
    var timer = Timer()
    var score: Int = 0
    var coordinates: [CLLocationCoordinate2D] = []
    var backgroundMusicPlayer = AVAudioPlayer()
    var region: MKCoordinateRegion?
    
    func playBackgroundMusic(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if Int(seconds) < 1 {
            backgroundMusicPlayer.pause()
            startScreenView.isHidden = false
            startButton.isHidden = false
            print("Alarm going off")
            //addded timer to end game on update function
            if score >= 10 {
                
                self.createGoodAlert(title: "Barry found his Honey!", message: "😊")
                
            }
                
            else {
                
                self.createBadAlert(title: "Barry died from food poisoning", message: "☠️")
                
            }
            //************
            
            timer.invalidate()
            //            performSegue(withIdentifier: "mySegue", sender: nil)
        }
        else {
            self.seconds -= 1
            print(seconds)
            self.timerLabel.text = String(self.seconds)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()

    }
    
    //start game function
    func startGame() {
        self.seconds = 30
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //        // hide lower status bar images until Start pressed
        //        lowerLogo.isHidden = true
        //        barryStatus.isHidden = true
        //
        //        // hide upper status bar labels until Start pressed
        //        timerTitle.isHidden = true
        //        timerLabel.isHidden = true
        //        scoreTitle.isHidden = true
        //        scoreLabel.isHidden = true
        
        
        
        // for custom pin annotations
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        playBackgroundMusic(filename: "nomnomnom.mp3")
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let berryAnnotation = view.annotation as? BerryAnotation else {
            return
        }
        if (berryAnnotation.pressed) {
            return
        }
        berryAnnotation.pressed = true
        self.score += berryAnnotation.getScore()
        view.image = berryAnnotation.getImage()
        self.barryStatus.image = berryAnnotation.getStatus()
        self.scoreLabel.text = String(self.score)
    }
    
    var userAnnotation:MKPointAnnotation!;
    
    func setUserLocation(_ myLocation: CLLocationCoordinate2D) {
        if (nil == userAnnotation) {
            userAnnotation = MKPointAnnotation()
            self.mapView.addAnnotation(userAnnotation)
            userAnnotation.title = "Your Location";
        }
        userAnnotation.coordinate.latitude = myLocation.latitude
        userAnnotation.coordinate.longitude = myLocation.longitude
    }
    
    //* ADD FUNCTIONS for pop ups for win or lose:
    func createBadAlert (title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let action = UIAlertAction(title: "", style: .default, handler: nil)
        let image = UIImage(named: "sad")?.withRenderingMode(.alwaysOriginal)
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = image
        action.setValue(image, forKey: "image")
        alert .addAction(action)
        
    }

    
    func createGoodAlert (title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let image = UIImage(named: "honey")?.withRenderingMode(.alwaysOriginal)
        let action = UIAlertAction(title: "", style: .default, handler: nil)
        action.setValue(image, forKey: "image")
        alert .addAction(action)
    }
    //********
    
    func onFirstLocationUpdate(_ region: MKCoordinateRegion) {
        //location of the user
        self.mapView.setRegion(region, animated: true)
        //self.mapView.showsUserLocation = true
        
        
        //making a request for parks and groceries landmarks
        let request = MKLocalSearchRequest()
        let locations = ["parks", "groceries", "malls", "schools", "fast food", "ice cream"]
        var count = 0
        while count < 2 {
            let index = Int(arc4random_uniform(6))
            request.naturalLanguageQuery = locations[index]
            request.region = region
            
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                guard let response = response else {
                    print("Search error: \(String(describing: error))")
                    return
                }
                
                for item in response.mapItems {
                    
                    let random = arc4random_uniform(3)
                    let annotation = BerryAnotation()
                    annotation.coordinate.latitude = item.placemark.coordinate.latitude
                    annotation.coordinate.longitude = item.placemark.coordinate.longitude
                    
                    if random <= 1 {
                        annotation.title = "You found a berry 😀!"
                        annotation.subtitle = "  @ \(item.name!)"
                    }
                        
                    else if random == 2 {
                        annotation.title = "You found a poison berry 🤢!"
                        annotation.subtitle = "  @ \(item.name!)"
                    }
                    self.mapView.addAnnotation(annotation)
                }
                search.cancel()
            }
            count += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let isFirstUpdate = currentLocation == nil
        currentLocation = locations[0]
        //added this code
        //        manager.stopUpdatingLocation()
        //how much with want to zoom
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.02, 0.02)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        self.region = region
        if (isFirstUpdate) {
            onFirstLocationUpdate(region);
        }
        setUserLocation(myLocation);
    }
    
    // Custom pin annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView:MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        let berryAnnotationMethods = BerryAnotation()
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            //            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        
        //        let customPointAnnotation = annotation as! CustomPointAnnotation
        if annotation === userAnnotation {
            annotationView!.image = UIImage(named: "barry")
        }
        else {
            annotationView!.image = berryAnnotationMethods.getImage()
        }
        
        return annotationView
    }


}

