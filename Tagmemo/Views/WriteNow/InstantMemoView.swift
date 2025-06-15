import SwiftUI

struct InstantMemoView: View {
    @State private var memoText: String = ""
    @State private var isShowingDiary = false
    @FocusState private var isFocused: Bool
    @StateObject private var memoStore = MemoStore()

    var body: some View {
        ZStack {
            Color(red: 0.9, green: 0.95, blue: 1.0)
                .ignoresSafeArea()

            VStack {
                TextEditor(text: $memoText)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(Color(red: 0.4, green: 0.45, blue: 0.6))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding()
                Spacer()
            }
            .onAppear {
                // アプリ起動時にキーボードを自動表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }

            HStack {
                // 日記画面へのボタン
                Button(action: {
                    isShowingDiary = true
                }) {
                    Image(systemName: "book")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $isShowingDiary) {
                    DiaryView(memoStore: memoStore)
                }

                Spacer()

                Button(action: {
                    saveCurrentMemo()
                    memoText = ""
                    isFocused = false
                    hideKeyboard()
                }) {
                    Image(systemName: "arrow.turn.up.right")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .keyboardDoneButton() // 統一されたキーボード制御
    }

    private func saveCurrentMemo() {
        guard !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        memoStore.add(memoContent: memoText)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
