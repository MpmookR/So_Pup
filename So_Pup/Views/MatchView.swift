import SwiftUI
import FirebaseFunctions

struct MatchView: View {
    var body: some View {
        VStack {
            Text("Hello MatchView")
            
            Button("Call Cloud Function") {
                callHelloFunction()
            }
        }
        .onAppear {
            // Optional: call automatically when view appears
            // callHelloFunction()
        }
    }

    func callHelloFunction() {
        Functions.functions().httpsCallable("helloSoPup").call(nil) { result, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            } else if let data = result?.data as? [String: Any],
                      let message = data["message"] as? String {
                print("✅ Backend says: \(message)")
            }
        }
    }
}


#Preview {
    MatchView()
}
