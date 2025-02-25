//
//  ReactionPickerView.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import SwiftUI



struct ReactionPickerView: View {
    let activity: FriendActivity
    let selectedEmoji: (String) -> Void
    private let emojis = Constants.reactionEmojis
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State private var tapStatus = "React with an emoji"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text(tapStatus)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(BPColor.customGrey)
                    .padding(.bottom, 8)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            LazyHGrid(rows: columns, spacing: 23) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .contentShape(Circle())
                        .clipShape(Circle())
                        .onTapGesture {
                            tapStatus = "Tapped emoji: \(emoji) for '\(activity.activityTitle)' (userId: \(activity.userId))"
                            print("Tapped emoji: \(emoji) for '\(activity.activityTitle)' (userId: \(activity.userId))")
                            selectedEmoji(emoji)
                            dismiss()
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .frame(height: 270)
    }
}

struct ReactionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionPickerView(
            activity: FriendActivity(
                userId: "1",
                imageUrl: "",
                name: "Test",
                timestamp: Date(),
                activityTitle: "Test Activity",
                activityMainEmoji: "🔥",
                reactions: []
            ),
            selectedEmoji: { emoji in print("Preview selected: \(emoji)") }
        )
    }
}
