//
//  ContentView.swift
//  DragAndDrop_SwiftUI
//
//  Created by 永田大祐 on 2021/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

@available(iOS 15.0, *)
struct ContentView: View {
    var body: some View {
        NavigationView {
            GridDragAndDropView()
                .navigationTitle("DropImage")
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 15.0, *)
struct GridDragAndDropView: View {
    var body: some View {
        VStack(spacing: 5) {
            Color.clear.frame(height: UIScreen.main.bounds.height/9)
            ForEach((0..<5), id: \.self) { row in
                HStack {
                    ForEach((0..<5), id: \.self) { column in
                        GridDragAndDropDesgin(delegate: GridImageData())
                            .frame(width: UIScreen.main.bounds.width/7,
                                   height: UIScreen.main.bounds.width/7)
                            .background(Color.blue)
                    }
                }
            }

            List(GridImageData().totalImages, id: \.image) { image in
                HStack {
                    Text((image.id + 1).description)
                    Image(image.image)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/8,
                               height: UIScreen.main.bounds.width/8)
                        .cornerRadius(15)
                        .onDrag {
                            NSItemProvider(item: .some(URL(string: image.image)! as NSSecureCoding),
                                           typeIdentifier: String(UTType.url.identifier))
                        }
                }
            }
        }
        .padding(.horizontal, UIScreen.main.bounds.width/10)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)

    }
}

@available(iOS 15.0, *)
struct GridDragAndDropDesgin: View {
    
    @State var count = 0
    @ObservedObject var delegate: GridImageData
    var columns: [GridItem] = Array(repeating: .init(.fixed(0)), count: 1)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: columns) {
                ForEach(delegate.selectedImages) { image in
                    Image(image.image)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/15,
                               height: UIScreen.main.bounds.width/15)
                        .cornerRadius(5).onAppear {
                            print(image.image)
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                DispatchQueue.main.async { [self] in
                                    delegate.selectedImages.removeAll { (check) -> Bool in
                                        if check.id == image.id{return true}
                                        else {return false}
                                    }
                                }
                            }
                        }
                }
            }
            
        }
        .onChange(of: delegate.selectedImages.count) { value in
            count = value
        }
        .offset(x: (UIScreen.main.bounds.width/7)/4)
        .onDrop(of: [String(UTType.url.identifier)], delegate: count == 0 ? delegate : GridImageData())
    }
}

@available(iOS 15.0, *)
class GridImageData: ObservableObject, DropDelegate {
    @Published var totalImages: [GridImg] = [
        GridImg(id: 0, image: "p1", flg: false),
        GridImg(id: 1, image: "p2", flg: false),
        GridImg(id: 2, image: "p3", flg: false),
        GridImg(id: 3, image: "p4", flg: false)
    ]
    @Published var selectedImages: [GridImg] = []
    
    func performDrop(info: DropInfo) -> Bool {
        for provider in info.itemProviders(for: [String(UTType.url.identifier)]) {
            guard provider.canLoadObject(ofClass: URL.self) else { return false }
            print("url loaded")
            let _ = provider.loadObject(ofClass: URL.self) { (url, err) in
                DispatchQueue.main.async { [self] in
                    selectedImages.append(GridImg(id: self.selectedImages.count,
                                                  image: "\(url!)",
                                                  flg: selectedImages.last?.flg ?? false))
                }
            }
        }
        return true
    }
}

@available(iOS 15.0, *)
struct GridImg: Identifiable {
    var id: Int
    var image: String
    var flg: Bool
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
