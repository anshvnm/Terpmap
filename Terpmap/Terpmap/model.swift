//
//  model.swift
//  Terpmap
//
//  James Marshal Bakeranderson, Erin Lawson, Ansh Vanam
//  3/7/2023

import Foundation
import CoreLocation
import MapKit
import UserNotifications


class LocationManager: NSObject, ObservableObject {
    public let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    //Intended for possible triggering of geofences?
    //Possibly needed / relevant for notifications.
    // Seems like it successfully triggers on relevant regions...but I can't quite pull
    // usable strings out of it. Check console to see what I'm talking about.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered region: \(region.identifier), \(region.description)")
        
    }
    
    
        
    
}

/*
 The enum below is from the lecture slides, we could modify with bucket-list locations
 Update 12MAR2023: I have removed all locations besides stamp, since I (james) am assuming
 that we are 'centering' campus around Stamp, and the rest of the locations will need GPS data
 to be provided on a per-activity basis
 */
enum Locations: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case Stamp = "Adele H. Stamp Student Union"
    static private let _Stamp = CLLocationCoordinate2D(latitude: 38.988360143144014,
                                                       longitude: -76.94406698758150)
}

struct bucketListItem : Identifiable{
    let id = UUID()
    let activityDescription : String
    let gpsLocation : CLLocationCoordinate2D
    var taskCompleted : Bool
    let icon : String
    
    //Ansh: Implemented persistence within this function. Makes life easier
    mutating func setTaskCompleted(){
        self.taskCompleted.toggle()
        UserDefaults.standard.set(self.taskCompleted, forKey: self.activityDescription)
    }
}

//Ansh: Initialized each taskCompleted using UserDefaults instead of calling explicit functions
class bucketList : ObservableObject {
     let UMDCenteredRegion : MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.988360143144014,
                                       longitude: -76.94406698758150),
        span : MKCoordinateSpan(
            // This might be a little 'zoomed in', but we can fine-tune it later...
            latitudeDelta: 0.005, longitudeDelta: 0.005
        )
    )
    
    var locationManager : LocationManager
    private let blRetrieveKey = "blArray"
    @Published var bucketListArray : [bucketListItem]
    @Published var notifyUser : Bool = false
    public var notificationManager : Notifications
    @Published var currCoords : CLLocationCoordinate2D
    @Published var coordSpan : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    @Published var coordReg : MKCoordinateRegion

    init(){

        locationManager = LocationManager()
        currCoords = locationManager.location?.coordinate ?? UMDCenteredRegion.center
        coordReg = UMDCenteredRegion
        
        //Initialize bucketList items for storage in the bucketListArray
        let footballGame = bucketListItem(activityDescription: "Watch a football game at Secu Stadium", gpsLocation: CLLocationCoordinate2D(latitude: 38.990433559726355, longitude: -76.94728521734704), taskCompleted: UserDefaults.standard.bool(forKey: "Watch a football game at Secu Stadium"), icon: "football.fill")
        
        let basketballGame = bucketListItem(activityDescription: "Watch a basketball game at the Xfinity Center", gpsLocation: CLLocationCoordinate2D(latitude: 38.99591418518346, longitude: -76.94176348666267), taskCompleted: UserDefaults.standard.bool(forKey: "Watch a basketball game at the Xfinity Center"), icon: "basketball.fill")
        
        let swimMcKeldin = bucketListItem(activityDescription: "Swim in McKeldin Fountain", gpsLocation: CLLocationCoordinate2D(latitude: 38.986120032749405, longitude: -76.94244758851168), taskCompleted: UserDefaults.standard.bool(forKey: "Swim in McKeldin Fountain"), icon: "figure.water.fitness")
        
        let eatMarathon = bucketListItem(activityDescription: "Eat fries at Marathon Deli", gpsLocation: CLLocationCoordinate2D(latitude: 38.98151722080496, longitude: -76.9380202694722), taskCompleted: UserDefaults.standard.bool(forKey: "Eat fries at Marathon Deli"), icon: "takeoutbag.and.cup.and.straw")
        
        let sitHelicopter = bucketListItem(activityDescription: "Sit in the helicopter", gpsLocation: CLLocationCoordinate2D(latitude: 38.99319644984482, longitude: -76.93936491549829), taskCompleted: UserDefaults.standard.bool(forKey: "Sit in the helicopter"), icon: "airpodsmax")
        
        let jimHensonVisit = bucketListItem(activityDescription: "Sit at the Jim Henson statue", gpsLocation: CLLocationCoordinate2D(latitude: 38.98769161079021, longitude: -76.94505455887561), taskCompleted: UserDefaults.standard.bool(forKey: "Sit at the Jim Henson statue"), icon: "sofa")
        
        let laPlataBeach = bucketListItem(activityDescription: "Catch some rays at La Plata Beach", gpsLocation: CLLocationCoordinate2D(latitude: 38.9926502545024, longitude: -76.94509921549836), taskCompleted: UserDefaults.standard.bool(forKey: "Catch some rays at La Plata Beach"), icon: "sun.dust")
        
        let paintBranchTrail = bucketListItem(activityDescription: "Walk paint branch trail", gpsLocation: CLLocationCoordinate2D(latitude: 38.999548548535444, longitude: -76.93272565967573), taskCompleted: UserDefaults.standard.bool(forKey: "Walk paint branch trail"),icon: "figure.hiking")
        
        let MCircle = bucketListItem(activityDescription: "Take a picture at M Circle", gpsLocation: CLLocationCoordinate2D(latitude: 38.9875945015398, longitude: -76.94017321235667), taskCompleted: UserDefaults.standard.bool(forKey: "Take a picture at M Circle"),icon: "m.circle")
        
        let YahentamitsiDiningHall = bucketListItem(activityDescription: "Eat at Yahentamitsi Dining Hall", gpsLocation: CLLocationCoordinate2D(latitude: 38.991400079641785, longitude: -76.94472114433383), taskCompleted: UserDefaults.standard.bool(forKey: "Eat at Yahentamitsi Dining Hall"),icon: "fork.knife.circle")
        
        self.bucketListArray = [footballGame,basketballGame,swimMcKeldin,eatMarathon,sitHelicopter,jimHensonVisit,laPlataBeach,paintBranchTrail,MCircle,YahentamitsiDiningHall]
        
        // Notifications instantiation (Moved out of its own function and made public for accessing view-side)
        notificationManager = Notifications()
        
        // Request permissions for notifications
        notificationManager.requestPerm()
        
        // Here we make a schedule for every location in bucketListArray to have a trigger set
        // to notify the user whenever they get within range of the bucketListItem
        for place in bucketListArray {
            
            // This line is where we formally call the schedule.
            // Note that we do this at init time because we expect, once everything is initialized,
            // that we should be good to use notifications
            notificationManager.schedule(place:place, locMan: locationManager)
            
            // Debug output to verify that the events got registered.
            // If you go to the console, you should see these!
            print("---DEBUG: See notificationCenter requests below---")
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    print("Found notificationCenter request\n: \(request)")
                }
            })
            
        }
        
    }
}


/* Notifications Stuff*/
class Notifications {
    //request authorization to send user notifications
    func requestPerm() {
        let options: UNAuthorizationOptions = [.alert, .sound]  //enable notifications (lock screen blurb) and ringtone
        UNUserNotificationCenter.current().requestAuthorization(options:options) {(ok, error) in
            
            if let error = error {          //placeholder code, could make it do something useful later
                print("Error: \(error)")
            } else {
                print("Permission granted")
                
            }
        }
    }
    
    //set up a geofence and trigger for a location notification
    func schedule(place : bucketListItem, locMan: LocationManager) {
        
        let notificationContent = UNMutableNotificationContent()        //alert text and sound
        notificationContent.title = "You are near bucket list item: \(place.activityDescription)"
        notificationContent.subtitle = "Complete?:\(place.taskCompleted)"
        notificationContent.sound = .default
        
        let notificationCoords = CLLocationCoordinate2D(        //coordinates
            latitude: place.gpsLocation.latitude,
            longitude: place.gpsLocation.longitude)
        
        let notificationRegion = CLCircularRegion(      //draw circle centered at coordinates
            center: notificationCoords,
            radius: 100.00,                //distance from center point in meters
            identifier: "\(place.activityDescription)")
        
        locMan.locationManager.startMonitoring(for: notificationRegion)
        
        //print what regions being monitored
        print("list of regions being monitored: \(locMan.locationManager.monitoredRegions)")
    
        
        notificationRegion.notifyOnEntry = true     //notify when enter region but not when exiting
        notificationRegion.notifyOnExit = false
        
        let regionTrigger = UNLocationNotificationTrigger(        //set up trigger
            region: notificationRegion,
            repeats: true)
        
        // Debug: I use this timeTrigger for testing. replace trigger: regionTrigger with trigger: timeTrigger in the request
        // in order to simply make a Trigger that waits for 10 seconds.
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            //this is the actual request to create and send the notification
            identifier: "\(place.activityDescription)",
            content: notificationContent,
            trigger: regionTrigger)
        
        //this adds the request to the notification center
        UNUserNotificationCenter.current().add(request)  {
            (error) in
            if error != nil {
                print("Error detecting adding Notification request! See error below:")
                print(error!.localizedDescription)
            }
            //print requests
            else {
                print(UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {request in
                    print("Request added to notification center - pending: \(request)")
                }))
            }
        }
    }
  
    func scheduleDelegate(place : bucketListItem, locMan: LocationManager) {
        
        let notificationContent = UNMutableNotificationContent()        //alert text and sound
        notificationContent.title = "You are near bucket list item: \(place.activityDescription)"
        notificationContent.subtitle = "Complete?:\(place.taskCompleted)"
        notificationContent.sound = .default
        
        let notificationCoords = CLLocationCoordinate2D(        //coordinates
            latitude: place.gpsLocation.latitude,
            longitude: place.gpsLocation.longitude)
        
        let notificationRegion = CLCircularRegion(      //draw circle centered at coordinates
            center: notificationCoords,
            radius: 1000.00,                //distance from center point in meters
            identifier: "\(place.activityDescription)")
        
        locMan.locationManager.startMonitoring(for: notificationRegion)
        
        notificationRegion.notifyOnEntry = true     //notify when enter region but not when exiting
        notificationRegion.notifyOnExit = false
        
        let regionTrigger = UNLocationNotificationTrigger(        //set up trigger
            region: notificationRegion,
            repeats: true)
        
        // Debug: I use this timeTrigger for testing. replace trigger: regionTrigger with trigger: timeTrigger in the request
        // in order to simply make a Trigger that waits for 10 seconds.
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            //this is the actual request to create and send the notification
            identifier: "\(place.activityDescription)",
            content: notificationContent,
            trigger: regionTrigger)
        
        
        
        //this adds the request to the notification center
        UNUserNotificationCenter.current().add(request)  {
            (error) in
            if error != nil {
                print("Error detecting adding Notification request! See error below:")
                print(error!.localizedDescription)
            }
        }
    }
    //delete notifications? -> implement if we can get a notification to show up...
}
