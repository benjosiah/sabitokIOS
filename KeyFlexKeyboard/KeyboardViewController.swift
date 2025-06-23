import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    private var hostingController: UIHostingController<KeyboardContentView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboardView = KeyboardContentView(proxy: self.textDocumentProxy)
        hostingController = UIHostingController(rootView: keyboardView)

        if let hostingVC = hostingController {
            addChild(hostingVC)
            view.addSubview(hostingVC.view)
            hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            hostingVC.didMove(toParent: self)
        }
    }
    
    
}
