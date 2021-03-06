import wep_settings
import subprocess
import os
from pathlib import Path

def start_wep_client():

  path_to_mods_folder = Path(os.path.realpath(__file__)).parent / "write-data" / "mods"
  
  if wep_settings.get_launch_factorio_through_steam():
    # 427520 is the app id of factorio (as can be seen from the url of https://store.steampowered.com/app/427520/Factorio/ )
    path_to_steam = wep_settings.get_path_to_steam()
    ls_output=subprocess.run(path_to_steam + " -applaunch 427520 --mp-connect 127.0.0.1:4798 --mod-directory " + str(path_to_mods_folder))
  else:
    path_to_factorio = wep_settings.get_path_to_factorio()
    ls_output=subprocess.run(path_to_factorio + " --mp-connect 127.0.0.1:4798 --mod-directory " + str(path_to_mods_folder))

if __name__ == "__main__":
  start_wep_client()