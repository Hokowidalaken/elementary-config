#!/bin/bash      
echo "___________________1 of 8___________________" &&
read -p "`echo $'\n> '`Hej there! This script will guide you through setting up your machine. We'll start by focusing on GUI things. Please note that the script won't continue unless you close the applications that will launch once you're done making changes there. Press [ENTER] to continue..." &&
clear
echo "___________________2 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Power will launch. Please make the changes listed below| `echo $'\n\n> '` -> Buttons: DO NOTHING. `echo $'\n> '` -> Turn off screen...: NEVER. `echo $'\n> '` Plugged In -> Sleep: NEVER. `echo $'\n> '` On Battery -> Sleep: NEVER. `echo $'\n> '` On Battery -> When power is low: DO NOTHING. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
gnome-control-center power &> /dev/null
clear
echo "___________________3 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Notifications will launch. Please make the changes listed below| `echo $'\n\n> '` -> DND (bottom left): Enable. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
gnome-control-center notifications &> /dev/null
clear
echo "___________________4 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Security and Privacy will launch. Please make the changes listed below| `echo $'\n\n> '` Privacy -> Privacy Mode -> ENABLE. `echo $'\n> '` Locking -> Lock on sleep: DISABLE. `echo $'\n> '` Locking -> Lock after screen...: DISABLE. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
gnome-control-center privacy &> /dev/null
clear
echo "___________________5 of 8___________________" &&
read -p "`echo $'\n> '`|Software & Updates will launch. Please make the changes listed below| `echo $'\n\n> '` Updates -> Automatically check for updates: NEVER. `echo $'\n\n>'` |Close Software & Updates when you are done. Press [ENTER] to continue...|" &&
software-properties-gtk &> /dev/null
clear
echo "___________________6 of 8___________________" &&
read -p "`echo $'\n> '`|Your work is mostly done. Here's what will happen now:| `echo $'\n\n> '` Google Chrome will be installed. `echo $'\n>'`  Xdotool will be installed. `echo $'\n> '` Disper will be installed. `echo $'\n> '` The lid handle switch will be disabled. `echo $'\n> '` Autostart files will be created. `echo $'\n> '` The refresh script will be created. `echo $'\n> '` We'll do a full system upgrade and remove unnecessary files. `echo $'\n\n> '`|All of this stuff will take a couple of minutes (up to 20 minutes depending on network speed). Go grab a coffee or something. There are two more step after this. Press [ENTER] to continue..." &&
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &&
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' &&
sudo apt-get update -y && 
sudo apt-get install xdotool -y &&
sudo apt-get install disper -y && 
sudo apt-get install google-chrome-stable -y && 
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf &&
sudo mkdir -p ~/.config/autostart &&
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.config/autostart &&
sudo printf "[Desktop Entry]\nType=Application\nExec=sh -c 'google-chrome-stable --disk-cache-dir=/dev/null -kiosk -incognito \"\" & sleep 10 && xdotool mousemove 0 9999 && ~/.refresh.sh & ~/.wificheck.sh'\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName[en_US]=Chrome\nName=Chrome\nComment[en_US]=\nComment=\n" > ~/.config/autostart/chrome.desktop &&
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.config/autostart &&
sudo printf "#!/bin/bash\nfor (( ; ; ))\ndo\nsleep 60 && xdotool key ctrl+F5\ndone\n" > ~/.refresh.sh &&
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.refresh.sh && 
sudo chmod +x ~/.refresh.sh &&
sudo printf "#!/bin/bash\nsleep 10 &&\nwhile true; do\n    LC_ALL=C nmcli -t -f TYPE,STATE dev | grep wireless:connected\n    if [ \$? -eq 1 ]; then\n        echo 'Device \$(hostname) on \${SSID} network disconnected \$(date -R)' >> ~/wifilog.txt &\n        nmcli nm wifi off && nmcli nm wifi on && sleep 5 && xdotool key CTRL+F5 &&\n        sleep 3\n    fi\n    SSID=\$(iwgetid -r)\n    sleep 5\ndone\n" > ~/.wificheck.sh && 
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.wificheck.sh && 
sudo chmod +x ~/.wificheck.sh &&
sudo apt-get update -y &&  
sudo apt-get dist-upgrade -y &&
sudo apt-get purge apport -y &&
sudo apt-get autoremove -y &&
clear
echo "___________________7 of 8___________________" &&
read -p "The updates are done, Chrome will now launch. Please make it the default browser. Press [ENTER] to continue..." &&
google-chrome &> /dev/null
clear
echo "___________________8 of 8___________________" &&
echo "Would you like to customize URLs and scripts? Selecting 'No' will reboot the machine (1 = Yes / 2 = No)."
select yn in "Yes" "No"; do
    case $yn in
        Yes ) clear;break;;
        No ) sleep 5 && sudo reboot;;
    esac
done
echo "Please enter an URL that you'd like to launch on startup, e.g. https://www.trustpilot.com. WIP: For now please remember to escape characters." &&
read url && sed -i "0,/\"/{s,\",\"$url ,}" ~/.config/autostart/chrome.desktop && clear
echo "Done! Would you like to add another URL (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) clear && echo "Please enter another URL to launch on startup" && read url && sed -i "0,/\"/{s,\",\"$url ,}" ~/.config/autostart/chrome.desktop && echo "Done! Would you like to add another URL (1 = Yes / 2 = No)?"; continue;;
        No ) clear;break;;
    esac
done
echo "Would you like to change any URLs (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
            clear &&
            nurl=$(grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | wc -w) && echo "There are currently $nurl URLs that launch on startup:" && grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | awk '{print $nurl}' &&
            echo "Please specify which URL you'd like to change. You're required to enter a number, e.g. 1 for the first URL, 2 for the second URL, and so on... Entering no number will change all URLs." &&
            read purl && echo "You'll be changing this URL: $(grep -oP '\"\K.*?(?=\")' ~/.config/autostart/chrome.desktop | awk -v purl="$purl" '{print $purl}')" &&
            echo "Please type in the new URL..." && read newurl
            sed -i "s/$(grep -oP '\"\K.*?(?=\")' ~/.config/autostart/chrome.desktop | awk -v purl="$purl" '{print $purl}')/$newurl/g" ~/.config/autostart/chrome.desktop &&
            clear &&            
            echo "Done. Would you like to change another URL (1 = Yes / 2 = No)?"            
            continue;;
        No ) clear;break;;
    esac
done
nurl=$(grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | wc -w) && echo "These $nurl URLs now launch on startup:" && grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | awk '{print $nurl}' &&
echo "Would you like to disable the WiFi check script (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Done." && sed -i "s/& ~\/.wificheck.sh//g" ~/.config/autostart/chrome.desktop; break;;
        No ) clear;break;;
    esac
done
echo "Would you like to disable the Refresh script (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Done." && sed -i "s/& ~\/.refresh.sh//g" ~/.config/autostart/chrome.desktop; break;;
        No ) clear;break;;
    esac
done
read -p "`echo $'\n> '`All done! You can further configure the system (eg sleep time, displays, URLs) by using the config script located in the same folder as this one. Please unplug the USB drive before the system boots as it may default into booting from the USB drive. You can close the Terminal now, unplug the USB drive and restart manually. Alternatively press [ENTER] to restart in 5 seconds, but please wait until the system starts shutting down before unplugging the USB drive..." && sleep 5 && 
sudo reboot
 

