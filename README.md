# Jason Chan iOS Code Test 

## Overview
- Tried to fulfil all requirements stated in document as much as possible (may have gotten carried away in some areas)
- Did not create separate screens for 'cancelling invite' as IMO they are negative User experiences which shoudn't draw attention to those actions. 
- In general positive actions should be large, robust and rewarding to encourage the user to progress through the flow, while negative actions should be subtle and practical.

## Architecture
- Model View Presenter with fully divded with interfaces for maximum testability
- Custom Router/Routing pattern used to delegate (all) navigation away from the View stack (get's messy and hard to maintain in the long run)
- Folders arranged by feature/behaviour


## Tooling
- ReactiveX framework (RxSwift, RxCocoa) which gels well with all async behaviour and updating information across screens with ease
- Cocoapods as dependency manager

## Test
- Made one test for the presenter to showcase the ease of testing each class in isolation

## Design Sources
https://dribbble.com/shots/14765335-Sign-in-Sign-up-form-Mobile/attachments/6469695?mode=media

https://dribbble.com/shots/4601002-The-Broccoli

https://coolors.co/1b3a34-83d4a7-c1a8e4-83d4a7-c1a8e4
