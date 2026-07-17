import SwiftUI
import SwiftData

struct EditMomentView: View {
    @Environment(\.modelContext) private var modelContext
    var moment: Moment
    @Binding var isPresented: Bool

    @State private var descriptionInput: String
    @State private var dateInput: Date

    init(moment: Moment, isPresented: Binding<Bool>) {
        self.moment = moment
        self._isPresented = isPresented
        self._descriptionInput = State(initialValue: moment.shortDescription ?? "")
        self._dateInput = State(initialValue: moment.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }

                Spacer()
                Text("Ubah Momen")
                    .font(.headline)
                Spacer()

                Button(action: {
                    moment.shortDescription = descriptionInput
                    moment.timestamp = dateInput
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save changes: \(error)")
                    }
                    isPresented = false
                }) {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    Group {
                        if let uiImage = UIImage(data: moment.photo) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 240)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal")
                                .font(.headline)
                            
                            DatePicker("", selection: $dateInput, displayedComponents: [.date])
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deskripsi")
                                .font(.headline)
                            TextField("", text: $descriptionInput)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .background(Color(.systemGray6))
    }
}
