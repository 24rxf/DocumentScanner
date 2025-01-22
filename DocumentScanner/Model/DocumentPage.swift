//
//  DocumentPage.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//
import SwiftUI
import SwiftData

@Model
class DocumentPage {
    var document: Document?
    var pageIndex: Int
    @Attribute(.externalStorage)
    var pageData: Data
    
    init(document: Document? = nil, pageIndex: Int, pageData: Data) {
        self.document = document
        self.pageIndex = pageIndex
        self.pageData = pageData
    }
    
}
