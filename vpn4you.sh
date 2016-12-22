#!/bin/bash
#
####################################################
#   vpn4you                                 2017
####################################################
ver="0.14"
author="sin-ok"   #    ivansvarkovsky@gmail.com         sin-ok@xmpp.jp
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
	sleep 0.05 && echo -e ${y}"      '._\) (/_.'      "${n}"     developer "${g}" $author   "                      ${n}""
	sleep 0.05 && echo -e ${y}"          | |          "${n}"                    "
	sleep 0.05 && echo -e ${y}"         /\ /\         "${g}"                    "${n}"*"
	sleep 0.05 && echo -e ${y}"         \ T /         "${g}"        "${n}" *    "                 
	sleep 0.05 && echo -e ${y}"         (/ \)\        "${g}"  "${n}" .          "${n}" ivansvarkovsky@gmail.com"    
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
echo -e ${n}"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━"${g}"  work  "${n}"━━━━━━━━━━━━━━━━━"${n}"━━◊  $lsf"  ${g}" ◊"${n}"┓"
####################################################
# Обработка list
####################################################
lsip=$(ls *[0-9]* | cut -c 9- | cut -c -16 | sed -e 's/\_//g' | sed -e 's/\-//g' | tr 'a-z' ' ' | tr 'A-Z' ' ' | grep -v "^$"  | grep -v "^$" | sort -n | uniq)
####################################################
REZ="/tmp/$(basename $0).REZ.$$.tmp"                         # сюда живых и относительно шустрых
uh="/tmp/$(basename $0).uh.$$.tmp"                        # будем держать 
COUNT=3                    # Количество пингов
mmax=150                # 100 ms потолок
mmaxslow=220          # предел  "проходной балл"
z=0
#
echo ""
for mhost in $lsip
 do
# теперь пингаем ищем возвращенные пакеты и дергаем поле с числом
   count=$(ping -c $COUNT $mhost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
# ms среднее значение          -                               c awk округляем до целых
 #  ms=$(ping -c $COUNT -b $mhost | grep rtt | cut -d"/" -f5 | awk '{ split($0, n, "."); print n[1] + (substr(n[2], 1, 1) >= 5 ? 1 : 0) }')
   ms=$(ping -c $COUNT -b $mhost | grep rtt | cut -d"/" -f5 | awk '{ split($0, n, "."); print n[1] + (substr(n[2], 1, 1) >= 5 ? 1 : 0) }' | bc -l)
#   
if [ "$z" = "$count" ]
then
    echo -e "                   $mhost -"${n}" unknown host" ${n}" "                
   echo "$mhost" >> "$uh"
elif [ "$ms" -gt "$mmaxslow" ]
 then
  echo -e "                                  $mhost ($ms ms) -"${p}" slow" ${n}" "  
          echo "$mhost" >> "$uh"     
elif [ "$ms" -gt "$mmax" ]
 then
  echo -e "                                  $mhost ($ms ms) -"${p}" slow" ${n}" "   
  else 
     echo "$ms $mhost" >> "$REZ" 
  echo -e "   $mhost ($ms ms) is"${g}" up " ${n}" "  
  fi
 done  
echo ""
echo -e ${n}"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛" 
####################################################
# Удаляем дохлые хосты
####################################################
while read lineuh           
do           
   find -type f -name "vpngate_"$lineuh"*" -exec rm -f {} \;   #    вот так вот  0_o^ 
done < "$uh"  
clear  

# Проверяем существет ли файл /tmp/$(basename $0).uh.*  и если существует удалим
if [ -e "$uh" ]
then
     rm /tmp/$(basename $0).uh.*
  fi
####################################################
REZn=$(cat "$REZ" | grep -v "^$" | sort -n | uniq | sed 8q)       # (sed 8q)  берем только первые 8 строк 
find /tmp -name ip_up.log -type f -exec rm {} \; 
echo "$REZn" > /tmp/ip_up.log
clear
####################################################
# Чтение построчно из итогового файла
####################################################    cut -d" " -f1 обрезать до первого пробела
# обработка первого куска строки с ms
line1ms="$(sed -n -e 1p /tmp/ip_up.log | cut -d" " -f1)"
line2ms="$(sed -n -e 2p /tmp/ip_up.log | cut -d" " -f1)"
line3ms="$(sed -n -e 3p /tmp/ip_up.log | cut -d" " -f1)"
line4ms="$(sed -n -e 4p /tmp/ip_up.log | cut -d" " -f1)"
line5ms="$(sed -n -e 5p /tmp/ip_up.log | cut -d" " -f1)"
line6ms="$(sed -n -e 6p /tmp/ip_up.log | cut -d" " -f1)"
line7ms="$(sed -n -e 7p /tmp/ip_up.log | cut -d" " -f1)"
line8ms="$(sed -n -e 8p /tmp/ip_up.log | cut -d" " -f1)"
# обработка второго куска строки с ip  # Так тоже можно:  cat ip_up.txt | awk '{print $2}' | tr '(' ' ' | sort -n | sed -e 's/\ //g'
line1ip="$(sed -n -e 1p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line2ip="$(sed -n -e 2p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line3ip="$(sed -n -e 3p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line4ip="$(sed -n -e 4p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line5ip="$(sed -n -e 5p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line6ip="$(sed -n -e 6p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line7ip="$(sed -n -e 7p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
line8ip="$(sed -n -e 8p /tmp/ip_up.log | cut -d" " -f2 | sed -e '1,$ s/.*(/ /g' | sed -e 's/\ //g')"
####################################################
# Поиск соответствия по каталогу 
####################################################
l1="$(find -type f -exec echo {} \; | grep *$line1ip* | cut -c 3-)"
l2="$(find -type f -exec echo {} \; | grep *$line2ip* | cut -c 3-)"
l3="$(find -type f -exec echo {} \; | grep *$line3ip* | cut -c 3-)"
l4="$(find -type f -exec echo {} \; | grep *$line4ip* | cut -c 3-)"
l5="$(find -type f -exec echo {} \; | grep *$line5ip* | cut -c 3-)"
l6="$(find -type f -exec echo {} \; | grep *$line6ip* | cut -c 3-)"        # l6="$(find *$line6ip*)"  
l7="$(find -type f -exec echo {} \; | grep *$line7ip* | cut -c 3-)"
l8="$(find -type f -exec echo {} \; | grep *$line8ip* | cut -c 3-)"    
#################################################### 
# Итоговое меню с выбором 
###
# Создаем функции
####################################################

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
sleep 0.05 && echo -e "\t1." ${g}"$line1ip    $line1ms ms   "${n}"" 
sleep 0.05 && echo -e ${n}"           $l1 "                                                      
sleep 0.05 && echo -e "\t2." ${g}"$line2ip    $line2ms ms   "${n}"" 
sleep 0.05 && echo -e ${n}"           $l2 "                                                  
sleep 0.05 && echo -e "\t3." ${g}"$line3ip    $line3ms ms   "${n}"" 
sleep 0.05 && echo -e ${n}"           $l3 "                                                 
sleep 0.05 && echo -e "\t4." ${y}"$line4ip    $line4ms ms   "${n}""
sleep 0.05 && echo -e ${n}"           $l4 "                                                  
sleep 0.05 && echo -e "\t5." ${y}"$line5ip    $line5ms ms   "${n}""
sleep 0.05 && echo -e ${n}"           $l5 "                                                
sleep 0.05 && echo -e "\t6." ${y}"$line6ip    $line6ms ms   "${n}""
sleep 0.05 && echo -e ${n}"           $l6 "                                                
sleep 0.05 && echo -e "\t7." ${y}"$line7ip    $line7ms ms   "${n}""
sleep 0.05 && echo -e ${n}"           $l7 "                                                
sleep 0.05 && echo -e "\t8." ${y}"$line8ip    $line8ms ms   "${n}""
sleep 0.05 && echo -e ${n}"           $l8 "                                                
echo -e ${n}"     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"${g}"◊"${n}"━┛"   
 sleep 0.5 
echo ""
echo -e "\t0.            Exit"
echo -en "\t\tMake a choice: "
read -n 1 option
}
# Используем цикл While и команду Case для создания меню.
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
# Проверяем существет ли файл /tmp/$(basename $0).REZ.* и если существует удалим
if [ -e "$REZ" ]
then
     rm /tmp/$(basename $0).REZ.*
  fi
####################################################
# Выход
####################################################
