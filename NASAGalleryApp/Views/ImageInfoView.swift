

import SwiftUI

struct ImageInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State var imageInfo : ImageAPIModel?
    var body: some View {
        NavigationView{
            ScrollView {
                Text(imageInfo?.explanation ?? "")
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal,20)
            .offset(y: -30)
            .safeAreaInset(edge: .bottom) {
                Label( imageInfo?.copyright ?? "Info not available",systemImage: "c.circle" )
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                
            }
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text(imageInfo?.title ?? "")
                        .multilineTextAlignment(.center)
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.25, alignment: .center)
                        .padding()
                        .foregroundColor(.blue)
                    
                }
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "x.circle")
                    }
                })
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Text(imageInfo?.serviceVersion ?? "")
                        .foregroundColor(.blue)
                })
            }
        }
    }
}




