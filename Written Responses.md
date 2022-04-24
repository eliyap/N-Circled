*List the open source software you used and explain why you used it.*  – 350 words
I used [KDTree](https://github.com/Bersaelor/KDTree), an MIT-licensed Swift implementation of the k-dimensional binary space partitioning data structure.

KDTree helps me to find “closest points” much faster than a brute force iteration would. This is important when scoring the “closeness” of a player’s puzzle solution, which requires finding the closest point for each point in a large sample. Using KDTree ensures that scoring is performant, and keeps the game responsive.

At first I used a linear search taking Theta(n) time. However, finding closest points seemed like a common computer science problem and after some research I discovered KDTree. KDTrees typically have performance around Theta(log n) time and never worse than Theta(n). 
Although constructing the tree takes O(n log n) time, the “solution” does not change, so I can reuse the data structure for each sampled point. This improves on the brute force runtime of O(n^2), where n is the number of samples. 

I also used the Apache-2.0-licensed Swift Numerics [ComplexModule](https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md). This module provides a simple API for finding the angle of a complex number, which I leveraged in the “dial” interface element for adjusting a Spinner’s phase.

I also adapted the MIT-licensed [SwiftConfettiView](https://github.com/ugurethemaydin/SwiftConfettiView) to create the “victory” screen. I was unfamiliar with `CAEmitterLayer`, and this sample implementation helped me create a fun player reward.

Additionally, I used code samples from hackingwithswift.com, stackoverflow.com, and guidance from the Apple Developer Forums. These sources are attributed in my code comments.

*Tell us about the features and technologies you used in your app project.* – 350 words
To animate the Inverse Discrete Fourier Transform, I used CoreAnimation’s `CALayer`s, making use of gradients, masks, and transforms to create a performant UI that didn’t sacrifice visual quality. I was shocked to see the Playground consume a mere 1-2% of my phone’s CPU while running. This emboldened me to push further with more complex visuals, such as the confetti and “ribbon streamer” animations.

My user interface was built in SwiftUI. I worked with the underlying Combine APIs to implement shared-state bindings and data persistence. Though I initially intended to implement the IDFT animation in SwiftUI, I couldn’t make it performant, and embedded a `CALayer` via SwiftUI’s UIKit inter-op.

*Beyond WWDC22* 
*If you’ve shared or considered sharing your coding knowledge and enthusiasm for computer science with others, let us know.* – 350 words

I assist with the EE250 (Internet of Things) class at the University of Southern California, and stepped up to develop presentations for the class’s lab assignments.
Engaging visuals were key to my presentations, and it was while introducing the Discrete Fourier Transform that I found YouTube channel 3Blue1Brown’s “circles on circles” vizualisation. Creating an interactive version of that animation was the inspiration for this project. I hope to use N-Circle next semester to show students how combining circles can counterintuitively create “non-circular” shapes.
[Drawing with Circles – 3Blue 1 Brown](https://www.youtube.com/watch?v=r6sGWTCMz2k)

Within Computer Science, I particularly love Swift, and have been fortunate enough to contribute to Paul Hudson’s excellent Hacking with Swift website. Last summer, I created over 400 screenshots for the [SwiftUI By Example](https://www.hackingwithswift.com/quick-start/swiftui) series. By adding example images and videos, as well as alt-text for visually-impaired developers, I hope to make learning SwiftUI easier for all.
This summer, I’ve started making screenshots for Hacking with macOS, and am excited to create more Swift resources!

Finally, I’ve been guiding my brother as he learns programming for the first time before entering college. Talking about print-debugging, the console and other topics has been tremendously fun.

Apps on the App Store
*If you have one or more apps on the App Store created entirely by you as an individual, tell us about them. This will not influence the judging process.* – 350 words
[Hyperthread](https://hyperthread.org/) is my third app on the App Store. It aims to overhaul the “Timeline” experience, by knitting replies, retweets, and quotes into coherent discussions. I found that adding this context made Twitter a lot easier to follow. Unlike the “atomic” twitter timeline, tweets in Hyperthread are always shown as part of a back and forth discussion, allowing me to get more out of Christian Selig’s code QnAs, Steve Troughton-Smith’s "open mic" events, and more.

Hyperthread was also my first wholly UIKit project. Though more challenging than SwiftUI, I’ve found working with UIKit rewarding and engaging, and have had a ton of fun crafting my own Twitter experience. Building a Twitter client from scratch exposed me to Apple’s rich collection of frameworks. I gained special appreciation for frameworks dealing with difficult issues, such as `AuthenticationServices` for OAuth web login, and `CommonCrypto`for hashing strings.

Comments 
*Is there anything else you would like us to know?* – 350 words