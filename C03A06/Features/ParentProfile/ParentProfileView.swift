//
//  ParentProfileView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
import SwiftUI

struct ParentProfileView: View {
    var body: some View {
        ZStack{
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            VStack{
                VStack(spacing:4){
                    Image(systemName: "face.smiling.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("Nama Orangtua")
                        .font(.largeTitle)
                    Text("GENDER ORANG TUA")
                        .font(.body)
                }.padding()
                VStack(alignment: .leading,spacing : 8){
                    Text("Daftar lencana")
                        .font(.headline)
                    BadgeGridView()
                }.padding()
            }
        }.navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
}
    
#Preview {
    ParentProfileView()
}
