
# BePresent Tester

## Overview


https://github.com/user-attachments/assets/bed3cd1e-88e8-4a2a-a5cf-a44400c10750


Doing an MVVM architecture, as well as a loading form with Alamofire, while using something like direct 1:1 loading helps Alamofire is stable enough of a package, if you wish I can build the loader, this to streamline the process.



Architecture, a scalable form of VVM but if I had more time i'd aim for a Viper lite with some SwiftUI MVVM present and a coordinator layer to ensure fast iteration.

This is still a solid start that can be CHANGED to any of those through simple moving of files.

```
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
        └── FriendsFeedUITes ts.swift 




```

Extras!
* Animated when you Add an emoji and the button when you remove said emoji
* We have a skeleton view which hides loadings, smooth polished animations.
* visual for a bit of charm, a little hop here a small thing there. Pull to reload like twitter

Challenges
Oh boy the challenge was only one and it was doing a ton of unit tests for a small application let me say that. 
* APIs where unidirectional and had to create a repository for user actions which means i had a storage of its recent toying so as to keep it when you pull
* SwiftUI Optimization to prevent visuals from leaking stuff gets destroyed and unalocated
* noticed, I did notice some intentions on date formats, I managed.
* I've been a swift engineer for over 12 years I'm used to the systems, I thank the challenge did some extra as a way to thanks for the reasonable extension.


![Screenshot 2025-02-25 at 5 08 59 PM](https://github.com/user-attachments/assets/77f50e50-ea41-4f2d-9f22-b76d1fa1226b)

A fun addition I did is this, the app should load

![Screenshot 2025-02-25 at 5 09 10 PM](https://github.com/user-attachments/assets/34a08925-4fa3-4b72-8276-d5433f64dcc1)


