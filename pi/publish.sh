#!/bin/bash
cmd="spawn /usr/bin/rsync -Pvaz --progress"
endpoint="cssgate.insttech.washington.edu:~/public_html/pi"
expect="/usr/bin/expect"

read -p "Enter UW NetID: " username
read -sp "Enter password: " password

gradle build

echo -e "\n### Publishing Java byte code...\n"
${expect} << EOC
set timeout -1
${cmd} build/classes/main/ ${username}@${endpoint}/bin
expect "password:"
send "${password}\r"
expect eof
EOC

echo -e "\n### Publishing php code...\n"
${expect} << EOC
set timeout -1
${cmd} src/com/viveret/pilexa/pi/php/ ${username}@${endpoint}/
expect "password:"
send "${password}\r"
expect eof
EOC

echo -e "\n### Publishing configuration files...\n"
${expect} << EOC
${cmd} build/resources/main/ ${username}@${endpoint}/
expect "password:"
send "${password}\r"
expect eof
EOC

echo -e "\n### Publishing libraries...\n"
gradle copyRuntimeLibs
${expect} << EOC
${cmd} build/dep/ ${username}@${endpoint}/lib
expect "Password:"
send "${password}\r"
expect eof
EOC

echo -e "\n### Done."

# rm $rsyncPassFile