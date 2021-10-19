//
//  AddViewController.swift
//  Texas
//

import UIKit
import MapKit

class AddViewController: UIViewController {
  var onDidAdd: (() -> Void)?
  
  @IBOutlet private weak var objectTypeButton: UIButton!
  @IBOutlet private weak var countFiled: UITextField!
  @IBOutlet private weak var mapView: MKMapView!
  
  private let locationManager = CLLocationManager()
  
  private var selectedType: ObjectType? {
    didSet {
      objectTypeButton.setTitle(selectedType?.title ?? "Выбрать", for: .normal)
    }
  }
  
  private var selectedLocation: CLLocationCoordinate2D? {
    didSet {
      if let selectedLocation = selectedLocation {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: selectedLocation,
                                        latitudinalMeters: CLLocationDistance(exactly: 500) ?? .zero,
                                        longitudinalMeters: CLLocationDistance(exactly: 500) ?? .zero)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(recognizer:)))
    mapView.addGestureRecognizer(gesture)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
  }
  
  @objc private func handleMapTap(recognizer: UIGestureRecognizer) {
    let point = recognizer.location(in: mapView)
    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
    self.selectedLocation = coordinate
  }
  
  @IBAction private func selectObject(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Тип объекта", message: nil, preferredStyle: .actionSheet)
    
    ObjectType.allCases.forEach { type in
      actionSheet.addAction(UIAlertAction(title: type.title, style: .default, handler: { [weak self] _ in
        self?.selectedType = type
      }))
    }
    
    actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    present(actionSheet, animated: true, completion: nil)
  }
  
  @IBAction private func didTapView(_ sender: Any) {
    view.endEditing(true)
  }
  
  @IBAction private func close(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction private func save(_ sender: Any) {
    guard let location = selectedLocation, let type = selectedType,
          let countString = countFiled.text, let count = Int(countString) else {
            let alert = UIAlertController(title: "Заполните все поля", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
          }
    
    let object = SavedObject(lat: location.latitude, lon: location.longitude, type: type, count: count)
    let data = UserDefaults.standard.data(forKey: "objects") ?? Data()
    var objects = (try? JSONDecoder().decode([SavedObject].self, from: data)) ?? []
    objects.append(object)
    
    if let data = try? JSONEncoder().encode(objects) {
      UserDefaults.standard.set(data, forKey: "objects")
    }
    
    onDidAdd?()
    dismiss(animated: true)
  }
}

// MARK: - CLLocationManagerDelegate

extension AddViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location?.coordinate,
          selectedLocation == nil else { return }
    selectedLocation = location
  }
}
