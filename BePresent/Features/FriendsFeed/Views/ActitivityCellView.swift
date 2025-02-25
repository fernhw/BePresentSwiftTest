//
//  ActivityCellView.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import SwiftUI



struct ActivityCellView: View {
    let activity: FriendActivity
    let dephaseAnimations: Int
    let onReactionTap: (String?) -> Void
    let onSelectorTap: () -> Void
    @Binding var pickerReaction: PickerReaction?
    
    @EnvironmentObject var viewModel: FriendsFeedViewModel
    @State private var animatedEmoji: String?
    @State private var showEmojiAnimation = false
    @State private var cellHop = false
    @State private var reactionToAnimate: String? // Track which reaction capsule to animate
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    UserInfoSection
                    ActivityContentSection
                    ReactionsSection
                }
                EmojiSection
            }
            .padding(.vertical, 9)
            .padding(.leading, 15)
            .padding()
            .background(BPColor.customWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.04), lineWidth: 1)
            )
            .scaleEffect(cellHop ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cellHop)
            
            if let emoji = animatedEmoji {
                Text(emoji)
                    .font(.system(size: 120))
                    .scaleEffect(showEmojiAnimation ? 1.2 : 0.3)
                    .opacity(showEmojiAnimation ? 1.0 : 0.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showEmojiAnimation)
            }
        }
        .onChange(of: pickerReaction) { newReaction in
            if let reaction = newReaction, reaction.activityId == activity.id {
                triggerAnimation(for: reaction.emoji)
                pickerReaction = nil
            }
        }
        .onChange(of: showEmojiAnimation) { isShowing in
            if !isShowing {
                animatedEmoji = nil
            }
        }
    }
    
    // MARK: - User Info Section
    private var UserInfoSection: some View {
        HStack {
            Group {
                if let url = activity.imageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .shimmer(delay: dephaseAnimations)
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                } else {
                    Color.gray.opacity(0.2)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading) {
                Text(activity.name)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(BPColor.primaryBlue)
                    .padding(.bottom, -1)
                Text(formattedTimestamp(for: activity.timestamp))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(BPColor.customGrey)
                    .padding(.top, -1)
            }
            .padding(.leading, 2)
            Spacer()
        }
    }
    
    // MARK: - Activity Content Section
    private var ActivityContentSection: some View {
        HStack {
            Text(activity.activityTitle)
                .font(.system(size: 26, weight: .bold))
                .kerning(1.1)
                .foregroundColor(BPColor.customBlack)
                .multilineTextAlignment(.leading)
        }
        .padding(.top, 7)
        .padding(.trailing, 7)
    }
    
    // MARK: - Reactions Section
    private var ReactionsSection: some View {
        let reactionRows = calculateReactionRows()
        
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<reactionRows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { column in
                        let index = row * 4 + column
                        if index < activity.reactions.count {
                            let reaction = activity.reactions[index]
                            Text("\(reaction.emoji) \(reaction.count)")
                                .font(.system(size: 14))
                                .foregroundColor(BPColor.customGrey)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(BPColor.blueButton)
                                .overlay(
                                    Capsule()
                                        .stroke(viewModel.userHasReacted(with: reaction.emoji, to: activity) ? BPColor.primaryBlue : Color.clear, lineWidth: 2)
                                )
                                .clipShape(Capsule())
                                .scaleEffect(reactionToAnimate == reaction.emoji ? 0.9 : 1.0)
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            if viewModel.userHasReacted(with: reaction.emoji, to: activity) {
                                                print("Removing reaction: \(reaction.emoji) from '\(activity.activityTitle)'")
                                                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                                    reactionToAnimate = reaction.emoji
                                                }
                                                onReactionTap(reaction.emoji)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    reactionToAnimate = nil
                                                }
                                            } else {
                                                print("Adding reaction: \(reaction.emoji) to '\(activity.activityTitle)'")
                                                onReactionTap(reaction.emoji)
                                                triggerAnimation(for: reaction.emoji)
                                            }
                                        }
                                )
                        } else if index == activity.reactions.count {
                            Image(systemName: "plus")
                                .foregroundColor(BPColor.customGrey)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(BPColor.blueButton)
                                .clipShape(Capsule())
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            print("Tapped plus button for '\(activity.activityTitle)'")
                                            onSelectorTap()
                                        }
                                )
                        }
                    }
                }
            }
        }
        .padding(.top, 12)
    }
    
    // MARK: - Emoji Section
    private var EmojiSection: some View {
        VStack {
            Text(activity.activityMainEmoji)
                .font(.system(size: 65))
        }
        .padding(.trailing, 18)
    }
    
    // MARK: - Helper Methods
    internal func calculateReactionRows() -> Int {
        let baseColumnsPerRow = 4
        let reactionCount = activity.reactions.count
        let totalItems = reactionCount + 1
        return (totalItems + baseColumnsPerRow - 1) / baseColumnsPerRow
    }
    
    //internal for tests
    internal func formattedTimestamp(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func triggerAnimation(for emoji: String) {
        animatedEmoji = emoji
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            showEmojiAnimation = true
            cellHop = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                cellHop = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.4)) {
                showEmojiAnimation = false
            }
        }
    }
}

struct ActivityCellView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = FriendActivity(
            userId: "1",
            imageUrl: "https://present-osn776hbea-uc.a.run.app/charles.png",
            name: "Charles",
            timestamp: Date().addingTimeInterval(-3600),
            activityTitle: "100-day 2 hour streak oh wow",
            activityMainEmoji: "🔥",
            reactions: [
                Reaction(emoji: "💪", count: 5),
                Reaction(emoji: "🔥", count: 3),
                Reaction(emoji: "👍", count: 2),
                Reaction(emoji: "😊", count: 1)
            ]
        )
        
        ActivityCellView(
            activity: sampleActivity,
            dephaseAnimations: 0,
            onReactionTap: { _ in },
            onSelectorTap: { },
            pickerReaction: .constant(nil)
        )
        .frame(width: 370)
        .padding()
        .environmentObject(FriendsFeedViewModel())
        .previewLayout(.sizeThatFits)
    }
}
