#!/bin/bash

if [ $# -ne 1 ]
        then
        echo "Err: Syntax Error:"
        echo "Usage: ./recon.sh <domain>"
else
        cd /recon/
        echo "Creating working directory, $1 in /recon/"
        mkdir $1
        cd $1

        #find subdomains
        echo "Finding subdomains for $1:"
        bash /root/tools/mytools/subdomains.sh $1
        filename=$1.txt
        num_subs=$(wc -l $1.txt)
        echo "Done, there are $num_subs subdomains in the file: $filename"

        #httprobe them
        echo "Passing those subdomains through httprobe:"
        cat $1.txt | httprobe > $1-httprobe
        num_httprobe=$(wc -l $1-httprobe)
        echo "Done, $num_httprobe urls were found and are in, $1-httprobe"

        #waybackurls
        echo "Running waybackurls in the httprobe resulted urls:"
        touch $1-waybackurls
        cat $1-httprobe | waybackurls >> $1-waybackurls
        echo "The waybackurls are saved in $1-waybackurls file!"

        #find ip addresses
        echo "Trying to find IP Addresses - Note that if the website is protected by a WAF, you might get the IP address of the WAF instead!"
        touch ipaddress.txt
        while IFS="" read -r addr || [ -n "$addr" ]
                do
                        echo "$addr:$(dig +short $addr)" >> ipaddress.txt
        done < $filename
fi
