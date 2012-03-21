SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `mlstats` DEFAULT CHARACTER SET latin1 ;
USE `mlstats` ;

-- -----------------------------------------------------
-- Table `mlstats`.`mailing_lists`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`mailing_lists` (
  `mailing_list_url` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `mailing_list_name` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT 'NULL' ,
  `project_name` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT 'NULL' ,
  `last_analysis` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`mailing_list_url`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `mlstats`.`compressed_files`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`compressed_files` (
  `url` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `mailing_list_url` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `status` ENUM('new','visited','failed') NULL DEFAULT NULL ,
  `last_analysis` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`url`) ,
  INDEX `mailing_list_url` (`mailing_list_url` ASC) ,
  CONSTRAINT `compressed_files_ibfk_1`
    FOREIGN KEY (`mailing_list_url` )
    REFERENCES `mlstats`.`mailing_lists` (`mailing_list_url` ))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `mlstats`.`people`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`people` (
  `email_address` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `name` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `username` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `domain_name` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `top_level_domain` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  PRIMARY KEY (`email_address`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `mlstats`.`mailing_lists_people`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`mailing_lists_people` (
  `email_address` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `mailing_list_url` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  PRIMARY KEY (`email_address`, `mailing_list_url`) ,
  INDEX `mailing_list_url` (`mailing_list_url` ASC) ,
  CONSTRAINT `mailing_lists_people_ibfk_1`
    FOREIGN KEY (`mailing_list_url` )
    REFERENCES `mlstats`.`mailing_lists` (`mailing_list_url` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mailing_lists_people_ibfk_2`
    FOREIGN KEY (`email_address` )
    REFERENCES `mlstats`.`people` (`email_address` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `mlstats`.`messages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`messages` (
  `message_ID` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `mailing_list_url` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `mailing_list` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `first_date` DATETIME NULL DEFAULT NULL ,
  `first_date_tz` INT(11) NULL DEFAULT NULL ,
  `arrival_date` DATETIME NULL DEFAULT NULL ,
  `arrival_date_tz` INT(11) NULL DEFAULT NULL ,
  `subject` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `message_body` TEXT CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `is_response_of` VARCHAR(255) CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  `mail_path` TEXT CHARACTER SET 'utf8' NULL DEFAULT NULL ,
  PRIMARY KEY (`message_ID`) ,
  INDEX `response` (`is_response_of` ASC) ,
  INDEX `mailing_list_url` (`mailing_list_url` ASC) ,
  CONSTRAINT `messages_ibfk_1`
    FOREIGN KEY (`mailing_list_url` )
    REFERENCES `mlstats`.`mailing_lists` (`mailing_list_url` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `mlstats`.`messages_people`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mlstats`.`messages_people` (
  `type_of_recipient` ENUM('From','To','Cc') NOT NULL DEFAULT 'From' ,
  `message_id` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  `email_address` VARCHAR(255) CHARACTER SET 'utf8' NOT NULL ,
  PRIMARY KEY (`type_of_recipient`, `message_id`, `email_address`) ,
  INDEX `m_id` (`message_id` ASC) ,
  INDEX `email_address` (`email_address` ASC) ,
  CONSTRAINT `messages_people_ibfk_1`
    FOREIGN KEY (`message_id` )
    REFERENCES `mlstats`.`messages` (`message_ID` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `messages_people_ibfk_2`
    FOREIGN KEY (`email_address` )
    REFERENCES `mlstats`.`people` (`email_address` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
