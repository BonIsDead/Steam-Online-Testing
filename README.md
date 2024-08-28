# Godot 4.3 Steam-Online-Testing Project
This is just a barebones project to see if I'm able to get a multiplayer project working through Steam's multiplayer API using **GodotSteam** and the **SteamMultiplayerPeer** GDExtension. I'll add some notes about where things are just incase anybody looks this over.

<<<<<<< Updated upstream
## Networking
The scripts handling most everything are `scripts/networking/SteamNetwork.gd`, `scenes/Level.gd`, and the various ones inside `lobby/`. The lobby scripts just handle buttons and menus, calling methods from `SteamNetwork.gd`. `Level.gd` handles spawning players into the test scene, though if it works correctly or is even a good implimentation (be it temporary) is beyond my knowledge.

## Voice Chat
Inside `scripts/networking/SteamNetwork.gd` are methods for handling voice chat. `voiceProcess()`, `voiceBufferRead(buffer:PackedByteArray, dataType:VoiceDataType)`, and `voiceRecord()`. Those are the only methods for handling voice chat. I'm enabling recording inside `scripts/PlayerManager.gd` in the `_ready()` function, and I'm setting up the stream playback in `objects/Player.gd`'s `_ready()` function.
At the moment voice chat, from the **GodotSteam** tutorials provided [here](https://godotsteam.com/tutorials/voice/), seem to *almost* be working. Local voice is connected, but the output is just faint clicks and nothing more. Either it's not quite where it needs to be at the moment, or I've glossed over something somewhere.
=======
## Project Theme
Right now, the idea is a 6DoF multiplayer game. Once you start the game, you can move around with `WASD`, and roll left and right with `Q` and `E`. Don't get sick!

## Networking Through Steam
The scripts handling most everything are `scripts/networking/SteamNetwork.gd`, `scenes/Level.gd`, and the various ones inside `lobby/`. The lobby scripts just handle buttons and menus, calling methods from `SteamNetwork.gd`. `Level.gd` handles spawning players into the test scene, though if it works correctly or is even a good implimentation (be it temporary) is beyond my knowledge.

## Proximity Voice Chat
Voice chat has been shelved for now! It's not currently implemented in a way that is useable at the moment.
>>>>>>> Stashed changes
