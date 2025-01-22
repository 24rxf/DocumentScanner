//
//  Document.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import Foundation
import SwiftData

@Model
class Document {
    var name: String
    var createAt: Date = Date.now
    @Relationship(deleteRule: .cascade, inverse: \DocumentPage.document)
    var pages: [DocumentPage]?
    var isLocked: Bool = false
    var uniqViewID: String = UUID().uuidString
    
    init(name: String, pages: [DocumentPage]? = nil) {
        self.name = name
        self.pages = pages
    }
}
