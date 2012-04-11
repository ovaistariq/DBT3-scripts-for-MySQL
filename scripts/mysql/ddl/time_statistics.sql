CREATE TABLE `time_statistics` (
  `task_name` varchar(40) DEFAULT NULL,
  `s_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `e_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `int_time` int(11) DEFAULT NULL,
  `tag` int(11) DEFAULT NULL,
  `run_id` int(11) DEFAULT NULL,
  `run_optimize` varchar(255) DEFAULT NULL,
  `stream` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1
