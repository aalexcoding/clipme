//
//  ShareViewController.swift
//  shareExtension
//
//  Created by AlexDelgado on 6/3/25.
//

import UIKit
import SwiftUI

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ShareViewController se ha cargado correctamente")

        // Crea la vista SwiftUI pasándole el extensionContext
        let contentView = ShareExtensionView(extensionContext: self.extensionContext)
        
        // Integra la vista con UIHostingController
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
