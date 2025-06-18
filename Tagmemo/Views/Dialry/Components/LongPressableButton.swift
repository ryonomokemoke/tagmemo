import SwiftUI
struct LongPressableButton<Label>: View  where Label: View{
    
    let label: (() -> Label)
    let tapAction: (() -> Void)?
    let longPressAction: (() -> Void )?
    let minimumDuration:Double
    
    init(label: @escaping (() -> Label), tapAction: (() -> Void)? = nil,
 longPressAction: (() -> Void)? = nil, minimumDuration: Double = 0.5) {
        self.label = label
        self.tapAction = tapAction
        self.longPressAction = longPressAction
        self.minimumDuration = minimumDuration
    }
    var body: some View {
        Button(action: {}){
            label()
                   .onTapGesture(perform: {tapAction?()})
                   .gesture(LongPressGesture(minimumDuration:minimumDuration)
                                 .onEnded({_ in longPressAction?()}))
             }.buttonStyle(.plain)
                    //buttonStyleはdefault以外にしないとrow全体が反応する。
    }
}