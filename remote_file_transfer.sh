#!/bin/bash

#The filename to be copied is taken as a parameter. 
cd /PATH/TO/SOURCE
copy_file_name=$(ls | grep *.csv)

ftp_site="<ftp_ip_address>"
username="<username>"

#source path
source_path="</PATH/TO/SOURCE>"

#remote path
remote_path="</PATH/TO/DESTINATION>"

#copy file
file="*.csv"

cd $source_path


message="$(timout 10s telnet $ftp_site 22 2>&1)"


if [[ $message  == *"No route to host"* ]]
then
        echo  "'"$(date)"' :   ERROR : No route to host '"$ftp_site"'" >> </PATH/TO/LOG>/transfer.log
elif [[ $message == *"refused"* ]]
then
	echo  "'"$(date)"' :   ERROR : Connection refused '"$ftp_site"'" >> </PATH/TO/LOG>/transfer.log
else


FILE_EXIST="</PATH/TO/SOURCE>*.csv"

if ls $source_path/*.csv > /dev/null
then
#####file transfer######
sshpass -p "<PASSWORD>" sftp -oBatchMode=no -b - $username@$ftp_site <<-EOF
cd $remote_path
mput $file
exit
EOF


temp=$?




if [ $temp -eq 0 ]
then

for node in `sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no <username>@<ftp_ip_address> 'cd </PATH/TO/DESTINATION> && ls *.csv'`
do
if [[ $node == $copy_file_name ]];
then
    echo  "'"$(date)"' :   SUCCESS :  '"$copy_file_name"' file named successfully copied " >> </PATH/TO/LOG>/transfer.log
fi
done

rm -rf /PATH/TO/SOURCE*.csv
else
echo  "'"$(date)"' :   ERROR :  SFTP CODE = '"$temp"'" >> </PATH/TO/LOG>/transfer.log
fi

else
echo "'"$(date)"' :   WARNING :  .csv file not found" >> </PATH/TO/LOG>/transfer.log		


fi
fi
