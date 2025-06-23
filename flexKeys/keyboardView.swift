//
//  keyboardView.swift
//  flexKeys
//
//  Created by user on 5/5/25.
//

import SwiftUI

class KeyboardView: UIView {
  
  // MARK: – Subviews
  private let titleLabel: UILabel = {
    let lbl = UILabel()
    lbl.text = "flexKeyboard"
    lbl.font = .systemFont(ofSize: 12, weight: .semibold)
    lbl.textAlignment = .center
    lbl.translatesAutoresizingMaskIntoConstraints = false
    return lbl
  }()
  
  private let rowsStackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.distribution = .fillEqually
    sv.spacing = 6
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()
  
  // MARK: – Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupAppearance()
    setupLayout()
    populateKeys()
  }
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: – Setup
  private func setupAppearance() {
    backgroundColor = .systemGray6
    layer.cornerRadius = 8
  }
  
  private func setupLayout() {
    addSubview(titleLabel)
    addSubview(rowsStackView)
    
    NSLayoutConstraint.activate([
      // Title at top
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      // Rows fill remainder
      rowsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
      rowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      rowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
      rowsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -4)
    ])
  }
  
  private func populateKeys() {
    // Simple 3-row QWERTY layout
    let row1 = makeRow(keys: ["Q","W","E","R","T","Y","U","I","O","P"])
    let row2 = makeRow(keys: ["A","S","D","F","G","H","J","K","L"])
    let row3 = makeRow(keys: ["Z","X","C","V","B","N","M","⌫"])
    [row1, row2, row3].forEach { rowsStackView.addArrangedSubview($0) }
  }
  
  private func makeRow(keys: [String]) -> UIStackView {
    let sv = UIStackView()
    sv.axis = .horizontal
    sv.distribution = .fillEqually
    sv.spacing = 4
    keys.forEach { title in
      let btn = UIButton(type: .system)
      btn.setTitle(title, for: .normal)
      btn.titleLabel?.font = .systemFont(ofSize: 16)
      btn.backgroundColor = .white
      btn.layer.cornerRadius = 4
      btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
      sv.addArrangedSubview(btn)
    }
    return sv
  }
  
  // MARK: – Actions
  @objc private func keyTapped(_ btn: UIButton) {
    guard let title = btn.title(for: .normal),
          let vc = findInputViewController() else { return }
    
    switch title {
    case "⌫": vc.textDocumentProxy.deleteBackward()
    default:    vc.textDocumentProxy.insertText(title)
    }
  }
  
  // climb responder chain to find our UIInputViewController
  private func findInputViewController() -> UIInputViewController? {
    var nextResponder: UIResponder? = self
    while let r = nextResponder {
      if let ivc = r as? UIInputViewController { return ivc }
      nextResponder = r.next
    }
    return nil
  }
}

