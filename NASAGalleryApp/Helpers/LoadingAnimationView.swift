
import SwiftUI

struct LoadingAnimationView: View {
    
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 4)
                .frame(width: 17.5, height: 17.5)
            
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 17.5, height: 17.5)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .onAppear() {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)){
                        self.isLoading = true
                    }
                }
        }
    }
}
