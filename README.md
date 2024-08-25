# Godot 4.3 Steam-Online-Testing Project
This is just a barebones project to see if I'm able to get a multiplayer project working through Steam's multiplayer API using **GodotSteam** and the **SteamMultiplayerPeer** GDExtension. I'll add some notes about where things are just incase anybody looks this over.

## Networking
The scripts handling most everything are `scripts/networking/SteamNetwork.gd`, `scenes/MultiplayerTestScene.gd`, and the various ones inside `lobby/`. The lobby scripts just handle buttons and menus, calling methods from `SteamNetwork.gd`. `MultiplayerTestScene.gd` handles spawning players into the test scene, though if it works correctly or is even a good implimentation (be it temporary) is beyond my knowledge.
