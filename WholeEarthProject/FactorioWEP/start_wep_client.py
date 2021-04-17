import wep_settings
import subprocess
import os
from pathlib import Path

def start_wep_client():

  path_to_factorio = wep_settings.get_path_to_factorio()

  ls_output=subprocess.run(path_to_factorio + " --mp-connect 127.0.0.1:4798")

if __name__ == "__main__":
  start_wep_client()