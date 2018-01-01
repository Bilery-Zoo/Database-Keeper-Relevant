# !/bin/bash
# Author    : Bilery Zoo(652645572@qq.com)
# create_ts : 2017年 12月 28日 星期四 09:47:09 CST
# program   : MySQL Master Config File Upgrade
# crontab   : o(>﹏<)o


### header parameters ceil ###
cnf_file=/etc/my.cnf
bak_file=/etc/my.cnf.$(date +%Y%m%d%H%M%S)
### header parameters floor ###


### function block ceil ###
# set backups
function setbackups(){
    cp ${cnf_file} ${bak_file}
    if [ $? == 0 ]; then
        echo -e "\n\(^o^)/ ${cnf_file} backup to ${bak_file} \(^o^)/\n"
        return 0
    else
        echo -e "\no(>﹏<)o my.cnf backup failed o(>﹏<)o\n"
        exit 1
    fi
}

# set threads
function setthreads(){
    cpus=$(lscpu | sed -ne '4p' | awk '{ print $2 }') && declare -i threads=${cpus}-1
    if [ $? == 0 ]; then
        echo -e "\n\(^o^)/ threads sets ${threads} \(^o^)/\n"
        return ${threads}
    else
        echo -e "\no(>﹏<)o threads sets failed o(>﹏<)o\n"
        exit 1
    fi
}

# set setbuffers
function setbuffers(){
    buffers=$(cat ${cnf_file} | grep ^innodb_buffer_pool_size | tr -cd "[[:digit:]]\n")
    if [ $? == 0 ]; then
        echo -e "\n\(^o^)/ buffers sets ${buffers} \(^o^)/\n"
        return ${buffers}
    else
        echo -e "\no(>﹏<)o buffers sets failed o(>﹏<)o\n"
        exit 1
    fi
}
### function block floor ###


######## main block ceil ########
# get threads
setthreads
thread=$?
# get buffers
setbuffers
buffer=$?
# set backup
setbackups
# upgrade block
sed -i '1, $s/^wait_timeout.*$/wait_timeout = 28800/g' ${cnf_file}
sed -i '1, $s/interactive_timeout.*$/interactive_timeout = 28800/g' ${cnf_file}
sed -i '1, $s/^max_connections.*$/max_connections = 500/g' ${cnf_file}
sed -i '1, $s/^max_user_connections.*$/max_user_connections = 0/g' ${cnf_file}
sed -i '1, $s/^tmp_table_size.*$/tmp_table_size = 16M/g' ${cnf_file}
sed -i '1, $s/^max_heap_table_size.*$/max_heap_table_size = 16M/g' ${cnf_file}
sed -i '1, $s/^innodb_log_buffer_size.*$/innodb_log_buffer_size = 16M/g' ${cnf_file}
sed -i '1, $s/^innodb_purge_batch_size.*$/innodb_purge_batch_size = 300/g' ${cnf_file}
sed -i '1, $s/^max_connect_errors.*$/max_connect_errors = 100/g' ${cnf_file}
sed -i '1, $s/^transaction_isolation.*$/transaction_isolation = REPEATABLE-READ/g' ${cnf_file}
sed -i '1, $s/^default-storage-engine.*$/default_storage_engine = InnoDB/g' ${cnf_file}
sed -i '1, $s/^character-set-server.*$/character_set_server = utf8/g' ${cnf_file}
sed -i '1, $s/^slave-net-timeout.*$/slave_net_timeout = 10/g' ${cnf_file}
sed -i '1, $s/^open-files-limit.*$/open_files_limit = 28192/g' ${cnf_file}
sed -i '1, $s/^skip-external-locking/skip_external_locking/g' ${cnf_file}
sed -i '1, $s/^skip-name-resolve/skip_name_resolve/g' ${cnf_file}
sed -i '1, $s/^no-auto-rehash/disable-auto-rehash/g' ${cnf_file}
sed -i '1, $s/^innodb_file_format.*$//g' ${cnf_file}
sed -i "1, \$s/^innodb_buffer_pool_instances.*\$/innodb_buffer_pool_instances = ${buffer}/g" ${cnf_file}
sed -i '99i innodb_change_buffer_max_size = 35' ${cnf_file}
sed -i "94i innodb_page_cleaners = ${buffer}" ${cnf_file}
sed -i "1, \$s/^innodb_purge_threads.*\$/innodb_purge_threads = ${thread}/g" ${cnf_file}
######## main block floor ########
