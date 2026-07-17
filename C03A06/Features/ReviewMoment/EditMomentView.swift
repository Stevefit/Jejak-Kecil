import SwiftUI
import SwiftData

struct EditMomentView: View {
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
                        .shadow(color: Color.black.opacity(0.05), radius: 4)
                }

                Spacer()

                Text("Ubah Momen")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Button(action: {
                    moment.shortDescription = descriptionInput
                    moment.timestamp = dateInput
                    isPresented = false
                }) {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.2), radius: 4)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
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

                        Text("Ketuk foto untuk mengubah")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal")
                                .font(.system(size: 18, weight: .bold))

                            DatePicker("", selection: $dateInput, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(24)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deskripsi")
                                .font(.system(size: 18, weight: .bold))

                            TextField("", text: $descriptionInput)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}
