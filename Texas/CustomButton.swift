//
//  CustomButton.swift
//  Texas
//

import UIKit

class CustomButton: UIButton {
  var onTap: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    addTarget(self, action: #selector(handleTap), for: .touchUpInside)
  }
  
  @objc private func handleTap() {
    onTap?()
  }
}
