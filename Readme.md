Hello, Here It Is

Doing an MVVM architecture, as well as a loading form with Alamofire, while using something like direct 1:1 loading helps Alamofire is stable enough of a package, if you wish I can build the loader, this to streamline the process.

I will make 2 branches
Challenge
ChallengePlus (which you can see here)

Architecture, a scalable form of VVM but if I had more time i'd aim for a Viper lite with some SwiftUI MVVM present and a coordinator layer to ensure fast iteration.

This is still a solid start that can be CHANGED to any of those through simple moving of files.

BePresent/
├── Core/
│   ├── Models/
│   │   ├── FriendActivity.swift
│   │   └── Reaction.swift
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   ├── NetworkMonitor.swift
│   │   └── Repositories/  (no singletons)
│   │       └── FriendsActivityRepository.swift
│   ├── Utilities/
│   │   ├── DateFormatter.swift
│   │   └── ShimmerEffect.swift
│   └── Services/
│       └── ImageCache.swift
├── Features/
│   ├── FriendsFeed/
│   │   ├── ViewModels/
│   │   │   └── FriendsFeedViewModel.swift
│   │   ├── Views/
│   │   │   ├── FriendsFeedView.swift
│   │   │   ├── ActivityCellView.swift
│   │   │   ├── ReactionPickerView.swift
│   │   │   └── SkeletonCellView.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Constants.swift (will be localizations later, only US_EN this moment)
├── BePresentApp.swift  (ROOT)
└── Tests/
    ├── UnitTests/
        │   (later would have a better folder structure)
    │   └── FriendsFeedViewModelTests.swift
    └── UITests/
        └── FriendsFeedUITests.swift


