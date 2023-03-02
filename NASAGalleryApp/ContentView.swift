
import SwiftUI

struct ContentView: View {
    @ObservedObject var imageViewModel = ImageAPIViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State var showImageToggle = false
    @State var selectedImage: ImageAPIModel?
    @State var slideShow = false
    @State var favouritesToggle:Bool = false
  
    var body: some View {
            NavigationView{
                ScrollableGridView(imageViewModel: imageViewModel, showImageToggle: $showImageToggle, slideShow: $slideShow, favouritesToggle: $favouritesToggle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar{
                        ToolbarItem(placement: .principal, content: {
                            Text("NASA GALLERY")
                                .font(.system(size:20))
                                .bold()
                        })
                    }
            }
            .task {
                await imageViewModel.fetchData()
            }
            .overlay(content: {
                withAnimation(.easeOut(duration: 0.5)){
                    ZStack{
                        if showImageToggle == true {
                            if favouritesToggle == true {
                                FavouriteSwipeableView(imageViewModel: imageViewModel, showImageToggle: $showImageToggle)
                            }
                            else
                            {
                               
                                    ImageSwipeableView(imageViewModel: imageViewModel,showImageToggle: $showImageToggle)
                                
                            }
                            
                        }
                        if slideShow == true {
                            ImageSlideShowView(imageViewModel: imageViewModel, slideShow: $slideShow, favouritesToggle: $favouritesToggle)
                        }
                        
                    }}
            })
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
