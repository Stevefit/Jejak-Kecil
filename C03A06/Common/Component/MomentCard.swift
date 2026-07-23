import SwiftUI

struct MomentCard: View {
    let moment: Moment

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let uiImage = UIImage(data: moment.photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    ZStack {
                        Color(.systemGray4)
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .aspectRatio(0.8, contentMode: .fit)
        .cornerRadius(16)
    }
}
