#!/usr/bin/bash

#this script uses the Minio client library to check for threshold alerts on monitored buckets
#connects to the Minio server, runs some docker commands to get data then does some parsing and
#calculating to determine how much space is used and how close that is to the threshold.

ctr=0

append_to_docker_command() {
   local arg="$1"
   docker run --rm --entrypoint /bin/sh \
       -v /etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt:ro minio/mc "\
       mc alias set minio https://minio.containers.mycomp.com minio_user my_password && $arg"
}

l=`append_to_docker_command "mc find minio | cut -d"/" -f2 | sort -u"`

for f in `echo $1 | cut -d"." -f2`;
do
    q=`append_to_docker_command "mc quota info minio/$f" | grep -v "successfully"`
    s=`append_to_docker_command "mc stat minio/$f" | grep 'Total size' | cut -d":" -f2`

    if [[ "$s" != *"0 B"* ]] && [[ "$q" == *"hard"* ]]; then
        
        ((ctr++))

        q2=`echo $q | cut -d" " -f7,8`
        echo "$ctr) Bucket--> $f"

        #split the variables s and q2 into two parts
        #using read with a space as the delimeter
        read -r nbr bytes <<< "$s"
        read -r value unit <<< "$q2"

        #check if the second part (unit) is "GiB"
        if [[ $unit == "GiB" ]]; then
            #multiply first part (value) by 1024
            result=$(echo "$value * 1024" | bc)
        else:
            result=$(echo "$value")
        fi

        percentage=$(awk "BEGIN { printf \"%.2f\", ($nbr / $result) * 100 }"}

        #output the result
        echo "In MiB, used space ($nbr) is $percentage% of the quota ($result)

        p=$(echo "$percentage > 75" | bc)
        if [ "$p" -eq 1]; then
            echo "Threshold of 75% exceeded, sending alert!"
        fi
    fi
done
