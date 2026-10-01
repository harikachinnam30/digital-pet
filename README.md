\# Digital Pet



\## Overview



Digital Pet is a Flutter application where the user takes care of a virtual pet. The pet has Happiness, Hunger, and Energy levels that change depending on the user's actions and over time.



The main goal is to keep the pet happy and healthy. The player wins by keeping the pet's Happiness above 80 continuously for 3 minutes. The player loses if Hunger reaches 100 while Happiness is 10 or below.



\---



\## Features



\- Custom pet name

\- Happiness meter

\- Hunger meter

\- Energy meter

\- Happy, Neutral, and Unhappy mood states

\- Pet color changes based on mood

\- Mood icons provide an additional non-color mood indicator

\- Feed, Play, and Rest care actions

\- Run and Sleep activities

\- Automatic Hunger increase every 30 seconds

\- Continuous 3-minute win timer

\- Game-over condition

\- Reset and Restart functionality

\- Animated meters

\- Animated pet response

\- Reduced-motion support

\- Automated Flutter tests



\---



\## Game Rules



\### Mood



The pet's mood depends on its Happiness value:



\- Happiness above 70 = Happy

\- Happiness from 30 to 70 = Neutral

\- Happiness below 30 = Unhappy



The pet image also changes color depending on its mood.



Green represents Happy, yellow represents Neutral, and red represents Unhappy.



I also included mood text and different facial-expression icons so the mood is not communicated only through color.



\---



\### Hunger



Hunger automatically increases by 5 every 30 seconds.



I also handled the Hunger overflow rule carefully.



If Hunger changes from 95 to 100 during an automatic hunger tick, Happiness is not reduced.



If another automatic hunger tick happens while Hunger is already at 100, Hunger stays at 100 and Happiness decreases by 20.



All meter values are kept between 0 and 100.



\---



\## Win Condition



To win the game, Happiness must remain strictly above 80 continuously for 3 minutes.



Exactly 80 does not qualify.



When Happiness first goes above 80, the continuous win timer starts.



If Happiness becomes 80 or lower before the 3 minutes are complete, the timer is cancelled.



The next time Happiness goes above 80, a completely new 3-minute timer starts.



If Happiness remains above 80 for the full 3 minutes, the game displays:



`YOU WON!`



After winning, the care and activity buttons are disabled until the user selects Restart Game.



\---



\## Loss Condition



The player loses when both of these conditions are true:



\- Hunger is 100

\- Happiness is 10 or below



When this happens, the application displays:



`GAME OVER`



All care and activity buttons are disabled after the loss.



The user must select Restart Game to begin again.



\---



\## Pet Actions



\### Feed



Feeding the pet reduces Hunger by 10.



The Happiness change is calculated using the resulting Hunger value.



If the resulting Hunger is below 30, Happiness decreases by 20.



Otherwise, Happiness increases by 10.



Feeding also restores a small amount of Energy.



\---



\### Play



Play:



\- Increases Happiness by 15

\- Increases Hunger by 5

\- Uses 10 Energy



If the pet does not have enough Energy, the action is rejected and the user receives feedback.



\---



\### Rest



Rest:



\- Restores Energy

\- Slightly increases Hunger



This gives the player a way to recover Energy before performing more activities.



\---



\### Run



Run is one of the additional activities I added.



Run:



\- Increases Happiness by 20

\- Increases Hunger by 10

\- Uses 20 Energy



The action cannot be performed if the pet does not have enough Energy.



\---



\### Sleep



Sleep:



\- Restores 35 Energy

\- Increases Hunger by 10

\- Decreases Happiness by 5



This creates a tradeoff between restoring Energy and maintaining Happiness.



\---



\## Advanced Features



\### 1. Energy System



I added Energy as an additional pet state.



The player has to consider Energy before performing activities instead of focusing only on Happiness and Hunger.



Play and Run consume Energy, while Rest and Sleep restore it.



Energy is also limited to the 0-100 range.



\---



\### 2. Activity Selection



In addition to the basic Feed, Play, and Rest actions, I added Run and Sleep.



The activities have different effects on Happiness, Hunger, and Energy.



This gives the player more choices for managing the pet's state.



\---



\### 3. Visual Polish and Accessibility



I added multiple visual effects to make state changes easier to understand.



The Happiness, Hunger, and Energy progress bars animate when their values change.



The pet also uses an animated scale effect when its Happiness is high.



I used `ColorFiltered` to change the pet's appearance depending on its mood.



The interface does not depend only on color. It also displays:



\- Happy, Neutral, or Unhappy text

\- Different mood icons

\- Pet messages



I also check the device's reduced-motion setting. When reduced motion is enabled, the animations are removed.



\---



\## Architecture



I separated the game rules from the Flutter user interface.



The main project files are:



\### `lib/pet\_game.dart`



This file contains the game model and rules, including:



\- Happiness

\- Hunger

\- Energy

\- Feed logic

\- Play logic

\- Run logic

\- Rest logic

\- Sleep logic

\- Hunger tick behavior

\- Meter clamping

\- Win state

\- Loss state

\- Reset behavior



\### `lib/main.dart`



This file handles the Flutter interface and application behavior, including:



\- User interface

\- Pet image

\- Pet name

\- Buttons

\- Progress indicators

\- Mood display

\- Animations

\- Hunger timer

\- Continuous win timer

\- User feedback

\- Restart functionality



Separating the model from the UI made the game rules easier to understand and test.



\---



\## Timer Management



The application uses timers for the automatic Hunger behavior and continuous win condition.



The Hunger timer starts when the pet screen is initialized and runs every 30 seconds.



Before starting a new Hunger timer, the previous timer is cancelled. This prevents multiple Hunger timers from running at the same time.



The win timer starts only when Happiness is strictly above 80.



If Happiness falls to 80 or below, the win timer is cancelled.



Both timers are cancelled in `dispose()` when the screen is removed.



Reset also cancels the existing timers before starting a new Hunger timer.



This helps prevent duplicate timers and unwanted state changes.



\---



\## Testing



I created automated tests using `flutter\_test` to verify important game rules and state transitions.



The tests check:



\- Initial game state

\- Feed behavior

\- Resulting Hunger calculation

\- Meter limits between 0 and 100

\- Hunger changing from 95 to 100

\- Hunger overflow behavior at 100

\- Loss condition

\- Win threshold

\- Exactly 80 not qualifying for a win

\- Happiness above 80 qualifying for the win process

\- Continuous win timing

\- Cancelling the win timer when Happiness returns to 80

\- Reset behavior

\- Basic UI loading



I used:



`flutter analyze`



to check the project for code problems.



I also used:



`flutter test`



to run the automated tests.



The automated tests passed successfully.



The final application was run and tested using an Android emulator.



On the emulator, I tested the normal game state, pet interactions, automatic Hunger changes, mood changes, Energy behavior, win condition, loss condition, disabled actions after the game ends, Reset, and Restart Game functionality.



\---



\## Design Tradeoff



One important design decision I made was separating the game rules from the Flutter widgets instead of putting all of the game logic directly inside `setState()`.



This required creating a separate `PetGame` class and an additional Dart file, so the project has slightly more structure and code.



However, I felt this was worth it because it made the rules easier to understand and test independently from the user interface.



For example, I could test edge cases such as Hunger changing from 95 to 100 and the strict Happiness greater-than-80 win requirement without depending on the visual interface.



It also made the main Flutter screen easier to organize because the UI is mainly responsible for displaying the current state and responding to user actions.



\---



\## Screenshots



The following states were tested while running the Digital Pet application on an Android emulator.



\### Normal State



The normal state shows:



\- Pet name

\- Mood

\- Mood icon

\- Pet image

\- Happiness

\- Hunger

\- Energy

\- Play

\- Feed

\- Rest

\- Run

\- Sleep



This state demonstrates the normal interaction screen of the application.



\### Win State



The win state is reached after Happiness remains strictly above 80 continuously for 3 minutes.



The application displays:



`YOU WON!`



The care and activity buttons become disabled and the user is given a Restart Game option.



\### Loss State



The loss state occurs when Hunger reaches 100 while Happiness is 10 or below.



The application displays:



`GAME OVER`



The pet appears in its Unhappy state, the care and activity buttons are disabled, and the user can select Restart Game.



\---



\## Pet Asset Attribution



The dog face image used for the Digital Pet is from OpenMoji.



Asset: Dog Face (U+1F436)



Contributor: Sofie Ascherl



The pet image is stored locally in:



`assets/pet.png`



The asset is used as the main visual representation of the Digital Pet.



\---



\## Project Structure



The important files in the project are:



`lib/main.dart`  

Main Flutter user interface, timers, animations, and interactions.



`lib/pet\_game.dart`  

Separate game model containing the Digital Pet rules and state transitions.



`test/pet\_game\_test.dart`  

Automated tests for the game model.



`test/widget\_test.dart`  

Automated Flutter widget and timer tests.



`assets/pet.png`  

Pet image used by the application.



`README.md`  

Project documentation.



\---



