//
//  DocumentScannerApp.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import SwiftUI

@main
struct DocumentScannerApp: App {
    var body: some Scene {
        WindowGroup {
            Home()
        }
        .modelContainer(for: [Document.self])
    }
}
