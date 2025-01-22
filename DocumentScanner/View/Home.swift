//
//  Home.swift
//  DocumentScanner
//
//  Created by Rizal Fahrudin on 20/01/25.
//

import SwiftUI
import SwiftData
import VisionKit
struct Home: View {
    @Query(sort: [.init(\Document.createAt, order: .reverse)], animation: .snappy) var documents: [Document]
    @State var showScannerView: Bool = false
    @State var askDocumentName: Bool = false
    @State var isLoading: Bool = false
    @State var documentName: String = ""
    @State var scanDocumenet: VNDocumentCameraScan?
    @Namespace private var animationID
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2), spacing: 15) {
                    ForEach(documents) { document in
                        NavigationLink {
                            DocumentDetailView(document: document)
                                .navigationTransition(.zoom(sourceID: document.uniqViewID, in: animationID))
                        } label: {
                            DocumentCardView(document: document, animationID: animationID)
                                .foregroundStyle(.primary)
                        }

                    }
                    .padding(15)
                }
            }
            .navigationTitle("Document's")
            .safeAreaInset(edge: .bottom) {
                CreateButton()
            }
        }
        .fullScreenCover(isPresented: $showScannerView) {
            ScannerView { err in
            } didCancel: {
                showScannerView = false
            } didFinish: { scan in
                scanDocumenet = scan
               showScannerView = false
                askDocumentName = true
            }
            .ignoresSafeArea()
        }
        .alert("Document Name", isPresented: $askDocumentName) {
            TextField("New Document", text: $documentName)
            Button("Save") {
                createDocument()
            }
            .disabled(documentName.isEmpty)
        }
        .loadingScreen(status: $isLoading)
    }
    
    @ViewBuilder
    func CreateButton() -> some View {
        Button {
            print("DEBUG: CreateButton()")
            showScannerView.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "document.viewfinder.fill")
                    .font(.title3)
                Text("Scan documents")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.purple.gradient, in: .capsule)
        }
        .hSpacing(.center)
        .padding(.vertical, 12)
    }
    
    func createDocument() {
        
        guard let scanDocumenet else { return }
        isLoading = true
        
        Task.detached(priority: .high) { [documentName] in
            
            let document = Document(name: documentName)
            var pages :[DocumentPage] = []
            
            for pageIndex in 0..<scanDocumenet.pageCount {
                let pageImage = scanDocumenet.imageOfPage(at: pageIndex)
                
                guard let pageData = pageImage.jpegData(compressionQuality: 0.65) else { return }
                let documentPage = DocumentPage(document: document, pageIndex: pageIndex, pageData: pageData)
                pages.append(documentPage)
            }
            
            document.pages = pages
            
            await MainActor.run {
                modelContext.insert(document)
                try? modelContext.save()
                
                self.scanDocumenet = nil
                isLoading = false
                self.documentName = "New Document"
            }
        }
        
    }
}

#Preview {
    Home()
}
