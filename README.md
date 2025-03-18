![Wow_what_a_beauty](https://github.com/user-attachments/assets/65915228-f358-4a9a-9fb0-b7d720fa44d8)
![style_and_grace](https://github.com/user-attachments/assets/19a200e2-8de8-4c21-aac2-2e669dc154f2)
# Summary: 
## _"She may not look like much, but she's got it where it counts"_
While I wouldn't hate a spending several more hours polishing up the UI, I'm hoping you're more interested in the architecture. 

# Focus Areas: 
The priority here was implementing TDD and the composition root architecture with a modern SwiftUI app.
This was the first time I've had the chance to build from the ground up using TDD with Swift Testing, which has some really nice features.
The main area of focus for me was modular, loosely coupled architecture using the composition root pattern - all dependencies are composed at the root of the app and injected to where they are needed.
The unit tests run on a macOS target. Blazingly fast.

# Time Spent: 
Well, here's where things went off the rails a bit - I saw the job posting was taken down so I assumed the position had been filled. The market is very much like that right now.
After seeing that I decided to take my time and just do the project for fun - digging into how composable SwiftUI architecture can be, trying to apply design patterns and principles I learned for UIKit etc.
Anyway, I probably spent 5 times longer than I should have. If you want to have a laugh, you can check out the commit history - I think it dates back to early February.
It wasn't until someone from Fetch HR reached out last week that I realized the team was still waiting on this code. My bad.

# Trade-offs and Decisions: 
I spent a lot of time trying to figure out how to configure a clean and modular SwiftUI architecture without falling into its tight-coupling and design anti-pattern traps.
Once I realized I was holding things up I decided to leave a few things for the sake of getting it done.
Error handling is pretty poor, and I built out and tested an ImageData-loadFromCache system which was going to be its own model relationship for quick url-based image lookup, but then I ended up abandoning it for AsyncImage. 
The tests and code are still in there though, I'd like to rip that out. There are also a few integration / end to end tests. Those would be a bigger piece of the puzzle if I'd had a few more weeks.
And, obviously it looks like something out of 2011 - but I think the design ideas are solid. Good protocol abstractions, adapters, very few leaky implementation details. Excited to build more apps like this in the future.

# Weakest Part of the Project: 
![my_project](https://github.com/user-attachments/assets/33799874-dac7-4771-907d-462b9528d7fd)

# Additional Information: 
There were some fun things along the way. AsyncImage doesn't give you access to underlying image data which caused me a couple of headaches right at the buzzer. 
SwiftUI really wants you to couple your (swiftData) data to your views, and add environment objects which aren't checked at compile time etc.
Overall though, loved the experience and I'm excited for where swift and swiftUI is going.
I didn't feel like I was fighting the framework too much to get some good architecture in place. Overall I'm happy with how it turned out - and I appreciate your patience!
