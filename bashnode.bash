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

  local exportedTag=$exported
  [[ $exportedTag == '-' ]] && exportedTag=

  while (( "$#" )); do
    local importname=$1
    local importedBasename="${importname%%.*}";

    local oldval=$(eval echo \$bashnode_imported_"$importedBasename"__$exportedTag)

    if [[ ! -z "$oldval"  ]] ;then
      return
    fi

    local sourceResult=
    eval "$( source $1 || echo false )" && sourceResult=yes
    if [[ $sourceResult == yes ]]; then
      eval bashnode_imported_"$importedBasename"__$exportedTag=1
    fi
  shift
  done



}


function bashnode::export  {
  local OPTIND

  defaultExported=
  while getopts "o:" arg; do
  case $arg in
    o) defaultExported=$OPTARG;;
  esac
  done
  shift $((OPTIND-1))

  if [[ -z $exported  ]]  ; then
    exported=$defaultExported
  fi

  if [[ $exported == '-' ]];then
    exported=
  fi



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
