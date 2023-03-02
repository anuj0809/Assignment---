
import Foundation
import UIKit

func shareButton(url: URL) {
    let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    
    UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
}
