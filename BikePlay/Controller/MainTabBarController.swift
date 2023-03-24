//
//  MainTabBarController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-28.
//

import UIKit
import CoreLocation
import Network

class MainTabBarController: UITabBarController {
    
    //Defining Shared Models To Pass Down
    var bluetoothModel = BluetoothModel()
    var locationModel = LocationModel()
    var offlineStorage = OfflineStorage()
    
    //Timers
    var weatherTimer: Timer = Timer()
    var timeTimer: Timer = Timer()

    //Notification Center
    let notificationCenter = NotificationCenter.default
    
    //Wifi Monitoring
    let monitor = NWPathMonitor()

    //Define Location Managers
    lazy var locationManager: CLLocationManager = {
        var locman = CLLocationManager()
        locman.desiredAccuracy = kCLLocationAccuracyBest
        return locman
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Update Internet Connection Variable
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Message: Internet Connection Found")
                self.offlineStorage.internetConnection = true
            } else {
                print("Message: No Internet Connection Found")
                self.offlineStorage.internetConnection = false
            }
        }

        let queue = DispatchQueue.main
        monitor.start(queue: queue)
                
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
                
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    @objc func willResignActive(_ notification: Notification) {
        weatherTimer.invalidate()
        timeTimer.invalidate()
    }
    
    @objc func appCameToForeground(_ notification: Notification) {
        beginWeatherBackgroundTask()
        beginTimeBackgroundTask()
    }
    
    func beginWeatherBackgroundTask()
    {
        DispatchQueue.global(qos: .background).async { [self] in
            
           self.sendWeather()
            
            weatherTimer = Timer(timeInterval: 300, repeats: true) { _ in 
                self.sendWeather()
            }
            
            let runLoop = RunLoop.current
            runLoop.add(weatherTimer, forMode: .default)
            runLoop.run()
        }
    }
    
    public func sendWeather()
    {
        guard let lat = locationModel.location?.coordinate.latitude else {return}
        guard let lon = locationModel.location?.coordinate.longitude else {return}
        
        let API_Key = "dfc0b2fb2da8198136ae02abcc493c7d"
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(lon) + "&appid=" + API_Key + "&units=metric") else { return }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error -> Void in
            
            let decoder = JSONDecoder()
            guard let unwrapped_data = data else {return}
            
            do {
                let weather = try decoder.decode(WeatherJSON.self, from: unwrapped_data)
                
                let icon = retrieveWeatherIcon(json: weather)
                let feels_like = String(Int(round(weather.main.feels_like)))
                
                self.bluetoothModel.sendToRPI(flag: "w:", data: icon)
                self.bluetoothModel.sendToRPI(flag: "t:", data: feels_like)
            }
            catch {
                print(error)
            }
        })
        task.resume()
    }

    func beginTimeBackgroundTask()
    {
        DispatchQueue.global(qos: .background).async { [self] in
            
            let now = Date.timeIntervalSinceReferenceDate
            let delayFraction = trunc(now) - now
            let delay = 60.0 - Double(Int(now) % 60) + delayFraction
            
            Thread.sleep(forTimeInterval: delay)
            
            self.sendTime()
            
            timeTimer = Timer(timeInterval: 60, repeats: true) { _ in
                self.sendTime()
            }
            
            let runLoop = RunLoop.current
            runLoop.add(timeTimer, forMode: .default)
            runLoop.run()
        }
    }
    
    func sendTime()
    {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time_packet = dateFormatter.string(from: date).capitalized
        
        bluetoothModel.sendToRPI(flag: "c:", data: time_packet)
    }
}

extension MainTabBarController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationModel.location = location
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print(error)
    }
}
    
    
    
