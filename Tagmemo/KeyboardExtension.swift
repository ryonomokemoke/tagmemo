import SwiftUI
import UIKit

// キーボード制御のためのExtension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// キーボードツールバーに「キーボードを隠す」ボタンを追加するModifier
    func keyboardDoneButton() -> some View {
        self.toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
