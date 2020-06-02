#!/usr/bin/env bash

if [[ $# < 2 ]]
then
echo "Script takes 2+ arguments, a project sdk_config.h and one or more example sdk_config.h, \
and displays settings in each example sdk_config.h that differ or are missing from project sdk_config.h"
exit
fi

PROJECT_CONFIG=$1

compare() {
    local IFS=$'\n\r'
    for EXAMPLE_OPTION in $( grep "#define" "$1" )
    do
        OPTION_NAME=$(printf "${EXAMPLE_OPTION}" | cut -d' ' -f2)
        PROJECT_OPTION=$(egrep "#define ${OPTION_NAME}( |$)" "${PROJECT_CONFIG}")
        if [[ -z ${PROJECT_OPTION} ]]
        then
            printf "Unset: ${OPTION_NAME}\n"
        elif [[ "${EXAMPLE_OPTION}" != "${PROJECT_OPTION}" ]]
        then
            printf "Settings differ: ${OPTION_NAME}\n"
        fi
    done
}

for ARG in "${@:2}"
do
    printf "Comparing to ${ARG}\n"
    compare "${ARG}"
done
