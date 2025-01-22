//
//  IntroView.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import SwiftUI

struct IntroView: View {
    
    @AppStorage("showInroView") var showInroView: Bool = true
    
    var body: some View {
        VStack(spacing: 15) {
            Text("What's new \nDocument Scanner ")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 65)
                .padding(.bottom, 35)
            
            VStack(alignment: .leading, spacing: 25) {
                PointView(
                    image: "scanner",
                    title: "Scan Document",
                    subtitle: "Scan any doucument with ease."
                )
                PointView(
                    image: "tray.full.fill",
                    title: "Save Document",
                    subtitle: "Persist scanned documents with the new SwiftData Model."
                )
                PointView(
                    image: "faceid",
                    title: "Locked Document",
                    subtitle: "Protect your documents so that only you can Unlock them using FaceID."
                )
            }
            .padding(.horizontal, 25)
           
            
            Spacer(minLength: 0)
            Button {
                //
            } label: {
                Text("Star using document scanner")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.purple, in: .rect(cornerRadius: 12))
            }
        }
        .padding(15)
       
    }
    
    @ViewBuilder
    func PointView(image: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(.purple)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    IntroView()
}
