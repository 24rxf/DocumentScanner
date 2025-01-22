//
//  DocumentCardView.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import SwiftUI

struct DocumentCardView: View {
    var document: Document

    var animationID: Namespace.ID
    @State private var downSizedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let firstPage = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex }).first {
                GeometryReader {
                    let size = $0.size
                    
                    if let downSizedImage {
                        Image(uiImage: downSizedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                        
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .task(priority: .high) {
                                guard let image = UIImage(data: firstPage.pageData) else { return }
                                let aspectSize = image.size.aspectFit(.init(width: 150, height: 150))
                                let render = UIGraphicsImageRenderer(size: aspectSize)
                                let resizedImage = render.image { context in
                                    image.draw(in: .init(origin: .zero, size: aspectSize))
                                }
                                
                                await MainActor.run {
                                    downSizedImage = resizedImage
                                }
                            }
                    }
                    
                    if document.isLocked {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                            
                            Image(systemName: "lock.fill")
                                .font(.title3)
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 15))
            }
            
            Text(document.name)
                .font(.callout)
                .lineLimit(1)
                .padding(.top, 10)
                .foregroundStyle(.black)
            Text(document.createAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.gray)
        }
    }
}
