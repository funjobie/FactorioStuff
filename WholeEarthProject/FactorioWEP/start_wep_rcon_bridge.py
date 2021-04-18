import factorio_rcon #https://pypi.org/project/factorio-rcon-py/  needs to install python package factorio-rcon-py
import requests #https://docs.python-requests.org/en/master/ needs to install python package requests
import time
import math
import urllib.parse
import concurrent.futures

commands_to_send_to_rcon = []

def update_chunk(req):
    
  if(req == ""):
    return

  line = req.split(";")
  if len(line) == 4 and line[0].startswith("surface=") and line[1].startswith("x=") and line[2].startswith("y="):
    surface = line[0].split("=")[1]
    chunk_x = line[1].split("=")[1]
    chunk_y = line[2].split("=")[1]
    print("parsing ok: "+ surface + ":" + chunk_x + ":" + chunk_y)
    queryString = "https://8dfgga78zg.execute-api.us-east-2.amazonaws.com/test/cluster?surfaceName=" + urllib.parse.quote_plus(surface)+"&x="+urllib.parse.quote_plus(chunk_x)+"&y="+urllib.parse.quote_plus(chunk_y)
    print("requesting tile from the cloud: " + queryString)
    cloudResponse = requests.get(queryString)
    if(cloudResponse.status_code == 200):
      print("success: " + cloudResponse.text)
      rJson = cloudResponse.json()
            
      tiles = []
      for i in range(32*32):
        tiles.append(rJson["defaultTile"])
      for tileName in rJson["otherTiles"]:
        offset = 0
        for o in rJson["otherTiles"][tileName]:
          offset = offset + o
          tiles[offset] = tileName
            
      rcon_string = "/update_chunk tiles={"
      tileOffset = -1
      for tile in tiles:
        #TODO world wraparound for x/y positions!
        tileOffset = tileOffset + 1
        tileOffset_x = tileOffset % 32
        tileOffset_y = math.floor(tileOffset / 32)
        rcon_string += "{name=\"" + tile + "\",position={"+str(int(chunk_x)*32+tileOffset_x)+","+str(int(chunk_y)*32+tileOffset_y)+"}}"
        if tileOffset != 1023:
          rcon_string += ","
      #TODO shouldn't surface also be coming from the server?
      rcon_string += "} surface=\""+surface+"\" chunk_x="+chunk_x+" chunk_y="+chunk_y
      commands_to_send_to_rcon.append(rcon_string)
      
    else:
      print("error: " + cloudResponse.status_code + " " + cloudResponse.text)
            
  else:
    print("error parsing  RCON_CHUNK_REQ")

def establish_connection():

  try:
    global rcon_client 
    rcon_client = factorio_rcon.RCONClient("127.0.0.1", 4799, "rconpw")
    print("established rcon connection")
    return True
  except:
    print("could not connect to factorio rcon")
    return False

def start_wep_rcon_bridge():
                
  connection_ok = False
  while True:
    time.sleep(1)
    if not connection_ok:
      connection_ok = establish_connection()
    else:
      try:
        response = rcon_client.send_command("/get_chunk_req_list")
      except:
        connection_ok = False
        continue
        print("lost rcon connection")
        
      if response is not None:
        split = response.split("RCON_CHUNK_REQ:")
        with concurrent.futures.ThreadPoolExecutor(max_workers=16) as executor:
          executor.map(update_chunk, split)

        #TODO realize a queue concept to ensure not being blocked by slowest answer

        #convert the array into a dict to hand over to rcon
        commands_to_send_to_rcon_dict = {}
        command_counter = 0
        global commands_to_send_to_rcon
        for command in commands_to_send_to_rcon:
          commands_to_send_to_rcon_dict["cmd"+str(command_counter)] = command
          command_counter = command_counter + 1
        commands_to_send_to_rcon = []
        
        try:
          rcon_response = rcon_client.send_commands(commands_to_send_to_rcon_dict)
        except Exception as err:
          print("couldn't send command to rcon: " + str(err))
          connection_ok = False

if __name__ == "__main__":
  start_wep_rcon_bridge()