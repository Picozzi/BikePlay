# BikePlay

BikePlay is an augmented-reality bicycle helmet prototype developed for the University of Waterloo’s 2023 Mechatronics Engineering capstone. It was designed to put cycling directions, time, weather, distance traveled, and helmet battery level within a rider’s view while their phone stays stowed.

Two helmet-mounted projection modules display information on the sides of an adjustable visor. The companion iOS app handles route search and navigation, stores map regions for offline use, and sends updates to the helmet controller over Bluetooth Low Energy.

## Repository layout

- [`BikePlay/`](BikePlay/) contains the Swift and UIKit iOS app, including Bluetooth connectivity and Mapbox routing.
- [`BikePlay.xcodeproj`](BikePlay.xcodeproj) is the Xcode project for the app.
- [`website/`](website/) contains the static project site, [technical specifications](website/technical-specifications/index.html), and [ten weekly build logs](website/build-log/index.html) covering the prototypes through the capstone symposium.

## Preview the website

Open [`website/index.html`](website/index.html) in a browser.


## Open the iOS project

Open `BikePlay.xcodeproj` in Xcode and select the `BikePlay` target. The project targets iOS 16.2 and uses Swift Package Manager for Mapbox Navigation and Search. To test the Bluetooth connection end to end, use an iPhone with the BikePlay helmet hardware.
