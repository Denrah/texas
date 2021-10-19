//
//  SavedObject.swift
//  Texas
//

import Foundation

struct SavedObject: Codable {
  let lat: Double
  let lon: Double
  let type: ObjectType
  let count: Int
}
