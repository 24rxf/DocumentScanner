//
//  CGSize+Extensions.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import Foundation


extension CGSize {
    func aspectFit(_ to: CGSize) -> CGSize {
        let scaleX = to.width / self.width
        let scaleY = to.height / self.height
        let aspectRatio = min(scaleX, scaleY)
        
        return .init(width: aspectRatio * width, height: aspectRatio * height)
    }
}
