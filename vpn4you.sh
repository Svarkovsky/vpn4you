#!/bin/bash
#
####################################################
#   vpn4you                                 2017
####################################################
ver="0.15"
author="@sin-ok"   #                  sin-ok@xmpp.jp
BTC="12WFM3nJHmAHraiLhXn5Qw51fkNBweSKjR"
name="vpn4you"
####################################################
# Цвета
####################################################
g="\033[1;32m"       # green
r="\033[1;31m"       # red
rs="\033[0;031m"     # red slim
bl="\033[1;34m"      # blue
c="\033[1;36m"       # cyan         
br="\033[0;33m"      # brown
y="\033[1;33m"       # yellow
p="\033[1;35m"       # pink
n="\e[1;0m"          # normal
####################################################
# Проверка пользователя
###################################################
if [ `echo -n $USER` != "root" ]
then
    echo
    echo -e ${y}"MESSAGE:"${r}" - ERROR - "${n}"Please run as"${g}" root "${n}" "
    echo
    exit 1
fi
####################################################
# Проверка наличия установленного openvpn
####################################################
openvpn_path=/usr/sbin/openvpn
if [ ! -e $openvpn_path ]; then 
   echo -e ${y}"MESSAGE:"${r}" - ERROR - "
    echo -e ${y}"MESSAGE:"${n}" You need install openvpn or rename path..."
exit 1
fi
####################################################
OUT=$HOME/vpngate
LIST=$OUT/list
LISTFILE=$OUT/list.txt
mkdir -p $OUT $LIST 
####################################################
# Начальное приветствие
#################################################### 
echo -e ${n}"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e ${bl}"                                                           ."${n}""
	sleep 0.05 && echo -e ${y}" "${n}"*                      "${g}"                   "                            ${n}""
	sleep 0.05 && echo -e ${y}"          ___          "${g}"                   "${n}"            *"
	sleep 0.05 && echo -e ${y}"  .,_    '---'    _,.  "${n}".         "${g}" $name"                                  ${n}""
	sleep 0.05 && echo -e ${y}"   \ *-._|\_/|_.-' /   "${g}"                    "              ${bl}"         ."   ${n}""
	sleep 0.05 && echo -e ${y}"    |   =)'T'(=   |    "${g}"                    "
	sleep 0.05 && echo -e ${y}"     \   /*'*\   /     "${n}"        script "${g}" ⓥ $ver "                         ${n}""
	sleep 0.05 && echo -e ${y}"      '._\) (/_.'      "${n}"       "${g}"   "                                     ${n}""
	sleep 0.05 && echo -e ${y}"          | |          "${n}"          "${g}" $author   "                          ${n}"          "
	sleep 0.05 && echo -e ${y}"         /\ /\         "${g}"                    "${n}"*"
	sleep 0.05 && echo -e ${y}"         \ T /         "${g}"        "${n}" *    "                 
	sleep 0.05 && echo -e ${y}"         (/ \)\        "${g}"  "${n}" .          "${n}" "    
	sleep 0.05 && echo -e ${y}"              ))       "${g}"                    "${n}"sin-ok@xmpp.jp"
	sleep 0.05 && echo -e ${y}"             ((        "${g}"Donate:  "                                             ${n}""
	sleep 0.05 && echo -e ${y}"              \)       "${g}"BTC "${n}" $BTC "                                   
echo ""
echo -e ${n}"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
 sleep 2.2
####################################################
# Помощь
####################################################
helpexit() {
	cat <<-_EOF
	usage: $name <action>
	actions:
	    [u] u[pdate]
	    [s] s[orting]
	update   : download and convert files in *.ovpn 
	sorting  : determine the fastest nodes
	files are loaded $LIST/
	_EOF
	exit
}
####################################################
#  Сообщение с параметрами использования
####################################################
if [ -z ${1} ]
then
    echo -e ${y}"MESSAGE:"${r}" Example: "${n}"`basename ${0}` u"${g}"  ◊  "${n}"`basename ${0}` s"
    echo -e ${y}"MESSAGE:"${r}" Usage: "${n}"`basename ${0}` h "
     exit 1
else
    echo
fi
####################################################
# Действия преобразования
####################################################
do_update() {
	wget -O $LISTFILE "http://www.vpngate.net/api/iphone/" ||exit
		tail -n+3 $LISTFILE |head -n-1 |while read s; do
		ip=$(echo $s |cut -d',' -f2)
		score=$(echo $s |cut -d',' -f3)
		country=$(echo $s |cut -d',' -f6 | tr ' ' '_')
        countrycode=$(echo $s |cut -d',' -f7)
		echo $s |cut -d',' -f15 |head -n6 |tail -n1 |base64 -d > $LIST/tmp 2>/dev/null
		proto="$(echo $(egrep "^proto tcp" $LIST/tmp ||echo "proto udp") |cut -d' ' -f2 |tr -d '\r' |tr '[a-z]' '[A-Z]')"
		mv $LIST/tmp "$LIST/vpngate_${ip}_${proto}_${country}.ovpn"
	done
}
####################################################
#  Опции 
####################################################
[ ! -e $LISTFILE ] && do_update

case $1 in
s|sorting)
	[ ! -e $LISTFILE ] && do_update
	#
	;;
u|update)
	do_update
	#
	;;
*)
	helpexit
esac
####################################################
clear
cd /$LIST
lsf="`find . -type f | wc -l`"    # количество файлов 
echo -e ${n}"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"${g}"  work  "${n}"━━━━━━━━━━━━━━━━━"${n}"━━◊  $lsf"  ${g}" ◊"${n}"┓"
echo ""
REZ="/tmp/$(basename $0).REZ.$$.tmp" 
REZzz="/tmp/$(basename $0).REZzz.$$.tmp"                
ls -l *[0-9]* | cut -c 45- > "$REZzz" 
IP=$(curl -s icanhazip.com)   
S=10
L=200

while read lineREZzz  
do   
   while [ "$(pidof openvpn > /dev/null; echo $?)" -eq 0 ]; do kill `pidof openvpn` >/dev/null 2>/dev/null; done
  
     if [ "$(curl -s icanhazip.com)" = "$IP" ] # если подключения через VPN нет, тогда IP = IP 
         then                   
            echo -e "   Verification" "$lineREZzz"    
                  /usr/sbin/openvpn --config "$lineREZzz" --daemon
          sleep "$S"                                            # 10c достаточно, должен подключится ~5c
       if [ "$(curl -s icanhazip.com)" != "$IP" ] 
           then  
              echo -e ${g}"        Successful response"${n}" "
               ms=$[`ping -c 3 -b 8.8.8.8 | grep rtt | cut -d"/" -f5 | cut -d"." -f1 `]
          if [ "$ms" -lt "$L" ] && [ "$ms" -ne 0 ]
              then 
   #              echo  "$ms" 
                  echo "$lineREZzz" "$ms" >>"$REZ"    
   else
      find "$lineREZzz" -delete
          echo -e ${p}"             bad" ${n}"                 delete profile"
    fi
   fi
  fi
done  < "$REZzz" 

  while [ "$(pidof openvpn > /dev/null; echo $?)" -eq 0 ]; do kill `pidof openvpn` >/dev/null 2>/dev/null; done

echo ""
echo -e ${n}"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛" 
####################################################
REZn=$(cat "$REZ" | sort -t" " -k2 -n | uniq)        
find /tmp -name ip_up.log -type f -exec rm {} \; 
echo "$REZn" > /tmp/ip_up.log
clear
####################################################
# Поиск соответствий 
####################################################
l1=`sed -n -e 1p /tmp/ip_up.log | cut -d" " -f1`
line1ip=`sed -n -e 1p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line1ms=`sed -n -e 1p /tmp/ip_up.log | cut -d" " -f2`
l2=`sed -n -e 2p /tmp/ip_up.log | cut -d" " -f1`
line2ip=`sed -n -e 2p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line2ms=`sed -n -e 2p /tmp/ip_up.log | cut -d" " -f2`
l3=`sed -n -e 3p /tmp/ip_up.log | cut -d" " -f1`
line3ip=`sed -n -e 3p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line3ms=`sed -n -e 3p /tmp/ip_up.log | cut -d" " -f2`
l4=`sed -n -e 4p /tmp/ip_up.log | cut -d" " -f1`
line4ip=`sed -n -e 4p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line4ms=`sed -n -e 4p /tmp/ip_up.log | cut -d" " -f2`
l5=`sed -n -e 5p /tmp/ip_up.log | cut -d" " -f1`
line5ip=`sed -n -e 5p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line5ms=`sed -n -e 5p /tmp/ip_up.log | cut -d" " -f2`
l6=`sed -n -e 6p /tmp/ip_up.log | cut -d" " -f1`
line6ip=`sed -n -e 6p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line6ms=`sed -n -e 6p /tmp/ip_up.log | cut -d" " -f2`
l7=`sed -n -e 7p /tmp/ip_up.log | cut -d" " -f1`
line7ip=`sed -n -e 7p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line7ms=`sed -n -e 7p /tmp/ip_up.log | cut -d" " -f2`
l8=`sed -n -e 8p /tmp/ip_up.log | cut -d" " -f1`
line8ip=`sed -n -e 8p /tmp/ip_up.log | cut -d" " -f1 | cut -c 9- | sed -e 's/\_//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | cut -c -16`
line8ms=`sed -n -e 8p /tmp/ip_up.log | cut -d" " -f2`
#################################################### 
# Функции действий
####################################################
function "$l1" {
clear
/usr/sbin/openvpn --config "$l1"
}
function "$l2" {
clear
/usr/sbin/openvpn --config "$l2"
}
function "$l3" {
clear
/usr/sbin/openvpn --config "$l3"
}
function "$l4" {
clear
/usr/sbin/openvpn --config "$l4"
}
function "$l5" {
clear
/usr/sbin/openvpn --config "$l5"
}
function "$l6" {
clear
/usr/sbin/openvpn --config "$l6"
}
function "$l7" {
clear
/usr/sbin/openvpn --config "$l7"
}
function "$l8" {
clear
/usr/sbin/openvpn --config "$l8"
}
# Создаем меню
function menu {
clear
echo -e "\t\t\t\t\t\t\t\t      \n"                   
echo -e ${n}"     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
sleep 0.05s && echo -e "\t1." ${g}"$line1ip    $line1ms ms   "${n}"" 
sleep 0.05s && echo -e ${n}"           $l1 "                                                      
sleep 0.05s && echo -e "\t2." ${g}"$line2ip    $line2ms ms   "${n}"" 
sleep 0.05s && echo -e ${n}"           $l2 "                                                  
sleep 0.05s && echo -e "\t3." ${g}"$line3ip    $line3ms ms   "${n}"" 
sleep 0.05s && echo -e ${n}"           $l3 "                                                 
sleep 0.05s && echo -e "\t4." ${y}"$line4ip    $line4ms ms   "${n}""
sleep 0.05s && echo -e ${n}"           $l4 "                                                  
sleep 0.05s && echo -e "\t5." ${y}"$line5ip    $line5ms ms   "${n}""
sleep 0.05s && echo -e ${n}"           $l5 "                                                
sleep 0.05s && echo -e "\t6." ${y}"$line6ip    $line6ms ms   "${n}""
sleep 0.05s && echo -e ${n}"           $l6 "                                                
sleep 0.05s && echo -e "\t7." ${y}"$line7ip    $line7ms ms   "${n}""
sleep 0.05s && echo -e ${n}"           $l7 "                                                
sleep 0.05s && echo -e "\t8." ${y}"$line8ip    $line8ms ms   "${n}""
sleep 0.05s && echo -e ${n}"           $l8 "                                                
echo -e ${n}"     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"${g}"◊"${n}"━┛"   
 sleep 0.3s 
echo ""
echo -e "\t0.            Exit"
echo -en "\t\tMake a choice: "
read -n 1 option
}
# Используем цикл While и команду Case для меню.
while [ $? -ne 1 ]
do
        menu
        case $option in
0)
        break ;;
1)
        /usr/sbin/openvpn --config "$l1" ;;
2)
        /usr/sbin/openvpn --config "$l2" ;;
3)
        /usr/sbin/openvpn --config "$l3" ;;
4)
        /usr/sbin/openvpn --config "$l4" ;;
5)
        /usr/sbin/openvpn --config "$l5" ;;
6)
        /usr/sbin/openvpn --config "$l6" ;;
7)
        /usr/sbin/openvpn --config "$l7" ;;
8)
        /usr/sbin/openvpn --config "$l8" ;;
*)
        clear
echo " "   
echo -e ${n}"┏"${g}"◊"${n}"  We must make a choice"
echo -e ${n}"┗━━";;
esac
echo -e " "
echo -en "\n\n\t\t\tPress any key to continue"  ${n}"  ━━"${g}"◊"${n}" "
echo -e " "
read -n 1 line
done
clear 
####################################################         
# Удаляем временные файлы
####################################################
if [ -e "$REZ" ]
 then
     rm /tmp/$(basename $0).REZ.*
     if [ -e "$REZzz" ]
        then
       rm /tmp/$(basename $0).REZzz.*
     fi
  fi
####################################################
# Выход
####################################################
