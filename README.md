# ClassicHealingAssignments

## 1. What is Classic Healing Assignments?
Classic Healing Assignments (CHA) let you assign Healers in a raid to Tanks or Raid markers, and post the assignments in the Raid channel, or a custom healer channel if you like.

<img src="https://github.com/Sentilix/ClassicHealingAssignments/blob/master/Images/assignments-2tanks6heals.JPG?raw=true" />

### 1.1. How do I use it?
Quick tour - TL;DR:
- Open the CHA user interface by clicking on the green PLUS icon. This brings up the main interface.

You must first select a Template, so click a template to the left side, or add a new one using the "Add template" button.
Now you can add Tanks (or tank markers) via the "Add target" button.

And finally you can add healers to those tanks / tank markers by click the "+" button next to each target.
You can click "Texts" to select which channel announcements should be posted in, and configure the texts if you like.

Now you are ready to post your assignments:
* CTRL + Rightclick on the green PLUS button to see your announcements locally (you can check your setup now)
* CTRL + Leftclick on the green PLUS button will post the announcements into the selected channel.


## 2. How to use the Addon
The addon is mainly controlled using the CHA button - the big PLUS button on the screen:
* Left/right-click the button to open the configuration screen.
* CTRL + Rightclick to post announcements locally. Used to check announcements before "going live".
* CTRL + Leftclick to post announcements in the configured chat channel.
* SHIFT + Drag to move the button anywhere on your screen.

<img src="https://github.com/Sentilix/ClassicHealingAssignments/blob/master/Images/assignments-raidchat.JPG?raw=true" />

### 2.1 Templates
A Template is one healer setup configuration (i.e. one boss fight). You an add, modify, rename or delete templates in the list.
Currently the maximum number of templates is dictated by the UI (15).

### 2.1.1 Tanks
Tanks - or tank targets - can be added to a template. When you switch template, you can add another set of tanks to that template. You can move, rename or delete the tanks by rightclicking and opening the options menu.

Note: Raid icons can be renamed, but in the final announcements they will be replaced by their icon. All other renamed targets will appear with the name you chose to give them.


### 2.1.2 Healers
You add healers to a tank by clicking the "+" button next to the tank. Each tank can have up to 8 healers assigned. You can move, rename or remove healers using the rightclick-options.

Note: Any target can only be assigned once on the same template, so you cannot assign a tank, which is also a healer.


## 2.2 Tank and Healer configuration
Tanks and Healers can be configured using the [Tanks] and [Healers] buttons. Here you can configure what type of targets are eligible for tanking / healing, including raid symbols, directions or even your own custom labels.

The configuration is stored per template, so you can have a "AQ40 Twins" template including Warlock tanks for example.

 
## 2.3 Text configuration
The texts used for announcements can be configured when you click the [Texts] button.

<img src="https://github.com/Sentilix/ClassicHealingAssignments/blob/master/Images/assignments-texts.JPG?raw=true" />

Here you can also configure which channel will be used for output, and how player names will be rendered in the output. The last is used for connected realms, as used in Retail and Classic Era/SOM.



# 3. Miscellaneous
## 3.1 Version 2.x?
The original addon code did not work after patch 1.13.4 / 2.5.1, and required some heavy refactoring to make it work again.
Instead the addon has been rewritten almost from scratch. The UI is close to the original version, but in general there are added more love into maintaining existing templates: you can for example move a player up/down (previous/next tank) instead of first removing and then adding.


## 3.2 About CHA.
This addon is a port of Vanilla Healing Assignments addon, originally made by Renew @ Vanillagaming.org
