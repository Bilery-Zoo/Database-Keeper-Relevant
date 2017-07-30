delimiter $$$


CREATE EVENT Event_table_Partition
	ON SCHEDULE EVERY 1 DAY STARTS '%Y%m%d %T' /* man modify */
	COMMENT 'Table `event_table` physical partition by Day'
	/* create_author: Bilery Zoo(652645572@qq.com)
	   create_time  : 2016-09-15 */
	DO
		BEGIN


			DECLARE _tab CHAR(39);
			DECLARE CONTINUE HANDLER FOR NOT FOUND, SQLEXCEPTION SET @_err := 1;
			
			SET _tab := (SELECT CONCAT('`event_database`.`event_table_', DATE_FORMAT(CURDATE(), '%Y%m%d') - 1, '`'));
			SET @cre := CONCAT('CREATE TABLE ', _tab, ' LIKE `event_database`.`event_table`;');
			SET @ins := CONCAT('INSERT INTO ', _tab, ' SELECT * FROM `event_database`.`event_table` WHERE DATE(`create_ts`) = CURDATE() - INTERVAL 1 DAY;');
			
			START TRANSACTION;
				
				-- create same table named by suffix of yesterday
				PREPARE CRE FROM @cre;
				EXECUTE CRE;
				
				-- insert yesterday records into yesterday table
				PREPARE INS FROM @ins;
				EXECUTE INS;
				
				-- delete yesterday table backuped old records
				DELETE FROM `event_database`.`event_table` WHERE DATE(`create_ts`) = CURDATE() - INTERVAL 1 DAY;

			IF @_err = 1 THEN ROLLBACK;
			ELSE COMMIT;
			END IF;


		END $$$


delimiter ;
