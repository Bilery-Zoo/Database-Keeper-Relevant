delimiter $$$


CREATE FUNCTION tab_rows_cnt(p_db VARCHAR(25), p_tb VARCHAR(25))
	RETURNS BIGINT(21)
	COMMENT 'Table `p_db.p_tb` records Count(MyISAM) or Estimate(InnoDB)'
	/* create_author: Bilery Zoo(652645572@qq.com)
	   create_time  : 2017-07-30 */
	DETERMINISTIC
	READS SQL DATA
	BEGIN

			
		IF (SELECT EXISTS(SELECT * FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA` = p_db)) = 0 THEN
			RETURN (SELECT -1);
		ELSEIF (SELECT EXISTS(SELECT * FROM `information_schema`.`TABLES` WHERE `TABLE_NAME` = p_tb)) = 0 THEN
			RETURN (SELECT -2);
		ELSE
			RETURN (SELECT `TABLE_ROWS` FROM `information_schema`.`TABLES` WHERE TABLE_NAME = p_tb AND TABLE_SCHEMA = p_db);
		END IF;


	END $$$


delimiter ;
