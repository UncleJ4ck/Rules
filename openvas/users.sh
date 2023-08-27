#!/bin/bash

echo "[+] Welcome to the users management script for OpenVas"
echo "[+] Choose what do u want to do"
echo "[+] 1. Add a user"
echo "[+] 2. Delete a user"
echo "[+] 3. Change a user password"
echo "[!] Choose by 1 or 2 or 3"
read -p "[?] > " choice

case $choice in
    1)
        read -p "[?] Enter a new user: " username
        read -s -p "[?] Enter a new password for the user provided: " password
        echo
        echo "[!] List of roles availables: Admin / Guest / Info / Monitor / User / Super Admin / Observer"
        read -p "[?] Enter the role for this user: " role
        docker-compose -f /home/debian/openvas/docker-compose-22.4.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --create-user=$username --role=$role
        docker-compose -f /home/debian/openvas/docker-compose-22.4.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --user=$username --new-password=$password
    ;;
    2)
        read -p "[?] Enter the user to be deleted: " username
        echo
        docker-compose -f /home/debian/openvas/docker-compose-22.4.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --delete-user=$username
    ;;
    3)
        read -p "[?] Enter the user whom you want to change the password for: " username
        read -s -p "[?] Enter the new password: " password
        echo
        docker-compose -f /home/debian/openvas/docker-compose-22.4.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --user=$username --new-password=$password
    ;;
    *)
        echo "[x] Invalid! Please try again"
    ;;
esac

