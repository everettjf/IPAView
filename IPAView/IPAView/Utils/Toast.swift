//
//  Toast.swift
//  IPAView
//
//  Created by everettjf on 2023/12/31.
//

import SwiftUI


extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        ZStack {
            self

            if isShowing.wrappedValue {
                Text(text)
                    .font(.system(size: 14))
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}

struct ToastView: View {
    @State private var showToast = true

    var body: some View {
        Rectangle()
            .frame(width:300, height: 300)
            .toast(isShowing: $showToast, text: "This is a toast message!")

    }
}

#Preview {
    ToastView()
}
