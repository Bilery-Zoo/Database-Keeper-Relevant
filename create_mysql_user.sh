#!/usr/bin/env bash
# date    : 2022-05-05
# creator : Bilery Zoo(bilery.zoo@gmail.com)
# script  : create project MySQL user
# execute : shell> bash create_mysql_user.sh --login-path=dba --project=abc --environment=dev --set-host-name-part='127%,255%' --create-mid-account


function usage() {
    echo -e "\nUsage: bash create_mysql_user.sh [OPTION]\n \
        Global options:
        \t[ -h | --help ]\t\t\tdisplay this help and exit\n \
        \t[ --login-path ]\t\tmysql client \`login-path'\n \
        \t[ --project ]\t\t\tproject short\n \
        \t[ --environment ]\t\tproject environment\n \
        \t[ --set-password-length ]\tpassword length\n \
        \t[ --set-host-name-part ]\thost name part\n \
        Detailed operations:
        \t[ --create-mid-account ]\tcreate middleware user list\n \
        \t[ --create-app-account ]\tcreate APP account list\n \
        Sub on-off(s):
        \t[ --dms ]\t\t\tcreate DMS user\n \
        \t[ --monitor ]\t\t\tcreate monitor user\n \
        "
}
if [ "$#" -eq 0 ]; then
    usage ; exit 2
fi


PASSWORD_LENGTH=16
HOST_NAME_PART=%
DMS=0
MONITOR=0

CREATE_MID_ACCOUNT=0
CREATE_APP_ACCOUNT=0

ARGS=$(getopt \
    --alternative \
    --name create_mysql_user.sh \
    --options h \
    --longoptions login-path:,project:,environment:,set-password-length::,set-host-name-part::,dms,monitor,create-mid-account,create-app-account,help \
    -- "$@" \
    )
eval set -- "${ARGS}"
while true ; do
    case "$1" in
    -h | --help)
        usage ; exit 0 ;;
    --login-path)
        LOGIN_PATH="$2" ; shift 2 ;;
    --project)
        PROJECT="$2" ; shift 2 ;;
    --environment)
        ENVIRONMENT="$2" ; shift 2 ;;
    --dms)
        DMS=1 ; shift ;;
    --monitor)
        MONITOR=1 ; shift ;;
    --create-mid-account)
        CREATE_MID_ACCOUNT=1 ; shift ;;
    --create-app-account)
        CREATE_APP_ACCOUNT=1 ; shift ;;
    --set-password-length)
        case "$2" in
        '')
            shift 2 ;;
        *)
            PASSWORD_LENGTH="$2" ; shift 2 ;;
        esac
        ;;
    --set-host-name-part)
        case "$2" in
        '')
            shift 2 ;;
        *)
            HOST_NAME_PART="$2" ; shift 2 ;;
        esac
        ;;
    --)
        shift ; break ;;
    esac
done
if [ ! ${LOGIN_PATH} ] || [ ! ${PROJECT} ] || [ ! ${ENVIRONMENT} ]; then
    usage ; exit 2
fi


source /etc/profile
function create_schema() {
    # $1: schema
    mysql --login-path="${LOGIN_PATH}" -N -e "CREATE DATABASE IF NOT EXISTS \`$1\`;"
}

function create_user() {
    # $1: user
    # $2: prefix title of schema(s) to echo
    local password=$(head /dev/urandom | tr -dc 0-9a-zA-Z | head -c "${PASSWORD_LENGTH}")
    mysql --login-path="${LOGIN_PATH}" -N -e "CREATE USER '$1'@'${HOST_NAME_PART}' IDENTIFIED BY '${password}';" && \
    echo -e "\tDB: $2\tUser: $1\tPassword: ${password}" && \
    return 0
}

function grant_privilege() {
    # $1: user
    # $2: privilege level
    # $3: permissible privileges
    mysql --login-path="${LOGIN_PATH}" -N -e "GRANT $3 ON $2 TO '$1'@'${HOST_NAME_PART}';" && \
    return 0
}


# create middleware service user
if [ ${CREATE_MID_ACCOUNT} -eq 1 ]; then
    echo 'Middleware account list:'
        # nacos
    create_schema nacos_config
    create_user "nacos_config_${ENVIRONMENT}" nacos_config && \
    grant_privilege "nacos_config_${ENVIRONMENT}" '`nacos_config`.*' 'ALL PRIVILEGES'
        # kafka
    create_schema kafka_monitor_midware_00
    create_user "kafka_monitor_midware_${ENVIRONMENT}" kafka_monitor_midware_00 && \
    grant_privilege "kafka_monitor_midware_${ENVIRONMENT}" '`kafka_monitor_midware_00`.*' 'ALL PRIVILEGES'
        # monitor
    if [ ${MONITOR} -eq 1 ]; then
        create_schema monitor_deployment
        create_user "monitor_deployment_${ENVIRONMENT}" monitor_deployment && \
        grant_privilege "monitor_deployment_${ENVIRONMENT}" '`monitor_deployment`.*' 'ALL PRIVILEGES'
    fi
        # dms
    if [ ${DMS} -eq 1 ]; then
        # dms source endpoint user
        create_user "dms_${ENVIRONMENT}_ro" 'DMS-source*' && \
        grant_privilege "dms_${ENVIRONMENT}_ro" '*.*' 'SELECT, REPLICATION SLAVE, REPLICATION CLIENT'
        # dms target endpoint user
        create_user "dms_${ENVIRONMENT}" 'DMS-target*' && \
        for db in $(mysql --login-path=${LOGIN_PATH} -N -e "SELECT REPLACE(s.\`SCHEMA_NAME\`, '_00', '') AS \`SCHEMA_NAME\` FROM \`information_schema\`.\`SCHEMATA\` AS s WHERE s.\`SCHEMA_NAME\` LIKE '${PROJECT}_%_00';")
        do
            grant_privilege "dms_${ENVIRONMENT}" "\`${db}\`.*" 'ALL PRIVILEGES'
        done
    fi
fi


# create single schema app user
if [ ${CREATE_APP_ACCOUNT} -eq 1 ]; then
    echo 'App account list:'
    for db in $(mysql --login-path=${LOGIN_PATH} -N -e "SELECT s.\`SCHEMA_NAME\` FROM \`information_schema\`.\`SCHEMATA\` AS s WHERE s.\`SCHEMA_NAME\` LIKE '${PROJECT}_%_00';")
    do
        create_user ${db/%00/${ENVIRONMENT}} ${db} && \
        grant_privilege ${db/%00/${ENVIRONMENT}} "\`${db}\`.*" 'ALL PRIVILEGES'
    done
fi
