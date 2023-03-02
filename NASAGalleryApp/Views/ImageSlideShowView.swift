

import SwiftUI

struct ImageSlideShowView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var favouriteImages: FetchedResults<ImageData>
    @ObservedObject var imageViewModel: ImageAPIViewModel
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var currentIndex = 0
    @State private var scale = 1.0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @Binding var slideShow: Bool
    @Binding var favouritesToggle: Bool
    @GestureState var draggingOffset: CGSize = .zero
    @ObservedObject var imageAnimation = ImageAnimation()
    
    var btnBack : some View { Button(action: {
        simpleSuccess()
        withAnimation(.easeOut(duration: 1)){
            audioPlayer?.stop()
            self.presentationMode.wrappedValue.dismiss()
            slideShow.toggle()
        }
        
    }) {
        Image(systemName: "x.circle")
            .resizable()
            .frame(width:UIScreen.main.bounds.width*0.06, height: UIScreen.main.bounds.width*0.06)
            .scaledToFit()
    }
    }
    
    var drag: some Gesture {
        DragGesture().updating($draggingOffset, body: {(value, outValue, _) in
            outValue = value.translation
            imageAnimation.onChange(value: draggingOffset, height: Float(UIScreen.main.bounds.height))
        }).onEnded({(value) in
            var translation = value.translation.height
            if translation < 0{
                translation = -translation
            }
            if translation < 200
            {
                imageAnimation.viewOffset = .zero
                imageAnimation.bgOpacity = 1
            }
            else{
                slideShow = false
                audioPlayer?.stop()
                self.presentationMode.wrappedValue.dismiss()
                imageAnimation.bgOpacity = 1
                imageAnimation.viewOffset = .zero
            }
        })
    }
    
    var body: some View {
        NavigationView{
            GeometryReader{ proxy in
                TabView(selection: $currentIndex) {
                    if favouritesToggle == true && favouriteImages.count != 0 {
                        ForEach(favouriteImages, id: \.self) { image in
                            if let imageURL = image.url {
                                Color.clear.overlay(
                                    CacheAsyncImage(url: imageURL) { phase in
                                        switch phase {
                                        case.success(let image):
                                            image.resizable()
                                                .scaledToFit()
                                                .scaleEffect(scale)
                                                .animation(.linear(duration: 5), value: scale)
                                                .onAppear {
                                                    withAnimation {
                                                        scale = 2
                                                    }
                                                }
                                            
                                        default:
                                            LoadingAnimationView()
                                                .scaledToFit()
                                        }
                                    }
                                )
                                
                                .tag(favouriteImages.firstIndex(of: image) ?? 0)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .aspectRatio(1, contentMode: .fill)
                                
                            }
                            
                            
                        }
                    }
                    else
                    {ForEach(imageViewModel.images, id: \.self) { image in
                        if let imageURL = image.url {
                            Color.clear.overlay(
                                CacheAsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case.success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .scaleEffect(scale)
                                            .animation(.linear(duration: 5), value: scale)
                                            .onAppear {
                                                withAnimation {
                                                    scale = 2
                                                }
                                                
                                            }
                                            .offset(y: imageAnimation.viewOffset.height)
                                        
                                    default:
                                        LoadingAnimationView()
                                            .scaledToFit()
                                    }
                                }
                            )
                            
                            .tag(imageViewModel.images.firstIndex(of: image) ?? 0)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .aspectRatio(1, contentMode: .fill)
                            
                        }
                        
                    }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onReceive(timer, perform: { _ in
                    DispatchQueue.main.async {
                        scale = 1
                    }
                    let totalImages = favouritesToggle ? favouriteImages.count : imageViewModel.images.count
                    withAnimation(.easeOut(duration: 0)){
                        
                        if currentIndex < totalImages - 1 {
                            currentIndex = currentIndex + 1
                            
                        } else {
                            slideShow.toggle()
                            audioPlayer?.stop()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    print("h")
                })
                
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing:
                                    btnBack
                .padding(.trailing, 5))
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    if favouritesToggle == true {
                        let totalImages = favouriteImages.count
                        Text(favouriteImages[currentIndex < totalImages ? currentIndex : 0].title ?? "")
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.3, alignment: .leading)
                            .padding()
                        
                    } else {
                        let totalImages = imageViewModel.images.count
                        Text(imageViewModel.images[currentIndex < totalImages ? currentIndex : 0].title ?? "")
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.3, alignment: .leading)
                            .padding()
                    }
                    
                }
            }
        }
        .onDisappear{
            self.timer.upstream.connect().cancel()
        }
        .onAppear (perform: {
            playSound (sound: "background-music", type: "mp3")
        })
        .opacity(imageAnimation.bgOpacity)
        .gesture(drag)
        
    }
}


