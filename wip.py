#!/usr/bin/env python3

import sys
import ivars
import os
import subprocess
import datetime
import re
import time

def main(argv):
  prog_name = os.path.basename(argv[0])
  command = get_command(argv)

  if command == 'r':
    should_create_config = first_check(ivars.FIRST, ivars.CONFIG)

    if should_create_config:
      create_config(ivars.CONFIG)

    wake_up_main(ivars.CONFIG)

  elif command == 'h':
    print_readme(ivars.README)

  elif command == 'v':
    print(ivars.VER)

  elif command == 'l':
    print_license(ivars.LICENSE)

  elif command == 'c':
    print("Checking for user config...\n\n")
    if os.path.isfile(ivars.CONFIG):
      print_file(ivars.CONFIG)

    else:
      print(f'{ivars.RED}Config file missing{ivars.RESET}')
      text = f"Do you Want to create one from '{ivars.CONFIG_EXAMPLE}'? [y/n]"
      error_text = "Yes or no please"
      response = get_valid_response(ivars.YES + ivars.NO, text, error_text)

      if response in ivars.YES:
        run_shell_command(f'cp "{ivars.CONFIG_EXAMPLE}" "{ivars.CONFIG}" && {" ".join(ivars.EDITOR_COMMAND)} {ivars.CONFIG}')

      elif response in ivars.NO:
        sys.exit(1)

  elif command == 'e':
    if os.path.isfile(ivars.CONFIG):
      run_shell_command(f'{" ".join(ivars.EDITOR_COMMAND)} {ivars.CONFIG}')

    else:
      print(f'{ivars.RED}Config file missing{ivars.RESET}')

  else:
    print_command_help(prog_name)


def first_check(first_file, config_file):
  if os.path.isfile(first_file):
    return False

  print(f"\n{ivars.RED}First start 'auto-config creator'{ivars.RESET}")

  if os.path.isfile(config_file):
    text = "Want to keep your old config?"
    error_text = "Yes or no please"
    response = get_valid_response(ivars.YES + ivars.NO, text, error_text)

    if response in ivars.YES:
      return False

  return True


def create_config(config_file):
  while True:
    config_data = get_input()
    clear_screen()
    print("This will be your config file.")
    print(get_config_string(config_data, config_file))

    text = "Want to keep it? [y/n/c]:"
    error_text = "Please answer yes,no or cancel."
    response = get_valid_response(ivars.YES + ivars.NO + ivars.CANCEL, text, error_text)

    if response in ivars.YES:
      if os.path.isfile(config_file):
        os.rename(config_file, f"{config_file}-old")

      with open(config_file, 'w') as f:
        f.write(get_config_string(config_data, config_file))
        f.write("\n")

      break

    elif response in ivars.NO:
      clear_screen()
      print("OK, let's start over")

    elif response in ivars.CANCEL:
      print("\nOK, let's end the suffering.")
      sys.exit(0)


def get_input():
  # Auto configure inputs
  config = {}
  config['broadcast'] = input("\nTarget Broadcast IP (i.e 192.168.0.255, get by running 'ifconfig' on the target machine).\n: ")
  config['mac'] = input("\nTarget IP4 Macadress (looks like aa:bb:cc:dd:ee:ff, get by running 'ifconfig' on the target machine).\n: ")
  config['target'] = input("\nTarget machines IP4 number.\n: ")
  config['port'] = input("\nTarget machines SSH port (default 22).\n: ")
  config['ifname'] = input("\nThe name of your local machines network interface (i.e eth0 or enp3s0).\n: ")
  config['user'] = input("""
Your SSH username on the target machine. It will help if this user have
'YOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /bin/systemctl' without the ''
set in /etc/sudoers file on the target machine, this so you dont need to type in passwords 'all' the time.
NOTE! the order in this file matters, try putting it before the last line, (edit with sudo visudo).
: """)
  config['rsa'] = input("\nWhere your SSH RSA key file are located on the local machine.\n: ")
  config['sec'] = input("""
How many seconds do we wait for the target machine to reboot
Raise or lower this if needed (default SEC=60).
: """)

  return config


def get_config_from_file(config_file, tee_file = None):
  config = {
    'BROADCAST': '',
    'MAC':       '',
    'TARGET':    '',
    'PORT':      '',
    'IFNAME':    '',
    'USER':      '',
    'RSA':       '',
    'SEC':       '',
  }

  pattern = re.compile(r"^([A-Z]*?)=(.*)$")

  tee("Checking for user config...\n", tee_file)

  if os.path.isfile(config_file):
    tee(f"{ivars.GREEN}OK{ivars.RESET}\n", tee_file)
  else:
    tee(f"{ivars.RED}FAIL{ivars.RESET}\n", tee_file)
    tee(f"\nCreate a new wol_config.cfg from the wol_config_example.cfg\n", tee_file)
    sys.exit(1)

  file_data = []
  with open(config_file) as f:
    file_data = [row.strip() for row in f.readlines()]

  for row in file_data:
    match = pattern.match(row)
    if match:
      key = match.group(1)
      val = match.group(2)
      config[key] = val

  return config


def get_config_string(config_data, config_file):
  result = f"""
# Start of auto configured {config_file}'
# More info about this config in 'wol_config_example.cfg'
"""

  for k, v in config_data.items():
    result += f"{k.upper()}={v}\n"

  result += f"# End of auto configured '{config_file}'"

  return result


def wake_up_main(config_file):
  log_filename = start_log()
  config = {}

  with open(log_filename, "w") as f:
    tee(f'Wake on Lan and update {ivars.YELLOW}{ivars.VER}{ivars.RESET} - {ivars.GREEN}started{ivars.RESET}: {datetime.datetime.now().strftime("%c")}\n', f)

    check_dep(f)

    config = get_config_from_file(config_file, f)
    with open(config_file) as cf:
      tee(f"{cf.read()}", f)

    tee(f"\n{ivars.GREEN}Waking target up.{ivars.RESET}\n", f)
    #run_shell_command(f"sudo etherwake -i {config['IFNAME']} {config['MAC']} -b {config['BROADCAST']}", False)
    #time.sleep(5)

    tee(f"{ivars.GREEN}Target gone woke, lets update it.{ivars.RESET}\n", f)
    #run_shell_command(f"ssh -i {config['RSA']} -l {config['USER']} {config['TARGET']} -p {config['PORT']} 'sudo apt-get update; sudo apt-get -y upgrade'")

    tee(f"{ivars.GREEN}Update done! Rebooting target.{ivars.RESET}\n", f)
    #run_shell_command(f"ssh -i {config['RSA']} -l {config['USER']} {config['TARGET']} -p {config['PORT']} 'sudo systemctl reboot --now'")

    countdown(int(config['SEC']))

    tee(f"{ivars.GREEN}Target rebooted, lets suspend it until next update.{ivars.RESET}\n", f)
    #run_shell_command(f"ssh -i {config['RSA']} -l {config['USER']} {config['TARGET']} -p {config['PORT']} 'sudo systemctl suspend'")

    tee(f"{ivars.GREEN}Target put to sleep! Ending script.{ivars.RESET}\n", f)

    tee(f'Wake on Lan {ivars.YELLOW}{ivars.VER}{ivars.RESET} - {ivars.RED}stop${ivars.RESET}: {datetime.datetime.now().strftime("%c")}\n', f)

  with open(ivars.FIRST, "w") as f:
    f.write("This file only lets the script 'WoL.sh' know if it is the first start or not, please ignore.\n")


def print_readme(file):
  if os.path.isfile(file):
    print_file(file)

  else:
    print(f'{ivars.RED}Readme file missing{ivars.RESET}')
    sys.exit(1)


def print_license(file):
  if os.path.isfile(file):
    print_file(file)

  else:
    print(f'{ivars.RED}License file missing{ivars.RESET}')
    sys.exit(1)


def print_file(file):
  with open(file) as f:
    print(f.read())


def print_command_help(prog_name):
  print(f"Usage: {prog_name} {{c|e|h|l|r|v}}")
  print(" c, Current config.")
  print(" e, Edit current config.")
  print(" h, Help.")
  print(" l, License.")
  print(" r, Run main script.")
  print(" v, Version.")


def get_command(argv):
  if len(argv) == 2 and argv[1] in ['c', 'e', 'h', 'l', 'r', 'v']:
    return argv[1]
  else:
    return None


def run_shell_command(command, print_command = False):
  if print_command:
    print(command)

  process = subprocess.run(command, shell=True)

  if process.returncode != 0:
    print(f"Error in command: {command}")
    sys.exit(1)


def get_valid_response(responses, question, error_text):
  while True:
    response = input(f'{question} ').lower()

    if response in responses:
      return response

    else:
      print(error_text)


def clear_screen():
  run_shell_command("clear")


def tee(text, f = None):
  if f:
    f.write(text)
  print(text, end="")


def start_log():
  if not os.path.isdir("log"):
    os.mkdir("log")

  filename = f'{datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}.log'
  filename = os.path.join("log", filename)

  return filename


def check_dep(tee_file):
  deps = {
    'etherwake': 'etherwake',
    'ssh':       'openssh-client',
    'systemctl': 'systemd',
  }

  err = False

  for k, v in deps.items():
    process = subprocess.run(['which', k], stdout=subprocess.DEVNULL)
    if process.returncode != 0:
      tee(f"{k} needs to be installed. Use 'sudo apt-get install {v}'", tee_file)
      err = True

  if err:
    tee("\n\nInstall the above and rerun this script\n", tee_file)
    sys.exit(1)

  tee(f"{ivars.GREEN}OK{ivars.RESET}\n", tee_file)


def countdown(s):
  # This version does not log countdown to log file, ince that doesn't really
  # add anything useful to the log
  run_shell_command("tput civis")

  # For compatibility and looks we count down
  # including 0
  while s >= 0:
    sec_color = ivars.RED
    if s <= 30:
      sec_color = ivars.YELLOW
    elif s <= 15:
      sec_color = ivars.GREEN

    print(f"\r{ivars.RESET}seconds to finished reboot: {sec_color}{s:02}{ivars.RESET}", end="")
    s -= 1
    time.sleep(1)

  run_shell_command("tput cnorm")

  # just a newline
  print()


if __name__ == '__main__':
  script_path = os.path.dirname(os.path.realpath(sys.argv[0]))
  os.chdir(script_path)

  try:
    main(sys.argv)

  except KeyboardInterrupt:
    print("\n\nExiting")
    run_shell_command('tput cnorm')
    sys.exit(1)