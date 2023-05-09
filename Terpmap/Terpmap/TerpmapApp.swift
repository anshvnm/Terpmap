//
//  TerpmapApp.swift
//  Terpmap
//
//  James Marshal Bakeranderson, Erin Lawson, Ansh Vanam
//  3/7/2023

import SwiftUI
import SwiftUI
import CoreLocation
import MapKit

// Ripped from the internet for debugging.
// Specifically:
// https://stackoverflow.com/questions/74145900/how-can-i-print-all-notifications-from-notificationcenter-in-swiftui

class NotificationObserver {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(printAllNotifications),
            name: nil,
            object: nil)
    }
    
    @objc func printAllNotifications(_ note: Notification) {
        guard note.name != UIScreen.brightnessDidChangeNotification else { return }
        
        print(note.name)
    }
}

@main
struct TerpmapApp: App {
    
    //    let notificationObserver = NotificationObserver()
    var body: some Scene {
        WindowGroup {
            /*
             initialBucketList is the first-most created bucket list.
             We then pass that bucket list into our mapView struct,
             keeping it mutable (though I'll probably need to make this a reference)
             so that users can still change bucketList items to 'completed'
             as necessary. For the moment: Ignore any warnings about mutation.
             We'll get there.
             */

            MapView()
        }
    }
}

struct annotationView : View {
    
    @State var isHidden : Bool = false
    private var textDescription = ""
    private let icon : String
    @State var taskCompleted : Bool
    
    init(hidden : Bool, description : String, icon : String, taskCompleted: Bool){
        self.textDescription = description
        self.isHidden = hidden
        self.icon = icon
        self.taskCompleted = taskCompleted
    }
    
    func reveal(){
        self.isHidden = false
    }
    
    func hide(){
        self.isHidden = true
    }
    
    var body: some View {
        if (self.taskCompleted){
            VStack(){
                Image(systemName: icon).foregroundColor(Color.red)
            }
        } else {
            VStack(){
                Image(systemName: icon).foregroundColor(Color.blue)
                Text(textDescription)
            }
        }
    }
}

struct MapView: View {
    @StateObject var bucketListInstance : bucketList = bucketList()

    var body: some View {
        //Create two tabs - the map and the bucket list
        TabView {
            //Map TabItem
            VStack {
                Text("Terpmap").font(.largeTitle)
                    .foregroundColor(.red)
                    .bold()
                    .padding()
                HStack() {
                    Circle().foregroundColor(.red).frame(width: 15, height: 15)
                    Text("Completed                      ").font(.subheadline)
                    .foregroundColor(.red)
                    .bold()
                    Circle().foregroundColor(.blue).frame(width: 15, height: 15)
                    Text("Not Completed").font(.subheadline)
                    .foregroundColor(.red)
                    .bold()
                    //.padding()
                }
                    
                /* Version 1 of map
                 Map(coordinateRegion: $UMDCenteredRegion,
                 interactionModes: .all,
                 showsUserLocation: true,
                 annotationItems: self.bucketListInstance.bucketListArray) {
                 place in MapMarker(coordinate: place.gpsLocation,
                 tint: Color.purple)
                 } */
                
                
                // Version 2
                Map(coordinateRegion: $bucketListInstance.coordReg,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.follow),
                    annotationItems: bucketListInstance.bucketListArray) {
                    
                    // I believe the 'accessing states value outside of being install on a view'
                    // is happening here...maybe. I think it doesn't like accessing the 'place' values
                    // in this way...but I don't know why!
                    place in MapAnnotation(coordinate: place.gpsLocation){
                        VStack() {
                            if (place.taskCompleted){
                                Image(systemName: place.icon).foregroundColor(Color.red)
                            }
                            else {
                                Image(systemName: place.icon).foregroundColor(Color.blue)
                            }
                            //Do we want the text?
                            Text(place.activityDescription)
                        }
                    }
                }

            }.background(.yellow)
                .tabItem{Label("Campus", systemImage: "tortoise")}
            //Bucket List Tab Item
            VStack(){
                //Header
                Text("Bucket List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                
                HStack() {
                    Circle().foregroundColor(.red).frame(width: 15, height: 15)
                    Text("Completed                      ").font(.subheadline)
                    .foregroundColor(.red)
                    .bold()
                    Circle().foregroundColor(.blue).frame(width: 15, height: 15)
                    Text("Not Completed").font(.subheadline)
                    .foregroundColor(.red)
                    .bold()
                    //.padding()
                }.padding(.bottom)
                
                //Scrollable bucket list - boxes to check off activities
                //TODO: Clicking the boxes does not change taskCompleted for the respective task in the list, something wrong with the model (maybe the fact that we are using a list of structs (bucketList) and structs are immutable?
                ScrollView {
                    ForEach(0..<self.bucketListInstance.bucketListArray.count, id: \.self) { i in
                        HStack() {
                            //Display the number, icon, and description of the activity
                            
                            Text("\(i + 1).)")
                            
                            //                            Image(systemName: self.bucketListInstance.bucketListArray[i].icon)
                            
                            Text("\(self.bucketListInstance.bucketListArray[i].activityDescription)").frame(maxWidth: .infinity, alignment: .leading)
                            
                            //Button to check off an activity
                            Button(action: {
                                self.bucketListInstance.bucketListArray[i].setTaskCompleted()
                            })
                            {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                    
                                    if self.bucketListInstance.bucketListArray[i].taskCompleted {
                                        
                                        //                                        Image(systemName: "checkmark")
                                        //                                            .foregroundColor(.blue)
                                        Image(systemName: self.bucketListInstance.bucketListArray[i].icon).foregroundColor(.red)
                                        
                                    } else {
                                        Image(systemName: self.bucketListInstance.bucketListArray[i].icon).foregroundColor(.blue)
                                    }
                                }
                            }.frame(maxWidth: .maximum(40, 40), alignment: .trailing)
                        }.padding()
                        
                    }
                }.background(.yellow)
            }.background(.yellow)
                .tabItem{Label("Bucket List", systemImage: "checklist")}
            VStack {
                Text("Terpmap").font(.largeTitle)
                    .foregroundColor(.red)
                    .bold()
                    .padding()
                ZStack {
                    Circle()
                        .stroke(Color.red, lineWidth: 10)
                        .frame(width: 150, height: 150)
                    Image(systemName: "tortoise")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.red)
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, 50)
                Text("Welcome to Terpmap, a bucket list activity tracker for University of Maryland students! \n\nThis app allows you to check on-campus items off your UMD bucket list and notifies you when you are close to these activities")
                    .font(.title2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all).background(.yellow).tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
