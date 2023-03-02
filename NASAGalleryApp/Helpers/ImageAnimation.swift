

import Foundation
import SwiftUI

class ImageAnimation: ObservableObject {
    
    @Published var bgOpacity: Double = 1
    @Published var viewOffset:CGSize = .zero
    
    func onChange(value: CGSize, height: Float) {
//        DispatchQueue.main.async {
            self.viewOffset = value
            let halfHeight = height / 2
            let progress = Float(value.height) / halfHeight
            self.bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
//        }
    }
    
}

