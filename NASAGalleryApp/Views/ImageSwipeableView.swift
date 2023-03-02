

import SwiftUI

struct ImageSwipeableView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var favouriteImages: FetchedResults<ImageData>
    @ObservedObject var imageViewModel: ImageAPIViewModel
    @ObservedObject var imageAnimation = ImageAnimation()
    @Binding var showImageToggle: Bool
    @State private var showingSheet = false
    @GestureState var draggingOffset: CGSize = .zero
    @State var imageScale: CGFloat = 1
    @State var favouritesToggle = false

    
    func addImageToFav(image : ImageAPIModel){
        let favImage = ImageData(context: moc)
        favImage.copyright = image.copyright
        favImage.date = image.date
        favImage.explanation = image.explanation
        favImage.hdURL = image.hdURL
        favImage.mediaType = image.mediaType
        favImage.serviceVersion = image.serviceVersion
        favImage.title = image.title
        favImage.url = image.url
        try? moc.save()
    }
    
    func deleteImageFromFav(image : ImageAPIModel){
        guard let favImage = favouriteImages.first(where: {$0.date == image.date}) else { return }
        moc.delete(favImage)
        try? moc.save()
    }
    
    func checkIfFav(date: String) -> Bool {
        if(favouriteImages.first(where: {$0.date == date}) == nil)
        {return false} else {return true}
    }
    
    var drag: some Gesture {
        DragGesture().updating($draggingOffset, body: {(value, outValue, _) in
            outValue = value.translation
            imageAnimation.onChange(value: draggingOffset, height: Float(UIScreen.main.bounds.height))
        }).onEnded({(value) in
            var translation = value.translation.height
            if translation < 0 {
                translation = -translation
            }
            if translation < 250
            {
                imageAnimation.bgOpacity = 1
                imageAnimation.viewOffset = .zero
            }
            else{
                showImageToggle = false
                imageAnimation.bgOpacity = 1
                imageAnimation.viewOffset = .zero
                
            }
        })
    }
    
    var body: some View {
        
        NavigationView{
                TabView(selection: $imageViewModel.selectedImage) {
                    ForEach(imageViewModel.images, id: \.self) { image in
                        if let imagehdURL = image.hdURL {
                            Color.clear.overlay(
                                CacheAsyncImage(url: imagehdURL) { phase in
                                    switch phase {
                                    case.success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .scaleEffect(imageScale > 1 ? imageScale : 1)
                                            .offset(y: imageAnimation.viewOffset.height)
                                            .gesture (
                                                MagnificationGesture()  .onChanged ( { (value) in
                                                    imageScale = value
                                                }) .onEnded({ (_) in
                                                    withAnimation (.spring() ){
                                                        imageScale = 1
                                                    }
                                                }))
                                            .simultaneousGesture(TapGesture (count: 2) .onEnded({
                                                withAnimation{
                                                    imageScale = imageScale > 1 ?  1 : 4}}))
                                        
                                    default:
                                        LoadingAnimationView()
                                        
                                    }
                                }
                                
                            )
                            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                            .aspectRatio(1, contentMode: .fill)
                            .tag(imageViewModel.images.firstIndex(of: image) ?? 0)
                        }
                        
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .sheet(isPresented: $showingSheet) {
                } content: {
                    ImageInfoView(imageInfo: imageViewModel.images[imageViewModel.selectedImage])
                        .presentationDetents([.medium])
                }
            
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(imageViewModel.images[imageViewModel.selectedImage].date ?? "")
                        .padding(.leading, UIScreen.main.bounds.width/3)
                }
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button (action: {
                        withAnimation (.default){
                            showImageToggle.toggle()
                        }
                    }
                            , label: {
                        Image (systemName: "x.circle")
                    }
                    )

                })
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        simpleSuccess()
                        checkIfFav(date: imageViewModel.images[imageViewModel.selectedImage].date ?? "") ?
                        deleteImageFromFav(image: imageViewModel.images[imageViewModel.selectedImage]) :
                        addImageToFav(image: imageViewModel.images[imageViewModel.selectedImage])

                    }, label: {
                        checkIfFav(date: imageViewModel.images[imageViewModel.selectedImage].date ?? "") ?
                        Image(systemName: "heart.fill") : Image(systemName: "heart")
                    })

                    Spacer()
                    Button(action: {
                        showingSheet = true
                    }, label: {
                        Label("Info", systemImage: "info.circle")
                    })
                    Spacer()
                    Button (action:{
                        if let hdURL = imageViewModel.images[imageViewModel.selectedImage].hdURL {
                            shareButton(url: hdURL)
                        }
                    }, label: {
                        Label("Share Image", systemImage: "square.and.arrow.up")
                    })
                }
            }
            .offset(y: -35)
        }
        
        .opacity(imageAnimation.bgOpacity)
        .gesture(drag)
      
    }
}

