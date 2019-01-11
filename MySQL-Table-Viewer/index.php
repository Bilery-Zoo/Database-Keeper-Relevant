<?php
/*
    * create_author : Bilery Zoo(652645572@qq.com)
    * create_time   : 2018-11-20
    * program       : *_* web index *_*
*/


include_once("config.php");
require_once("page.php");
require_once("query.php");


?>


<!DOCTYPE html>
<html>
    <head>

        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Welcome Tableviewer...</title>
        <style type="text/css">
            p{margin:0}
            #page{
                height:40px;
                padding:20px 0px;
            }
            #page a{
                display:block;
                float:left;
                margin-right:10px;
                padding:2px 12px;
                height:24px;
                border:1px #cccccc solid;
                background:#fff;
                text-decoration:none;
                color:#808080;
                font-size:12px;
                line-height:24px;
            }
            #page a:hover{
                color:#077ee3;
                border:1px #077ee3 solid;
            }
            #page a.cur{
                border:none;
                background:#077ee3;
                color:#fff;
            }
            #page p{
                float:left;
                padding:2px 12px;
                font-size:12px;
                height:24px;
                line-height:24px;
                color:#bbb;
                border:1px #ccc solid;
                background:#fcfcfc;
                margin-right:8px;

            }
            #page p.pageRemark{
                border-style:none;
                background:none;
                margin-right:0px;
                padding:4px 0px;
                color:#666;
            }
            #page p.pageRemark b{
                color:black;
            }
            #page p.pageEllipsis{
                border-style:none;
                background:none;
                padding:4px 0px;
                color:#808080;
            }
        </style>
    </head>

    <body>
        <div>
            <ul>
                <li><font size='8' color="black"><b>Tableviewer Service</b></font></li>
            </ul>
        </div>

        <div>
			<!--h2 class="title"><font size='3' color="black">ようこそ...</font></h2-->

			<div>
				<ul>
					<style type="text/css">
						table.gridtable {
							font-family: verdana,arial,sans-serif;
							font-size: 11px;
							color: #333333;
							border: 1px solid black;
							border-width: 1px;
							border-color: #666666;
							border-collapse: collapse;
							table-layout: fixed;
							width: 100%;
							word-break: break-all;
							word-wrap: break-word;
							white-space: normal;
							overflow: auto;
							margin: auto;
						}
						table.gridtable th {
							border-width: 1px;
							padding: 8px;
							border-style: solid;
							border-color: #666666;
							background-color: #dedede;
							table-layout: fixed;
						}
						table.gridtable td {
							border-width: 1px;
							padding: 8px;
							border-style: solid;
							border-color: #666666;
							background-color: #ffffff;
							table-layout: fixed;
							white-space: pre-line;
						}

						.search{
							width: 100%;
							height: 52px;
							line-height: 52px;
							font-size: 16px;
							font-weight: bold;
							padding-left: 20px;
						}
						.search>form>input{
							width: 270px;
							height: 30px;
							border-radius: 5px;
							outline: none;
						}
						.search>form>button{
							width: 60px;
							height: 33px;
							border-radius: 5px;
							line-height: 30px;
							position: relative;
							top: 2px;
						}
					</style>

					<table id="CaseResult" class="gridtable" align="center">
						<div class="search" style="width:100%; align:center; text-align:center">
							<form method="POST">
								table: <input type="text" name="table">
								table_schema: <input type="text" name="table_schema">
								table_comment: <input type="text" name="table_comment">
								table_column: <input type="text" name="table_column">
								<button>Search</button>
							</form>
						</div>

						<tr>
							<th align="center" width="80"> table </th>
							<th align="center" width="80"> table_schema </th>
							<th align="left" width="240"> table_comment </th>
							<th align="left" width="240"> table_column </th>
						</tr>

						<?php

							if ($_SERVER['REQUEST_METHOD'] == 'POST'){
									$table = $_POST["table"];
									$table_schema = $_POST["table_schema"];
									$table_comment = $_POST["table_comment"];
									$table_column = $_POST["table_column"];
								if ($table != ''){
									$sql .= " AND t.`TABLE_NAME` REGEXP '" . $table . "'";
								}
								if ($table_schema != ''){
									$sql .= " AND t.`TABLE_SCHEMA` REGEXP '" . $table_schema . "'";
								}
								if ($table_comment != ''){
								    $sql .= " AND t.`TABLE_COMMENT` REGEXP '" . $table_comment . "'";
								}
								if ($table_column != ''){
								    $sql .= " AND c.`COLUMN_NAME` REGEXP '" .$table_column . "'";
								}
							}

							$sql .= " GROUP BY t.`TABLE_NAME`, t.`TABLE_SCHEMA`, t.`TABLE_COMMENT` ORDER BY t.`TABLE_SCHEMA`";
							$total = mysqli_num_rows(mysqli_query($conn, $sql));	//Get rows counts
							$sql .= " LIMIT " . ($curpage - 1) * $showrow . ",$showrow;";
							$query = mysqli_query($conn, $sql);
							$data=mysqli_fetch_all($query);

							foreach ($data as $row) {
						?>
						<tr>
							<td align="center"><?php echo $row[0] ?></td>
							<td align="center"><?php echo $row[1] ?></td>
							<td align="left"><?php echo $row[2] ?></td>
							<td align="left"><?php echo $row[3] ?></td>
						</tr>
					<?php
					}?>
					</table>
				</ul>
			</div>

			<div>
				<?php
				if (!empty($_GET['page']) && $total != 0 && $curpage > ceil($total / $showrow)){
					$curpage = ceil($total / $showrow);
				}	//binding last pagination
				if ($total > $showrow) {
					$page = new page($total, $showrow, $curpage, $url, 2);
					echo $page->myde_write();
				}	//starting first pagination
				?>
			</div>
		</div>

        <div>
            Powered by Bilery Zoo <a href="https://github.com/Bilery-Zoo" target="_blank">https://github.com/Bilery-Zoo</a>
        </div>

    </body>
</html>