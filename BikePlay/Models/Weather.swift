//
//  Weather.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-28.
//

import Foundation

public struct WeatherJSON : Codable {
    var weather: [Weather]
    var main : Main
}

public struct Weather : Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

public struct Main : Codable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
}

public func retrieveWeatherIcon(json : WeatherJSON) -> String {
    
    switch json.weather[0].main
    {
    case "Thunderstorm":
        return "thunderstorm"
    case "Drizzle":
        return "rain"
    case "Rain":
        return "rain"
    case "Snow":
        return "snow"
    case "Clear":
        return "sun"
    case "Clouds":
        return "cloud"
    case "Mist":
        return "fog"
    case "Smoke":
        return "fog"
    case "Haze":
        return "fog"
    case "Dust":
        return "hazard"
    case "Fog":
        return "fog"
    case "Sand":
        return "hazard"
    case "Ash":
        return "hazard"
    case "Squall":
        return "hazard"
    case "Tornado":
        return "hazard"
    default:
        return "sun"
    }
}




