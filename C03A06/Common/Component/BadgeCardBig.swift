//
//  BadgeCardBig.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//
import SwiftUI

struct BadgeCardBig: View {
    var body: some View {
        //container
        VStack (alignment: .leading){
            //card
            HStack (spacing: 20) {
                Image("badge")
                    .resizable()
                    .frame(width: 116, height: 125)
                VStack(alignment: .leading){
                    Text("Judul Lencana")
                        .font(.headline)
                        .bold()
                    Text("Deskripsi Lencana")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            //end card
        }
        .padding()
        .frame(maxWidth: .infinity, alignment:.leading)
        //end container
    }
}

#Preview {
    BadgeCardBig()
}
