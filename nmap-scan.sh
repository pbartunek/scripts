#!/bin/bash
#
# simple nmap scanning script
#

quickPorts="21,22,23,80,111,443,445,1080,1098,1099,1198,1199,1414,1433,1521,1527,2049,2375,2376,3306,3389,4443,4444,5555,5800,5900,5984,6000,6093,6095,6379,6600,6984,7001,7002,7005,7006,7009,7010,7202,8000,8009,8080,8081,8042,8082,8088,8090,8095,8089,8180,8181,8282,8443,8880,8888,8983,9000,9001,9043,9090,9443,9700,9494,9797,9800,9875,9999,10090,10099,11098,11099,11111,11112,12333,24604,24605,60001,61616"
httpPorts="80,443,3000,5985,8000,8080,8081,8181,8282,8443,8880,9000,9090,9443"
httpScripts="--script=+http-title,+http-userdir-enum,+http-headers,+http-methods,+http-apache-server-status,+http-git,+http-ls,+http-robots.txt"

nmapFlagsServices=" -sTV --version-all -A --script-timeout 1m --randomize-hosts --script-args-file=$( dirname "${BASH_SOURCE[0]}" )/nmap-script.args "
nmapFlags="-vvv --open"
scanType=""
targets=""
listOfHosts=""

while getopts ":sfqvt:T:Hr:L:P" opt; do
  case ${opt} in
    q ) # quick
      scanType="quick"
      nmapFlags="${nmapFlags} -p ${quickPorts}"
      ;;
    s ) # short
      scanType="short"
      nmapFlags="${nmapFlags} "
      ;;
    f ) # full
      scanType="full"
      nmapFlags="${nmapFlags} -p- "
      ;;
    v ) # versions
      scanType="${scanType}_versions"
      nmapFlags="${nmapFlags} ${nmapFlagsServices} "
      ;;
    t ) # targets
      targets=$OPTARG
      nmapFlags="${nmapFlags} $targets"
      ;;
    T ) # targets file
      targets=$OPTARG
      nmapFlags="${nmapFlags} -iL $targets"
      ;;
    L ) # scan from file one by one
      targets=$OPTARG
      echo "Running discovery scan to create a list of targets..."
      listOfHosts=`nmap -sn -iL ${targets} -n | grep "Nmap scan report" | cut -d" " -f5`
      ;;
    H ) # HTTP(S)
      scanType="http"
      nmapFlags="${nmapFlags} -p ${httpPorts} ${httpScripts}"
      ;;
    r ) # max rate
      maxRate=$OPTARG
      nmapFlags="${nmapFlags} --max-rate ${maxRate} "
      ;;
    P ) # no ping
      nmapFlags="${nmapFlags} -Pn "
      ;;
    \? ) # help
      echo "Usage: cmd [-q] [-s] [-f] [-v] [-t|-T] [-r]"
      echo "  -q    quick scan - only selected ports"
      echo "  -s    short scan - default 1000 ports"
      echo "  -f    full scan  - all 65k ports"
      echo "  -v    versions scan"
      echo "  -t    target to scan"
      echo "  -T    text file with targets to scan"
      echo "  -L    scan from file one-by-one"
      echo "  -r    max rate"
      echo "  -H    http scan  - scan common HTTP(s) ports with scripts"
      echo "  -P    no ping"
      ;;
    : )
      echo "Option: $OPTARG requires an argument"
      ;;
  esac
done

if [[ -z "$scanType" ]]; then
  echo "Scan type not set!"
  exit 1
elif [[ -z "$targets" ]]; then
  echo "Targets not set!"
  exit 1
fi

echo -n "Running nmap: "

if [[ -z $listOfHosts ]]; then
  echo "nmap ${nmapFlags}"
  nmapFlags="$nmapFlags -oA nmap_${scanType}"
  nmap ${nmapFlags}
else
  echo "Scanning hosts one-by-one:"
  echo  "${listOfHosts}"
  while IFS= read -r host; do
    echo "Scanning host: $host";
    outFile="nmap_${host}_${scanType}"
    if [[ -f "$outFile" ]]; then
      echo "Output file for host: $host exists, skipping scan"
    else
      nmap ${nmapFlags} -oA $outFile $host
    fi
  done <<< "$listOfHosts"
fi

