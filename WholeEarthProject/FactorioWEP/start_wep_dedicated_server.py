import wep_settings
import subprocess
import os
from pathlib import Path

def start_wep_dedicated_server():

  path_to_factorio = wep_settings.get_path_to_factorio()
  path_to_config_file = Path(os.path.realpath(__file__)).parent / "wep_dedicated_server_config.ini"
  path_to_write_data = Path(os.path.realpath(__file__)).parent / "write-data"
  path_to_save_folder = Path(os.path.realpath(__file__)).parent / "write-data" / "saves"
  if not os.path.isfile(path_to_config_file):
    f = open(path_to_config_file, "w")
    f.write("[path]\n")
    f.write("read-data=__PATH__executable__\..\..\data\n")
    f.write("write-data=" + str(path_to_write_data))
    f.close()
    print("created wep_dedicated_server_config.ini")

  load_or_start_scenario = " --start-server-load-scenario freeplay"
  if os.path.isdir(path_to_save_folder):
    _, _, filenames = next(os.walk(path_to_save_folder))
    for filename in filenames:
      if filename.endswith(".zip"):
        load_or_start_scenario = " --start-server-load-latest"
        print("found a zip file in saves folder, attempt to load last save game")
        break
    
  ls_output=subprocess.run(path_to_factorio + load_or_start_scenario + " --bind 127.0.0.1:4798 --config " + str(path_to_config_file) + " --rcon-port 4799 --rcon-password rconpw")

if __name__ == "__main__":
  start_wep_dedicated_server()