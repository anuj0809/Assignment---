
import Foundation


class ImageAPIViewModel: ObservableObject {
    
    @Published var images = [ImageAPIModel]()
    @Published  var selectedImage = 0
    
    func fetchData() async {
        // create url
        guard let apiURL = URL(string: "https://raw.githubusercontent.com/obvious/take-home-exercise-data/trunk/nasa-pictures.json")
        else {
            print("The URL doesn't work")
            return
        }
        // fetch data from url
        do {
            
            let (data, _ ) = try await URLSession.shared.data(from: apiURL)
            
            // decode the data
            if let decodedResponse = try? JSONDecoder().decode([ImageAPIModel].self, from: data) {
                DispatchQueue.main.async {
                    self.images = decodedResponse.sorted{
                        $0.date ?? "" > $1.date ?? ""
                        
                    }
                }
            }
            
        }
        catch {
            print("The data isn't valid")
        }
        
    }
    
}

