#!/bin/bash
#
# simple nmap scanning script
#

quickPorts="21,22,23,80,111,443,445,1080,1098,1099,1198,1199,1414,1433,1521,2375,3306,3389,4443,4444,5555,5800,5900,6000,6379,6600,7001,7002,7202,8000,8009,8080,8081,8042,8082,8088,8090,8089,8181,8282,8443,8888,9000,9001,9043,9090,9443,9700,9494,9797,9800,9875,9999,10090,10099,11098,11099,11111,11112"
httpPorts="80,443,3000,5985,8000,8080,8081,8181,8282,8443,8880,9000,9090,9443"

httpScripts="--script=http-title.nse --script=http-userdir-enum.nse \
        --script=http-headers.nse --script=http-methods.nse \
        --script=http-apache-server-status.nse --script=http-git.nse \
        --script=http-ls.nse --script=http-robots.txt.nse \
        --script http-wordpress-enum --script-args check-latest=true,search-limit=10"

nmapFlagsServices=" -sTV --version-all -A "
nmapFlags="-vvv --open"
scanType=""
targets=""

while getopts ":sfqvt:T:Hr:" opt; do
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
      nmapFlags=" -p- "
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
    H ) # HTTP(S)
      scanType="http"
      nmapFlags="${nmapFlags} -p ${httpPorts} ${httpScripts}"
      ;;
    r ) # max rate
      maxRate=$OPTARG
      nmapFlags="${nmapFlags} --max-rate ${maxRate} "
      ;;
    \? ) # help
      echo "Usage: cmd [-q] [-s] [-f] [-v] [-t|-T] [-r]"
      echo "  -q    quick scan - only selected ports"
      echo "  -s    short scan - default 1000 ports"
      echo "  -f    full scan  - all 65k ports"
      echo "  -v    versions scan"
      echo "  -t    target to scan"
      echo "  -T    text file with targets to scan"
      echo "  -r    max rate"
      echo "  -H    http scan  - scan common HTTP(s) ports with scripts"
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

nmapFlags="$nmapFlags -oA nmap_${scanType}"

echo -n "Running nmap: "
echo "nmap ${nmapFlags}"

nmap ${nmapFlags}
