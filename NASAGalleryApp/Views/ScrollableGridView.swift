

import SwiftUI

struct ScrollableGridView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var favouriteImages: FetchedResults<ImageData>
    @ObservedObject var imageViewModel: ImageAPIViewModel
    let columns: [GridItem] = [
        GridItem(.flexible(),spacing: 2.5),
        GridItem(.flexible(),spacing: 2.5),
        GridItem(.flexible(),spacing: 2.5)
    ]
    @Environment(\.colorScheme) var colorScheme
    @Binding var showImageToggle: Bool
    @Binding var slideShow: Bool
    @Binding var favouritesToggle:Bool
    @State var showingAlert: Bool = false
    
    var body: some View {
        ScrollView{
            if favouritesToggle == true && favouriteImages.count == 0 {
                Text("Favourites yet to be added!")
                    .position(x:UIScreen.main.bounds.width/2 , y:UIScreen.main.bounds.height/2.5)
            }
            LazyVGrid(columns: columns,spacing: 2.5) {
                if favouritesToggle == true {
                    if favouriteImages.count != 0 {
                        ForEach(favouriteImages, id: \.self) { image in
                            Button(
                                action:{
                                    
                                    showImageToggle.toggle()
                                    imageViewModel.selectedImage = favouriteImages.firstIndex(of: image) ?? 0
                                    
                                }
                                
                                , label: {
                                    if let imageURL = image.url {
                                        Color.clear.overlay(
                                            CacheAsyncImage(url: imageURL) { phase in
                                                switch phase {
                                                case.success(let image):
                                                    image.resizable()
                                                        .scaledToFill()
                                                default:
                                                    LoadingAnimationView()
                                                }
                                            }
                                        )
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipped()
                                        .tag(favouriteImages.firstIndex(of: image) ?? 0)
                                    }
                                })
                        }
                    }
                }
                else {
                    ForEach(imageViewModel.images, id: \.self) { image in
                        Button(
                            action:{
                                
                                showImageToggle.toggle()
                                imageViewModel.selectedImage = imageViewModel.images.firstIndex(of: image) ?? 0
                            }
                            
                            , label: {
                                if let imageURL = image.url {
                                    Color.clear.overlay(
                                        CacheAsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case.success(let image):
                                                image.resizable()
                                                    .scaledToFill()
                                            default:
                                                LoadingAnimationView()
                                            }
                                        }
                                    )
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipped()
                                    .tag(imageViewModel.images.firstIndex(of: image) ?? 0)
                                }
                            })
                    }
                    
                }
            }
            .padding(5)
        }
        .toolbar
        {
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: {
                    simpleSuccess()
                    withAnimation(.easeOut(duration: 1)){
                        favouritesToggle.toggle()
                    }
                }, label: {
                    favouritesToggle == false ?
                    Image(systemName: "heart")
                        .frame(width:UIScreen.main.bounds.width*0.06, height: UIScreen.main.bounds.width*0.06)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color.clear, radius: 2)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color.clear, radius: 2)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color.clear, radius: 2)
                    :
                    Image(systemName: "heart.fill")
                        .frame(width:UIScreen.main.bounds.width*0.06, height: UIScreen.main.bounds.width*0.06)
                        .shadow(color: colorScheme == .dark ? Color.white : Color.blue.opacity(0.5), radius: 2)
                        .shadow(color: colorScheme == .dark ? Color.white : Color.blue.opacity(0.5), radius: 2)
                        .shadow(color: colorScheme == .dark ? Color.white : Color.blue.opacity(0.5), radius: 2)
                })
                .padding(.leading, 2.5)
            })
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button(
                    action:
                        {
                            simpleSuccess()
                            if favouritesToggle == true && favouriteImages.count == 0 {
                                showingAlert = true
                            }
                            else {
                                
                                withAnimation(.easeOut(duration: 1)){
                                    slideShow = true
                                }
                            }
                        }
                    ,
                    label: {
                        Image("Comet-Icon")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width:UIScreen.main.bounds.width*0.06, height: UIScreen.main.bounds.width*0.06)
                            .scaledToFit()
                            .aspectRatio(1, contentMode: .fit)
                            .buttonStyle(PlainButtonStyle())
                            .shadow(color: colorScheme == .dark ? Color.white : Color.blue, radius: 2)
                            .shadow(color: colorScheme == .dark ? Color.white : Color.blue, radius: 2)
                            .shadow(color: colorScheme == .dark ? Color.white : Color.blue, radius: 2)
                    }
                )
                .padding(.trailing, 2.5)
                .alert("No Favourites Available for Slide Show!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
            })
        }
    }
}


