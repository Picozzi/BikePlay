////
////  MapModuleViewController.swift
////  BikePlay
////
////  Created by Matthew Picozzi on 2023-01-25.
////
//
//import UIKit
//import MapKit
//
//protocol ClickDelegate {
//    func clicked(_ row: Int)
//}
//
//class MapModuleViewController: UITableViewController {
//
//    var selectAlternateRouteDelegate:SelectAlternateRoute? = nil
//    var startSelectedRoute:StartRoute? = nil
//
//    var routesList : [MKRoute] = []
//    var refresher: UIRefreshControl!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .systemBackground
//
//        let smallId = UISheetPresentationController.Detent.Identifier("small")
//        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
//            return 170
//        }
//
//        if let presentationController = presentationController as? UISheetPresentationController {
//            presentationController.detents = [
//                .medium(),
//                smallDetent
//            ]
//            presentationController.prefersGrabberVisible = true
//            presentationController.largestUndimmedDetentIdentifier = .medium
//        }
//       // self.tableView.reloadData() dont need
//        tableView.register(SheetTableViewCell.nib(), forCellReuseIdentifier: "SheetTableViewCell")
//
//    }
//
//    func routes(router: [MKRoute]) {
//        routesList = router
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return routesList.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let customCell = tableView.dequeueReusableCell(withIdentifier: "SheetTableViewCell", for: indexPath) as! SheetTableViewCell
//
//        let distance = "\(String(round(routesList[indexPath.row].distance/1000))) km"
//        let etas = "\(String(round(routesList[indexPath.row].distance/1000)/25)) hrs"
//
//        customCell.configure(with: routesList[indexPath.row].name, ETA: etas, distance: distance)
//
//        customCell.delegate = self
//        customCell.cellIndex = indexPath
//        return customCell
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectAlternateRouteDelegate?.showAlternate(selectedRoute: routesList[indexPath.row], index: indexPath.row)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
//    }
//
//
//
//
//    }
//
//extension MapModuleViewController: ClickDelegate {
//    func clicked(_ row: Int) {
//        print("hiii")
//        //MAYBE GET RID OF THIS (THIS IS JUST A DELAY TO SHOW BUTTON ANIMATION LOL)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
//            self.startSelectedRoute?.startButtonPressed(index: row)
//        }
//    }
//}
//
