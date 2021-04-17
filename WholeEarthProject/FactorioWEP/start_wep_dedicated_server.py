import wep_settings
import subprocess
import os
from pathlib import Path

def start_wep_dedicated_server():

  path_to_factorio = wep_settings.get_path_to_factorio()
  path_to_config_file = Path(os.path.realpath(__file__)).parent / "wep_dedicated_server_config.ini"
  path_to_write_data = Path(os.path.realpath(__file__)).parent / "write-data"
  if not os.path.isfile(path_to_config_file):
    f = open(path_to_config_file, "w")
    f.write("[path]\n")
    f.write("read-data=__PATH__executable__\..\..\data\n")
    f.write("write-data=" + str(path_to_write_data))
    f.close()
    print("created wep_dedicated_server_config.ini")

  ls_output=subprocess.run(path_to_factorio + " --start-server-load-scenario freeplay --bind 127.0.0.1:4798 --config " + str(path_to_config_file) + " --rcon-port 4799 --rcon-password rconpw")

if __name__ == "__main__":
  start_wep_dedicated_server()