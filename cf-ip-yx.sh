#!/bin/bash
## check os
## download
## decompression
## yx

iscf=$2    
port=$1
case "$port" in
  "")
    proto='http'
    port=80
    ;;
  443|8443|2053|2083|2087|2096)
    proto='https'
    ;;
  80|8080|8880|2052|2082|2086|2095)
    proto='http'
    ;;
  *)
    "error: the port is not supported"
    exit 1
    ;;
esac

check_os_and_arch() {
  if [[ "$(uname)" == 'Linux' ]]; then
    case "$(uname -m)" in
      'i386' | 'i686')
        MACHINE='386'
        ;;
      'amd64' | 'x86_64')
        MACHINE='amd64'
        ;;
      'armv8' | 'aarch64')
        MACHINE='arm64'
        ;;
      *)
        echo "error: The arch is not supported"
        exit 1
        ;;
    esac
    if [[ ! -f '/etc/os-release' ]]; then
      echo "error: Don't use outdated Linux distributions."
      exit 1
    fi  
  else
     echo "error: This operating system is not supported."
     exit 1
  fi
}

download_file() {
  DOWNLOAD_ZIP_LINK="https://xdl.xdawa.shop/https://zip.baipiao.eu.org"
  DOWNLOAD_TAR_LINK="https://xdl.xdawa.shop/https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.5/CloudflareST_linux_$MACHINE.tar.gz"
  while read file link; do
    echo "Downloading $link"
    if ! curl -sSL -o "$file" "$link"; then
      echo "Download $file fail! Please check your network or retry again."
      exit 1
    fi
  done < <(echo $ZIP_FILE $DOWNLOAD_ZIP_LINK;echo $EXEC_FILE $DOWNLOAD_TAR_LINK)
}

decompression() {
  echo "Extracting files..."
  if ! unzip -q "$1" -d "$TMP_DIRECTORY"; then
    echo "error: archive decompression fail!"
    exit 1
  fi
  if ! tar zxf "$2" -C "$TMP_DIRECTORY"; then
    echo "error: archive decompression fail!"
    exit 1
  fi
  echo "Extract the files to $TMP_DIRECTORY and prepare it for yx."
}

exec_yx() {
  
  if [ "$iscf" != "cf" ]; then
    echo -n >$TMP_DIRECTORY/cffip.txt
    for i in `ls $TMP_DIRECTORY | grep "[-]$port.txt"`
    do
      cat $TMP_DIRECTORY/$i >>$TMP_DIRECTORY/cffip.txt
    done
    ipfile=$TMP_DIRECTORY/cffip.txt 
  else
    ipfile=$TMP_DIRECTORY/ip.txt
  fi

  $TMP_DIRECTORY/CloudflareST -tp $port -url=$proto://cs.xdawa.shop -sl 1 -tl 200 -dn 5 -f $ipfile 
  
}

main() {
  check_os_and_arch
  
  [ ! -d cffyx ] && mkdir cffyx

  #TMP_DIRECTORY="$(mktemp -d)"
  TMP_DIRECTORY="cffyx"
  ZIP_FILE="$TMP_DIRECTORY/txt.zip"
  EXEC_FILE="$TMP_DIRECTORY/CloudflareST_linux_$MACHINE.tar.gz"
  
  if [ -x $TMP_DIRECTORY/CloudflareST ]
  then
    exec_yx
  else
    download_file
    decompression "$ZIP_FILE" "$EXEC_FILE"
    exec_yx
  fi
}  

main
