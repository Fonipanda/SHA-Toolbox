import socket
import sys

def isopen(hostname, port, milliseconds):
  seconds=(int(milliseconds)/1000)%60
  try:
      sock = socket.create_connection((hostname, port), timeout=int(seconds))
      print("connection succeeded")
  except socket.timeout as err:
      print(err)
  except socket.error as err:
      print(err)


if __name__ == "__main__":
  try:
    hostname, port, milliseconds = sys.argv[1:]
    isopen(hostname, port, milliseconds)
  except ValueError:
      print("Not enough arguments")
