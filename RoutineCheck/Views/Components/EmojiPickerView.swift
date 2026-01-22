//
//  EmojiPickerView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/6/26.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    @State private var customEmoji = ""
    @FocusState private var isCustomFieldFocused: Bool

    private let emojiSections: [(title: String, emojis: [String])] = [
        ("Smileys & People", [
            "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
            "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
            "😋", "😛", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥳", "😏",
            "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣", "😖", "😫",
            "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤯", "😳", "🥵",
            "🥶", "😱", "😰", "😥", "😓", "🤗", "🤔", "🫣", "🤭", "🫡",
            "😴", "🤤", "🥴", "🤮", "🤧", "😷", "🤒", "🤕", "🤑", "🤠"
        ]),
        ("Activities & Sports", [
            "⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🥏", "🏓", "🏸",
            "🥊", "🥋", "🎽", "⛳️", "🏌️", "🏂", "⛷️", "🏄‍♀️", "🏊‍♂️", "🚴‍♀️",
            "🚴‍♂️", "🚵‍♀️", "🚵‍♂️", "🤸‍♀️", "🤸‍♂️", "⛹️‍♀️", "⛹️‍♂️", "🤾‍♀️", "🤾‍♂️", "🧘‍♀️",
            "🧗‍♀️", "🧗‍♂️", "🏋️‍♀️", "🏋️‍♂️", "🏇", "🏹", "🎣", "🤿", "🛹", "🛼",
            "🎯", "🥇", "🥈", "🥉", "🏆", "🎳", "🎱", "🥌", "⛸️", "🪁"
        ]),
        ("Animals & Nature", [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
            "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🐣",
            "🐺", "🐗", "🦄", "🦓", "🦒", "🦘", "🦬", "🐘", "🦏", "🦛",
            "🐢", "🐍", "🦎", "🐙", "🦑", "🦞", "🦀", "🐟", "🐬", "🐳",
            "🦋", "🐝", "🐞", "🪲", "🌸", "🌼", "🌻", "🌿", "🍀", "🌵"
        ]),
        ("Food & Drink", [
            "🍎", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🍍",
            "🥭", "🥝", "🍑", "🍐", "🥥", "🍅", "🥑", "🥦", "🥕", "🌽",
            "🧀", "🥖", "🥨", "🥯", "🥞", "🧇", "🍔", "🍟", "🌭", "🍕",
            "🌮", "🌯", "🥗", "🍣", "🍱", "🍜", "🍝", "🍤", "🍩", "🍪",
            "🍫", "🍿", "🧁", "🍰", "🎂", "🍦", "🍨", "🍵", "☕️", "🥤",
            "🍺", "🍷", "🍸", "🍹", "🧃", "🥛", "🧉", "🫖", "🫙", "🧂"
        ]),
        ("Travel & Places", [
            "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚚",
            "🚛", "🚜", "🛴", "🛵", "🚲", "🚂", "🚆", "🚇", "🚊", "✈️",
            "🛫", "🛬", "🚀", "🛰️", "🚢", "⛵️", "🛶", "🗺️", "🗽", "🗼",
            "🏰", "🏯", "🏟️", "🎡", "🎢", "🎠", "🏖️", "🏝️", "⛰️", "🏔️",
            "🌋", "🏜️", "🏞️", "🌁", "🌉", "🌃", "🌆", "🏙️", "🌌", "🛤️"
        ]),
        ("Objects", [
            "⌚️", "📱", "💻", "🖥️", "⌨️", "🖱️", "🖨️", "🕹️", "💾", "📷",
            "📸", "🎥", "📺", "🎧", "🎤", "🔊", "📡", "💡", "🔦", "🕯️",
            "🧯", "🔋", "🔌", "🪫", "🧲", "🧰", "🔧", "🔨", "🪛", "🪚",
            "🧱", "🧪", "🧫", "🧬", "📚", "📖", "📎", "✏️", "🖊️", "📌",
            "📍", "🗂️", "📅", "📌", "✂️", "🧷", "🧹", "🪣", "🪑", "🛋️"
        ]),
        ("Symbols", [
            "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💖",
            "💯", "✅", "☑️", "✔️", "❌", "❎", "❗️", "❓", "‼️", "⚠️",
            "⭐️", "🌟", "✨", "💫", "🔥", "💥", "💤", "➕", "➖", "➗",
            "✖️", "〰️", "💲", "💱", "♻️", "🔁", "🔄", "🔔", "🔕", "🎵",
            "🎶", "🔒", "🔓", "🔑", "🧭", "🛑", "⚡️", "☀️", "🌙", "☁️"
        ])
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 5)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center, spacing: 16) {
                        Text("Enter Any Emoji")
                            .font(.headline)

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.black.opacity(0.06))
                            Text(selectedEmoji.isEmpty ? "🙂" : selectedEmoji)
                                .font(.system(size: 28))
                        }
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.orange.opacity(0.45), radius: selectedEmoji.isEmpty ? 0 : 12, x: 0, y: 0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isCustomFieldFocused = true
                        }

                        TextField("", text: $customEmoji)
                            .frame(width: 1, height: 1)
                            .opacity(0.01)
                            .focused($isCustomFieldFocused)
                            .keyboardType(.default)
                            .onChange(of: customEmoji) { oldValue, newValue in
                                if newValue.isEmpty {
                                    selectedEmoji = ""
                                    customEmoji = ""
                                    return
                                }

                                guard let firstEmoji = newValue.first(where: { $0.isEmoji }) else {
                                    customEmoji = oldValue
                                    return
                                }

                                let sanitized = String(firstEmoji)
                                customEmoji = sanitized
                                selectedEmoji = sanitized
                            }
                    }

                    ForEach(emojiSections, id: \.title) { section in
                        Text(section.title)
                            .font(.headline)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(section.emojis, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                    customEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedEmoji == emoji ? Color.white.opacity(0.08) : Color.clear)
                                        )
                                        .shadow(
                                            color: selectedEmoji == emoji ? Color.orange.opacity(0.45) : Color.clear,
                                            radius: selectedEmoji == emoji ? 10 : 0,
                                            x: 0,
                                            y: 0
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                customEmoji = selectedEmoji
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isCustomFieldFocused = true
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("😀"))
        .preferredColorScheme(.dark)
}
