<?php
/*
    * create_author : Bilery Zoo(652645572@qq.com)
    * create_time   : 2018-11-20
    * program       : *_* web config *_*
*/


/* Website relevant */
$timezone="Asia/Shanghai";
header("Content-Type: text/html; charset=utf-8");

/* MySQL relevant */
$host="127.0.0.1";
$db_user="root";
$db_pass="1024";
$db_name="information_schema";
$conn = new mysqli($host, $db_user, $db_pass, $db_name);

/* Pagination relevant */
$curpage = empty($_GET['page']) ? 1 : $_GET['page'];    //current page
$url = "?page={page}";  //pagination address
$showrow = 10;


?>