# !/bin/bash
# Author    : Bilery Zoo(652645572@qq.com)
# create_ts : 2017年 12月 20日 星期三 15:45:15 CST
# program   : MySQL Benchmark
# crontab   : o(>﹏<)o


# 
# This Script based on Benchmark Tools:
# sysbench（https://github.com/akopytov/sysbench）
# tpcc-mysql(https://github.com/Percona-Lab/tpcc-mysql)
# 


### header parameters ceil ###
cnf_def=/etc/my.cnf
cnf_ori=/etc/my.cnf.ori
cnf_opt=/etc/my.cnf.opt
ser_host=127.0.0.1
ser_user=benchmarker
ser_pswd=1024
ser_dbas=benchmarker
sys_tabs=1000000
sys_time=7200
sys_thre=2
sys_seed=1024
tpc_ware=11
tpc_time=3600
tpc_thre=2
tpc_warm=600
tpc_inva=60
res_dire=/app/result/
### header parameters floor ###


### function block ceil ###
# switch file
function swit_cnf(){
	mv $1 $2 &> /dev/null
	if [ $? == 0 ]; then
		echo -e "$1 dies  o(>﹏<)o\n$2 come  \(^o^)/"
		return 0
	else
		echo -e "\n    o(>﹏<)o  switch my.cnf failed  o(>﹏<)o"
		exit 1
	fi
}

# init mysqld
function rest_ser(){
	service mysqld restart &> /dev/null
	if [ $? == 0 ]; then
		echo -e "\n\(^o^)/ MySQL restart \(^o^)/\n"
		return 0
	else
		echo -e "\no(>﹏<)o MySQL die o(>﹏<)o\n"
		exit 1
	fi
}

# create database
function crea_dbs(){
	# $1: MySQL host
	# $2: MySQL user
	# $3: MySQL password
	# $4: MySQL database
	mysqladmin -h$1 -u$2 -p$3 create $4 &> /dev/null
	if [ $? == 0 ]; then
		echo -e "\n\(^o^)/ ${4} created \(^o^)/\n"
		return 0
	else
		echo -e "\no(>﹏<)o ${4} uncreated o(>﹏<)o\n"
		exit 1
	fi
}

# drop database
function drop_dbs(){
	# $1: MySQL host
	# $2: MySQL user
	# $3: MySQL password
	# $4: MySQL database
	mysqladmin -h$1 -u$2 -p$3 -f drop $4 &> /dev/null
	if [ $? == 0 ]; then
		echo -e "\n\(^o^)/ ${4} dropped \(^o^)/\n"
		return 0
	else
		echo -e "\no(>﹏<)o ${4} undropped o(>﹏<)o\n"
		exit 1
	fi
}

# sysbench benchmark
function sysb_bmk(){
	# $1: MySQL host
	# $2: MySQL user
	# $3: MySQL password
	# $4: MySQL database
	# $5: Benchmark table size
	# $6: Benchmark execute time
	# $7: Benchmark execute threads
	# $8: Benchmark random seed
	# $9: Benchmark result writer
	sysbench --db-driver=mysql --mysql-host=$1 --mysql-user=$2 --mysql-password=$3 \
	--mysql-db=$4 --table_size=$5 oltp_read_write prepare &&\
	sysbench --db-driver=mysql --mysql-host=$1 --mysql-user=$2 --mysql-password=$3 \
	--mysql-db=$4 --table_size=$5 --time=$6 --threads=$7 --rand-seed=$8 \
	oltp_read_write run &> $9 &&\
	sysbench --db-driver=mysql --mysql-host=$1 --mysql-db=$4 \
	--mysql-user=$2 --mysql-password=$3 --table_size=$5 oltp_read_write cleanup
	return 0
}

# tpcc benchmark
function tpcc_bmk(){
	# $1: MySQL host
	# $2: MySQL user
	# $3: MySQL password
	# $4: MySQL database
	# $5: Benchmark warehouse size
	# $6: Benchmark execute time
	# $7: Benchmark execute threads
	# $8: Benchmark warm-up time
	# $9: Benchmark result writer
	# $10: Benchmark report interval
	dire_scri=$(locate tpcc_load)
	dire_tpcc=${dire_scri%tpcc_load}
	cd ${dire_tpcc}
	mysql -h$1 -u$2 -p$3 $4 < create_table.sql &&\
	mysql -h$1 -u$2 -p$3 $4 < add_fkey_idx.sql &&\
	./tpcc_load  -h$1 -P3306 -d$4 -u$2 -p$3 -w$5 &&\
	./tpcc_start -h$1 -P3306 -d$4 -u$2 -p$3 -w$5 \
	-l$6 -c$7 -r$8 -i${10} &> $9
	return 0
}
### function block floor ###


######## benchmark block ceil ########

# init
updatedb
if [ -d ${res_dire} ]; then
    > /dev/null
else
    mkdir -p ${res_dire}
fi

### ori benchmark ceil ###
#
# sysbench
#
rest_ser
crea_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
sysb_bmk ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas} ${sys_tabs} ${sys_time} ${sys_thre} ${sys_seed} "${res_dire}slave_oltp_ori"
if [ $? == 0 ]; then
    echo -e "\n\(^o^)/ sysbench oltp fly high \(^o^)/\n"
else
    echo -e "\no(>﹏<)o sysbench oltp fall over o(>﹏<)o\n"
    exit 1
fi
drop_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
#
# tpcc
#
rest_ser
crea_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
tpcc_bmk ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas} ${tpc_ware} ${tpc_time} ${tpc_thre} ${tpc_warm} "${res_dire}slave_tpcc_ori" ${tpc_inva}
if [ $? == 0 ]; then
    echo -e "\n\(^o^)/ tpcc oltp fly high \(^o^)/\n"
else
    echo -e "\no(>﹏<)o tpcc oltp fall over o(>﹏<)o\n"
    exit 1
fi
drop_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
#
### ori benchmark floor ###

### switch config ceil ###
swit_cnf ${cnf_def} ${cnf_ori}
swit_cnf ${cnf_opt} ${cnf_def}
### switch config floor ###

### opt benchmark ceil ###
#
# sysbench
#
rest_ser
crea_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
sysb_bmk ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas} ${sys_tabs} ${sys_time} ${sys_thre} ${sys_seed} "${res_dire}slave_oltp_opt"
if [ $? == 0 ]; then
    echo -e "\n\(^o^)/ sysbench oltp fly high \(^o^)/\n"
else
    echo -e "\no(>﹏<)o sysbench oltp fall over o(>﹏<)o\n"
    exit 1
fi
drop_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
#
# tpcc
#
rest_ser
crea_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
tpcc_bmk ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas} ${tpc_ware} ${tpc_time} ${tpc_thre} ${tpc_warm} "${res_dire}slave_tpcc_opt" ${tpc_inva}
if [ $? == 0 ]; then
    echo -e "\n\(^o^)/ tpcc oltp fly high \(^o^)/\n"
else
    echo -e "\no(>﹏<)o tpcc oltp fall over o(>﹏<)o\n"
    exit 1
fi
drop_dbs ${ser_host} ${ser_user} ${ser_pswd} ${ser_dbas}
#
### opt benchmark floor ###

# init
swit_cnf ${cnf_def} ${cnf_opt}
swit_cnf ${cnf_ori} ${cnf_def}
rest_ser

######## benchmark block floor ########
