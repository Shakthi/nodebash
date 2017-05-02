#!/bin/bash


#set -x

function bashnode  {
  local command=bashnode::$1
  shift 1
  $command $@
}


function bashnode::import  {
  local exported=
  local OPTIND

  while getopts "i:" arg; do
  case $arg in
    i) exported=$OPTARG;;

  esac
  done
  shift $((OPTIND-1))

  local importname=$1
  local importedBasename="${importname%%.*}";
  local oldval=$(eval echo \$bashnode_imported_"$importedBasename"__$exported)

  if [[ ! -z "$oldval"  ]] ;then
    return
  fi
  eval bashnode_imported_"$importedBasename"__$exported=1

  eval "$( source $1;)"

}


function bashnode::export  {
   for i in  $*;do
     local exportedPrefixFunction=
     local exportedPrefixVar=

     if [[ x"$exported" != x ]];then
        exportedPrefixFunction=$exported::
        exportedPrefixVar="$exported"_
     fi



    if [[ "$(type -t $i)" = 'function' ]]; then
       echo -n 'function ';
       declare -f $i|sed s"/$i/$exportedPrefixFunction$i/"
       continue;
    fi

    eval content=\$$i

    if [[ x"$content" != x ]]; then
      echo "$exportedPrefixVar$i=$content"
    fi
   done


}


