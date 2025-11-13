# set -x
Check="OK"
# Control syntax
cat /etc/fstab | grep -v ^# | grep -vw / | awk '{print$2}' | grep -n '/' > /tmp/fstab_chk
cat /tmp/fstab_chk | grep /$ > /dev/null
if [[ $? -eq 0 ]];then
 echo "Syntax Error: fstab entry should not end with a slash: $(grep /$ /tmp/fstab_chk | awk -F ':' '{print$2}' | tr '\n' ' ')"
 Check="KO"
fi

# Control duplicate lines

duplicate_lines=$(cat /tmp/fstab_chk | awk -F ':' '{print$2}' | sort | uniq -d 2>/dev/null)
if [[ "${duplicate_lines}" != "" ]];then
  echo "Syntax Error: fstab contains duplicate filesystems: $(cat /tmp/fstab_chk | awk -F ':' '{print$2}' | sort | uniq -d | tr '\n' ' ')"
  Check="KO"
fi

# Control order
for entry in $(cat /tmp/fstab_chk) ;do
 num=$(echo "${entry}" | awk -F ':' '{print$1}')
 fs=$(echo "${entry}" | awk -F ':' '{print$2}' | sed 's!/$!!')/
 for line in $(cat /tmp/fstab_chk) ;do
   num2=$(echo "${line}" | awk -F ':' '{print$1}')
   fs2=$(echo "${line}" | awk -F ':' '{print$2}' | sed 's!/$!!')
   echo "${fs2}" | grep ^"${fs}" > /dev/null
   if [[ $? -eq 0 ]];then
     if [[ ${num} -gt ${num2} ]];then
       echo "Order Error: ${fs} should be mounted before ${fs2}"
       Check="KO"
     fi
   fi
 done
done

if [[ "${Check}" == "KO" ]];then
 exit 1
fi

