//
//  ObjectType.swift
//  Texas
//

import Foundation

enum ObjectType: String, Codable, CaseIterable {
  case powerPylon = "power_pylon", streetlight, tree, mailbox, hydrant
  
  var title: String {
    switch self {
    case .powerPylon:
      return "столбы ЛЭП"
    case .streetlight:
      return "уличные фонари"
    case .tree:
      return "деревья"
    case .mailbox:
      return "почтовые ящики"
    case .hydrant:
      return "пожарные гидранты"
    }
  }
}
