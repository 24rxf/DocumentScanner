//
//  DocumentDetailView.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 21/01/25.
//

import SwiftUI
import PDFKit
import LocalAuthentication

struct DocumentDetailView: View {
    var document: Document
    // View Properties
    @State private var isLoading = false
    @State private var showFileMover = false
    @State private var fileURL: URL?
    // Lock Screen Properties
    @State private var isLockAvailable = false
    @State private var isUnLocked = false
    
    //Environment Values
    @Environment(\.dismiss) var dismiss
    var body: some View {
        if let pages = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex}) {
            VStack(spacing: 10) {
                HeaderView()
                    .padding()
                TabView {
                    ForEach(pages) { page in
                        if let image = UIImage(data: page.pageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .tabViewStyle(.page)
                
                FooterBuilder()
            }
            .background(.black)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .loadingScreen(status: $isLoading)
            .overlay {
                LockView()
            }
            .fileMover(isPresented: $showFileMover, file: fileURL) { result in
                
                if case .failure(_) = result {
                    guard let fileURL else { return }
                    try? FileManager.default.removeItem(at: fileURL)
                    self.fileURL = nil
                }
                
            }
            .onAppear{
                guard document.isLocked else {
                    isUnLocked = true
                    return
                }
                
                let context = LAContext()
                isLockAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            }
        }
    }
    
    @ViewBuilder
    func FooterBuilder() -> some View {
        HStack {
            Button(action: createAndShareDocument) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
            }
            Spacer(minLength: 0)
            
            Button {
                dismiss()
                Task { @MainActor in
                    
                    try? await Task.sleep(for: .seconds(0.3))
                    
                }
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding([.horizontal, .bottom], 15)
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        Text(document.name)
            .font(.callout)
            .foregroundStyle(.white)
            .hSpacing(.center)
            .overlay(alignment: .leading) {
                Button {
                    document.isLocked.toggle()
                    isUnLocked = !document.isLocked
                } label: {
                    Image(systemName: document.isLocked ? "lock.fill" : "lock.open")
                        .font(.title3)
                        .foregroundStyle(.purple)
                }
                
            }
        
    }
    
    func createAndShareDocument() {
        
        guard let pages = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex}) else { return }
        isLoading = true
        
        let pdfDocument = PDFDocument()
        
        for index in pages.indices {
            if let pageImage = UIImage(data: pages[index].pageData),
               let pdfPage = PDFPage(image: pageImage) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }
        
        var pdfURL = FileManager.default.temporaryDirectory
        let fileName = "\(document.name).pdf"
        
        pdfURL.append(path: fileName)
        
        if pdfDocument.write(to: pdfURL) {
            showFileMover = true
            fileURL = pdfURL
            isLoading = false
        }
        
    }
    
    func authenticationUser() {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Locked Document") { status, _ in
                DispatchQueue.main.async {
                    self.isUnLocked = status
                }
            }
        } else {
            isLockAvailable = false
            isUnLocked = false
        }
    }
    
    
    @ViewBuilder
    func LockView() -> some View {
        if document.isLocked {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    if  !isLockAvailable {
                        Text("Please enable biometric access in Settings to unlock this document!")
                            .multilineTextAlignment(.center)
                            .frame(width: 200)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                        
                        Text("Tap to unlock")
                            .font(.callout)
                    }
                }
                .padding(15)
                .background(.bar, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
                .onTapGesture(perform: authenticationUser)
            }
            .opacity(isUnLocked ?  0 : 1)
            .animation(snappy, value: isUnLocked)
        }
    }
}
