import os.path
def get_path_to_factorio():
  path = "D:/Steam/SteamApps/common/Factorio/bin/x64/factorio.exe"
  if os.path.isfile(path):
    return path
  else:
    raise FileNotFoundError("could not find factorio executable. please set path in wep_settings.py")

# if this is true, then the game client is launched from within steam. if "False" the client is opened directly.
# recommended to be "True" as directly launching it produces a warning message from steam which the player needs to click before it actually launches it.
# see discussion in https://steamcommunity.com/discussions/forum/1/458604254465948374/
def get_launch_factorio_through_steam():
  return True
    
# If the above setting is true, the path to steam is needed which will be used to start the factorio client.
def get_path_to_steam():
  path = "D:/Steam/steam.exe"
  if os.path.isfile(path):
    return path
  else:
    raise FileNotFoundError("could not find steam executable. please set path in wep_settings.py")