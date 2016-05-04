#!/bin/bash
# Introduction to the script, telling users what will happen
echo "___________________1 of 8___________________" &&
read -p "`echo $'\n> '`Hej there! This script will guide you through setting up your machine. We'll start by focusing on GUI things. Please note that the script won't continue unless you close the applications that will launch once you're done making changes there. Press [ENTER] to continue..." &&
clear
# Instruction for System Settings - Power menu, what to change where
echo "___________________2 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Power will launch. Please make the changes listed below| `echo $'\n\n> '` -> Buttons: DO NOTHING. `echo $'\n> '` -> Turn off screen...: NEVER. `echo $'\n> '` Plugged In -> Sleep: NEVER. `echo $'\n> '` On Battery -> Sleep: NEVER. `echo $'\n> '` On Battery -> When power is low: DO NOTHING. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
# Launch Power menu
gnome-control-center power &> /dev/null
clear
# Instruction for System Settings - Notifications menu, what to change where
echo "___________________3 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Notifications will launch. Please make the changes listed below| `echo $'\n\n> '` -> DND (bottom left): Enable. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
# Launch Notification menu
gnome-control-center notifications &> /dev/null
clear
# Instruction for System Settings - Security and Privacy menu, what to change where
echo "___________________4 of 8___________________" &&
read -p "`echo $'\n> '`|System Settings - Security and Privacy will launch. Please make the changes listed below| `echo $'\n\n> '` Privacy -> Privacy Mode -> ENABLE. `echo $'\n> '` Locking -> Lock on sleep: DISABLE. `echo $'\n> '` Locking -> Lock after screen...: DISABLE. `echo $'\n\n>'` |Close System Settings when you are done. Press [ENTER] to continue...|" &&
# Launch privacy menu
gnome-control-center privacy &> /dev/null
clear
# Instruction for Software and Updates, what to change where
echo "___________________5 of 8___________________" &&
read -p "`echo $'\n> '`|Software & Updates will launch. Please make the changes listed below| `echo $'\n\n> '` Updates -> Automatically check for updates: NEVER. `echo $'\n\n>'` |Close Software & Updates when you are done. Press [ENTER] to continue...|" &&
# Launch Software and Updates 
software-properties-gtk &> /dev/null
clear
# Telling users what will automatically happen next
echo "___________________6 of 8___________________" &&
read -p "`echo $'\n> '`|Your work is mostly done. Here's what will happen now:| `echo $'\n\n> '` Google Chrome will be installed. `echo $'\n>'`  Xdotool will be installed. `echo $'\n> '` Disper will be installed. `echo $'\n> '` The lid handle switch will be disabled. `echo $'\n> '` Autostart files will be created. `echo $'\n> '` The refresh script will be created. `echo $'\n> '` We'll do a full system upgrade and remove unnecessary files. `echo $'\n\n> '`|All of this stuff will take a couple of minutes (up to 20 minutes depending on network speed). Go grab a coffee or something. There are two more step after this. Press [ENTER] to continue..." &&
# Import public key for Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &&
# Add Chrome package to sources list
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' &&
# Update software repositories
sudo apt-get update -y && 
# Install Xdotool, Disper and finally Chrome
sudo apt-get install xdotool -y &&
sudo apt-get install disper -y && 
sudo apt-get install google-chrome-stable -y && 
# Change HandleLidSwitch to ignore in logind.conf to ignore closing the lid
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf &&
# Create directory autostart
sudo mkdir -p ~/.config/autostart &&
# Change ownership of autostart directory
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.config/autostart &&
# Create chrome.desktop application to launch on startup. Will open URLs and scripts
sudo printf "[Desktop Entry]\nType=Application\nExec=sh -c 'google-chrome-stable --disk-cache-dir=/dev/null -kiosk -incognito placeholder & sleep 10 && xdotool mousemove 0 9999 && ~/.refresh.sh & ~/.wificheck.sh'\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName[en_US]=Chrome\nName=Chrome\nComment[en_US]=\nComment=\n" > ~/.config/autostart/chrome.desktop &&
# Change ownership of autostart directory again so that the application itself has correct rights
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.config/autostart &&
# Create refresh.sh script and change its ownership
sudo printf "#!/bin/bash\nfor (( ; ; ))\ndo\nsleep 1800 && xdotool key ctrl+F5\ndone\n" > ~/.refresh.sh &&
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.refresh.sh && 
# Make refresh.sh executable
sudo chmod +x ~/.refresh.sh &&
# Create wificheck.sh script and change its ownership; make it executable
sudo printf "#!/bin/bash\nsleep 10 &&\nwhile true; do\n    LC_ALL=C nmcli -t -f TYPE,STATE dev | grep wireless:connected\n    if [ \$? -eq 1 ]; then\n        echo 'Device \$(hostname) on \${SSID} network disconnected \$(date -R)' >> ~/wifilog.txt &\n        nmcli nm wifi off && nmcli nm wifi on && sleep 5 && xdotool key CTRL+F5 &&\n        sleep 3\n    fi\n    SSID=\$(iwgetid -r)\n    sleep 5\ndone\n" > ~/.wificheck.sh && 
sudo chown ${USER:=$(/usr/bin/id -run)}:$USER ~/.wificheck.sh && 
sudo chmod +x ~/.wificheck.sh &&
# Update software repositories
sudo apt-get update -y && 
# Start full system upgrade
sudo apt-get dist-upgrade -y &&
# Remove apport (crash reporter)
sudo apt-get purge apport -y &&
# Remove other unnecessary files
sudo apt-get autoremove -y &&
clear
# Informing users that Chrome will launch
echo "___________________7 of 8___________________" &&
read -p "The updates are done, Chrome will now launch. Please make it the default browser. Press [ENTER] to continue..." &&
# Launch Chrome
google-chrome &> /dev/null
clear
# Asking users if they want to continue configuring their setup
echo "___________________8 of 8___________________" &&
echo "Would you like to customize URLs and scripts? Please note that currently no URLs will be launched on startup. Selecting 'No' will reboot the machine (1 = Yes / 2 = No)."
# Yes / No choice
select yn in "Yes" "No"; do
    case $yn in
        # Yes: Continue script below
        Yes ) clear;break;;
        # No: Wait 5 secs and reboot
        No ) sleep 5 && sudo reboot;;
    esac
done
# Inform user what to do
echo "Please enter an URL that you'd like to launch on startup, e.g. https://www.trustpilot.com." &&
# Wait for input, use input to replace placeholder in chrome.desktop
read url && sed -i "0,/placeholder/{s,placeholder,\"$url\" ,}" ~/.config/autostart/chrome.desktop && clear
# Add other URLs?
echo "Done! Would you like to add another URL (1 = Yes / 2 = No)?"
# Yes / No choice
select yn in "Yes" "No"; do
    case $yn in
        # Yes: Wait for input, use input to add URL to chrome.desktop, go back to beginning
        Yes ) clear && echo "Please enter another URL to launch on startup" && read url && sed -i "0,/\"/{s,\", \"$url\" \",}" ~/.config/autostart/chrome.desktop && echo "Done! Would you like to add another URL (1 = Yes / 2 = No)?"; continue;;
        # No: Continue script below
        No ) clear;break;;
    esac
done
# Change any URLs?
echo "Would you like to change any URLs (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        # Yes: Part below
        Yes ) 
            clear &&
            # Show current URLs to user
            nurl=$(grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | wc -w) && echo "There are currently $nurl URLs that launch on startup:" && grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | awk '{print $nurl}' &&
            # Which to change?
            echo "Please specify which URL you'd like to change. You're required to enter a number, e.g. 1 for the first URL, 2 for the second URL, and so on... Entering no number will change all URLs." &&
            # Wait for input, use input to specify URL
            read purl && echo "You'll be changing this URL: $(grep -oP '\"\K.*?(?=\")' ~/.config/autostart/chrome.desktop | awk -v purl="$purl" '{print $purl}')" &&
            # Instruction, wait for input
            echo "Please type in the new URL..." && read newurl
            # Use input to replace URL
            sed -i "s,$(grep -oP '\"\K.*?(?=\")' ~/.config/autostart/chrome.desktop | awk -v purl="$purl" '{print $purl}'),$newurl,g" ~/.config/autostart/chrome.desktop &&
            clear &&
            # Change another URL? 
            echo "Done. Would you like to change another URL (1 = Yes / 2 = No)?"            
            # Go back to beginning
            continue;;
        # No: Continue script below
        No ) clear;break;;
    esac
done
# Inform user which URLs will launch on startup
nurl=$(grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | wc -w) && echo "These $nurl URLs now launch on startup:" && grep -oP "\"\K.*?(?=\")" ~/.config/autostart/chrome.desktop | awk '{print $nurl}' &&
# Asking user if they want to disable the WiFi script, e.g. for Google Slide URLs
echo "Would you like to disable the WiFi check script (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        # Yes: Remove string from chrome.desktop, continue script below
        Yes ) echo "Done." && sed -i "s/& ~\/.wificheck.sh//g" ~/.config/autostart/chrome.desktop; break;;
        # No: Continue script below
        No ) clear;break;;
    esac
done
# Asking user if they want to disable the Refresh script, e.g. for Google Slide URLs
echo "Would you like to disable the Refresh script (1 = Yes / 2 = No)?"
select yn in "Yes" "No"; do
    case $yn in
        # Yes: Remove string from chrome.desktop, continue script below
        Yes ) echo "Done." && sed -i "s/& ~\/.refresh.sh//g" ~/.config/autostart/chrome.desktop; break;;
        # No: Continue script below
        No ) clear;break;;
    esac
done
# Information, cheers you're done!
read -p "`echo $'\n> '`All done! You can further configure the system (eg sleep time, displays, URLs) by using the config script located in the same folder as this one. Please unplug the USB drive before the system boots as it may default into booting from the USB drive. You can close the Terminal now, unplug the USB drive and restart manually. Alternatively press [ENTER] to restart in 5 seconds, but please wait until the system starts shutting down before unplugging the USB drive..." && sleep 5 && 
# Restart machine
sudo reboot
