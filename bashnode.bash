#!/bin/bash


#set -x

[[ $bashnode_included == yes ]] && return 0
bashnode_included=yes

bashnode_self_path="${BASH_SOURCE%/*}"
if [[ ! -d "$bashnode_self_path" ]]; then bashnode_self_path="$PWD"; fi

function bashnode  {
  local command=bashnode::$1
  shift 1
  $command $@
}



function bashnode::import  {
  local exported=
  local OPTIND
  local builtingPath=$bashnode_self_path/nodes

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
    eval "$(   PATH=$builtingPath:$bashnode_path:$PATH && source  importhelper && source $1 || echo false )" && sourceResult=yes
    if [[ $sourceResult == yes ]]; then
      eval bashnode_imported_"$importedBasename"__$exportedTag=1
    fi
  shift
  done



}


function bashnode::export  {

  function rename_function()
  {
      local old_name=$1
      local new_name=$2
      eval "$(echo "${new_name}()"; declare -f ${old_name} | tail -n +2)"
      unset -f ${old_name}
  }

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
      if [[ ! -z $exportedPrefixFunction ]];then
      rename_function $i $exportedPrefixFunction$i
      fi
      declare -f $exportedPrefixFunction$i
      echo export -f $exportedPrefixFunction$i
    else


    eval content=\$$i

    if [[ x"$content" != x ]]; then
      echo "export $exportedPrefixVar$i=$content"
    fi

   fi
   done


}

export -f bashnode::export  bashnode::import bashnode
