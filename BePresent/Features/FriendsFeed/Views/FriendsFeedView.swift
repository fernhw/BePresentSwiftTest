//
//  FriendsFeedView.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import SwiftUI



struct PickerReaction: Equatable {
    let activityId: String
    let emoji: String
}

struct FriendsFeedView: View {
    @StateObject private var viewModel = FriendsFeedViewModel()
    @State private var isRefreshing = false
    @State private var displayState: DisplayState = .initial
    @State private var pickerActivity: FriendActivity?
    @State private var pickerReaction: PickerReaction? // Use custom struct
    
    enum DisplayState {
        case initial
        case skeleton
        case initializingList
        case fadingInContent
        case contentOnly
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            mainContentView
        }
        .background(BPColor.background)
        .sheet(isPresented: $viewModel.showReactionPicker) {
            reactionPickerSheet
                .presentationDetents([.fraction(0.33)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
                .onTapGesture {
                    print("Tapped sheet background")
                }
        }
        .onChange(of: viewModel.state) { newState in
            if case .loaded = newState, displayState != .contentOnly {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    displayState = .initializingList
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        displayState = .fadingInContent
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            displayState = .contentOnly
                        }
                    }
                }
            }
        }
        .onAppear {
            displayState = .initial
        }
        .environmentObject(viewModel)
    }
    
    private var headerView: some View {
        HStack {
            Text("Friends Feed")
                .font(.system(size: 23, weight: .bold))
            Spacer()
            Button(action: {
                Task {
                    isRefreshing = true
                    displayState = .skeleton
                    await viewModel.fetchActivities()
                    isRefreshing = false
                }
            }) {
                Text("Refresh")
                    .foregroundColor(BPColor.primaryBlue)
            }
        }
        .padding()
        .background(BPColor.background)
    }
    
    private var mainContentView: some View {
        NavigationView {
            ZStack {
                Color(BPColor.background)
                    .edgesIgnoringSafeArea(.all)
                loadingSkeletonView
                loadedContentView
                errorView
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .background(BPColor.background)
    }
    
    private var loadingSkeletonView: some View {
        Group {
            if displayState == .skeleton || displayState == .fadingInContent || displayState == .initializingList {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            SkeletonCellView(baseDelay: index * 100)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                }
                .opacity((displayState == .skeleton || displayState == .initializingList) ? 1 : 0)
                .animation(.easeInOut(duration: 0.7), value: displayState)
            }
        }
    }
    
    // MARK: Activity List
    private func activityListContent(activities: [FriendActivity], viewModel: FriendsFeedViewModel) -> some View {
        List {
            ForEach(Array(activities.sorted(by: { $0.timestamp > $1.timestamp }).enumerated()), id: \.element.id) { index, activity in
                ActivityCellView(
                    activity: activity,
                    dephaseAnimations: index * 200,
                    onReactionTap: { emoji in
                        if let emoji = emoji {
                            if viewModel.userHasReacted(with: emoji, to: activity) {
                                viewModel.removeReaction(emoji, from: activity)
                            } else {
                                viewModel.addReaction(emoji, to: activity)
                            }
                        }
                    },
                    onSelectorTap: {
                        pickerActivity = activity
                        viewModel.showReactionPicker = true
                    },
                    pickerReaction: $pickerReaction
                )
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: CONTENT LOADED
    private var loadedContentView: some View {
        Group {
            if case .loaded(let activities) = viewModel.state,
               (displayState == .fadingInContent || displayState == .contentOnly || displayState == .initializingList) {
                activityListContent(activities: activities, viewModel: viewModel)
                    .background(BPColor.background)
                    .refreshable {
                        isRefreshing = true
                        displayState = .skeleton
                        await viewModel.fetchActivitiesSafely()
                        isRefreshing = false
                    }
                    .overlay(
                        Group {
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                    .foregroundColor(BPColor.primaryBlue)
                            }
                        }
                    )
                    .opacity((displayState == .contentOnly || displayState == .fadingInContent) ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: displayState)
            }
        }
    }
    
    private var errorView: some View {
        Group {
            if case .error(let message) = viewModel.state {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(.body)
                    Button("Retry") {
                        Task {
                            isRefreshing = true
                            displayState = .skeleton
                            await viewModel.fetchActivitiesSafely()
                            isRefreshing = false
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
    
    private var reactionPickerSheet: some View {
        Group {
            if let activity = pickerActivity {
                ReactionPickerView(
                    activity: activity,
                    selectedEmoji: { emoji in
                        print("Sending emoji '\(emoji)' from picker to '\(activity.activityTitle)' (userId: \(activity.userId))")
                        if !viewModel.userHasReacted(with: emoji, to: activity) {
                            viewModel.addReaction(emoji, to: activity)
                            pickerReaction = PickerReaction(activityId: activity.id, emoji: emoji)
                        }
                        viewModel.showReactionPicker = false
                        pickerActivity = nil
                    }
                )
                .onAppear {
                    print("Reaction picker appeared for '\(activity.activityTitle)' (userId: \(activity.userId))")
                }
            }
        }
    }
}

struct FriendsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsFeedView()
    }
}
