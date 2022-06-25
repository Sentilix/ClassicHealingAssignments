ClassicHealingAssignments

1. What is Classic Healing Assignments?
---------------------------------------
Classic Healing Assignments (CHA) let you assign Healers in a raid to Tanks or
Raid markers, and post the assignments in the Raid channel (or a custom healer 
channel if you like).


1.1. How do I use it?
---------------------
Quick your - TL;DR:
Open the CHA user interface by clicking on the [+] icon. This brings up the 
main interface. You must first select a Template, so click a template to the
left side.

Now you can select what role you want to do assignments for: Tanks, Healers 
or Decursers.
Click the role button to switch between roles.

Each role requires one or more targets, so start adding your targets to the 
list. You can then add teanks/healers/decursers by clicking the "+" button 
next to a target.

When you are done, you can close the window.

The [+] button has now changed appearance, if you created a Tank setup, it 
will show a Shield and so on.

To post your assignments by CTRL+Leftclick on the button.
You can also test the assignments by using CTRL+rightclick: this will post
the assignments locally for you only so you can double-check them before
going "live".



2.1 Templates
-------------
A Template contains the entire setup for all three roles, so a full template
have a:
 * List of tank targets + assigned tanks for the tank role
 * List of tanks + assigned healers for the healer role
 * List of targets + assigned decursers for the decurser role.

However, if you do not need decurser or tank assignments, you can just fill in
healer assignments only.

The templates are named after the raids in the current WoW version, but they
are just names without any meaning. You can change the name to whatever, and
add new templates.
For now the number of templates is limited to 15. This is a limitation of the
UI, but I will consider making room for more, should need arise.

Templates:
 * Left-click: Make the selected template the active one.
 * Right-click: Lets you move, rename and delete a template.



2.2 Roles
---------
Classic Healing Assignments (CHA) works with three different roles:
Tank, Healing and Decursing assignment.

The roles are independent, so you can for example create a full healing setup 
without adding tanks in the tank setup - they are just there to make it easy
to do other type of assignments than just healing.

The main window shows what targets are currenty defined. To the right of each 
target is the assigned players (tanks, healers, decursers).

The role defines which targets are eligible:
 - Tank targets can be a Symbol, a Direction or a Custom marker.
 - Healer targets can be (tank)players and symbols.
 - Decursor targets can be players and groups.

You can click on a target icon and move, rename or delete it.

Note:
Raid icons can be renamed, but in the announcements they will be replaced by
their icon. All other renamed targets will appear with the selected name.



2.3 Players
-----------
When a target has been defined you can add players by clicking the "+" button 
next to a target. Each target support up to eight assigned players.

A player can only be assigned as a Tank OR a Healer.
But it IS possible to assign a Healer as a Decurser also.

Clicking on a healer lets you move the player up and down to the next/previous 
target in the list.

Note:
All assigned players are stored on the template to make it easier to reuse
the same plan next raid. This also include players no longer in the raid.

The "Clean up" button will fix this mess by removing all disconnected players
and all players not in the raid from the templates. After this clean-up you
can start filling up the assignments again.



## 3.1 Version 2.x?
The original addon code did not work after patch 1.13.4 / 2.5.1, and required some heavy refactoring to make it work again.
Instead the addon has been rewritten almost from scratch. The UI is close to the original version, but in general there are added more love into maintaining existing templates: you can for example just move a player up/down (previous/next tank) instead of first removing and then adding.

<img src="https://github.com/Sentilix/ClassicHealingAssignments/blob/CHA-2.0/Images/mainframe-2-0-0-a1-healers.JPG?raw=true" />


## 3.2 About CHA.
This addon is a port of Vanilla Healing Assignments, originally made by Renew @ Vanillagaming.org




Version 2.0.0
-------------------
* Added: Options for different name formats.


Version 2.0.0-beta2
-------------------
* Bugfix: Renaming of Templates did not work.


Version 2.0.0-beta1
-------------------
* Added: Responses to "!me" and "!repost" are now working.
* Added: Validation of output channel:
  * /rw without promotion now converts to /r.
  * /rw, /r in party now converts to /p. 
* Added: French translations, thanks to Emboukkan <EU-Nethergarde Keep> for translating.
* Added: Support for Retail (although 99.9% untested since I don't play there)


Version 2.0.0-alpha3
--------------------
* Major refactoring:
    - Removed Roles (Tank, Healer, Decurser): The overall role idea did not work out as expected.
      Instead only Healing Assignments are supported (back to the roots I guess).
	- Redesigned UI (since role buttons where now gone): more space in the overall UI


Version 2.0.0-alpha2
--------------------
* Added configurable texts per role.


Version 2.0.0-alpha1
--------------------
* First working version:

