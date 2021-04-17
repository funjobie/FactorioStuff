import os.path
def get_path_to_factorio():
  path = "D:/Steam/SteamApps/common/Factorio/bin/x64/factorio.exe"
  if os.path.isfile(path):
    return path
  else:
    raise FileNotFoundError("could not find factorio executable. please set path in wep_settings.py")