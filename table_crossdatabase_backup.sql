delimiter $$$


CREATE DEFINER = 'root'@'%' PROCEDURE tab_crossdb_bak(IN p_srcdb VARCHAR(25), IN p_baktb VARCHAR(25), IN p_tardb VARCHAR(25))
	COMMENT 'Table `p_srcdb.p_srctb` cross database backup to `p_srcdb.p_tardb`'
	/* create_author: Bilery Zoo(652645572@qq.com)
	   create_time  : 2017-07-30 */
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	BEGIN
	
	
		DECLARE CONTINUE HANDLER FOR NOT FOUND, SQLEXCEPTION SET @_err := 1;
		
		SET @dro := CONCAT('DROP TABLE IF EXISTS `', p_tardb, '`.`', p_baktb, '`;');
		SET @cre := CONCAT('CREATE TABLE `', p_tardb, '`.`', p_baktb, '` LIKE `', p_srcdb, '`.`', p_baktb, '`;');
		SET @ins := CONCAT('INSERT INTO `', p_tardb, '`.`', p_baktb, '` SELECT * FROM `', p_srcdb, '`.`', p_baktb, '`;');
		
        -- do drop
        PREPARE DRO FROM @dro;
        EXECUTE DRO;

        -- do create
        PREPARE CRE FROM @cre;
        EXECUTE CRE;

		START TRANSACTION;

			-- do insert
			PREPARE INS FROM @ins;
			EXECUTE INS;
			
		IF @_err = 1 THEN ROLLBACK;
		ELSE COMMIT;
		END IF;
	
	
	END $$$
	

delimiter ;