DROP TABLE IF EXISTS `besieged_prisoners`;
CREATE TABLE `besieged_prisoners` (
  `prisoner` tinyint(2) unsigned NOT NULL,
  `stronghold` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `cell` tinyint(2) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`prisoner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `besieged_prisoners` VALUES (1,0,0);
INSERT INTO `besieged_prisoners` VALUES (2,0,0);
INSERT INTO `besieged_prisoners` VALUES (3,0,0);
INSERT INTO `besieged_prisoners` VALUES (4,0,0);
INSERT INTO `besieged_prisoners` VALUES (5,0,0);
INSERT INTO `besieged_prisoners` VALUES (6,0,0);
INSERT INTO `besieged_prisoners` VALUES (7,0,0);
INSERT INTO `besieged_prisoners` VALUES (8,0,0);
INSERT INTO `besieged_prisoners` VALUES (9,0,0);
INSERT INTO `besieged_prisoners` VALUES (10,0,0);
INSERT INTO `besieged_prisoners` VALUES (11,0,0);
INSERT INTO `besieged_prisoners` VALUES (12,0,0);
INSERT INTO `besieged_prisoners` VALUES (13,0,0);
INSERT INTO `besieged_prisoners` VALUES (14,0,0);
INSERT INTO `besieged_prisoners` VALUES (15,0,0);
