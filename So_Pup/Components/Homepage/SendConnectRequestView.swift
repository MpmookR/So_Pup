import SwiftUI

struct SendConnectRequestView: View {
    var dogName: String
    var onBack: () -> Void
    var onSend: (_ message: String) -> Void
    
    @State private var message: String = "Hi! Our pups might get along — happy to connect and see if they'd enjoy a walk together! 🐶"

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomNavBar(
                    title: "\(dogName)",
                    showBack: true,
                    onBackTap: onBack,
                    backgroundColor: .white
                )
                
                VStack(spacing: 16) {
                    Text("✍️ Write a quick message to connect")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $message)
                        .padding(12)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .stroke(Color.socialButton, lineWidth: 1.5)
                            )
                    
                    HStack(spacing: 20) {
                        Button("back") {
                            onBack()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 32)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.socialButton, lineWidth: 1.5))
                        .foregroundColor(Color.socialText)
                        .cornerRadius(99)
                        
                        Button("Let's Connect") {
                            onSend(message)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 32)
                        .padding()
                        .background(Color.socialButton)
                        .foregroundColor(Color.socialText)
                        .cornerRadius(99)
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationBarBackButtonHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#Preview {
    SendConnectRequestView(
        dogName: "Scooby",
        onBack: {
            print("Back tapped")
        },
        onSend: { message in
            print("Sent message: \(message)")
        }
    )
}


