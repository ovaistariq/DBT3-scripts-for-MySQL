#ifndef _DB_H
#define _DB_H

#ifdef SAPDB
#define SQL_EXEC "sql_execute"
#endif /* SAPDB */
#ifdef PGSQL
#define SQL_EXEC ""
#endif /* PGSQL */
#ifdef MYSQL
#define SQL_EXEC ""
#endif /* MYSQL */
#ifdef INGRES
#define SQL_EXEC ""
#endif /* INGRES */
#ifdef INGRES_VECTORWISE
#define SQL_EXEC ""
#endif /* X100 */
#ifdef SQLSERVER
#define SQL_EXEC ""
#endif /* SQLSERVER */

#ifdef SQLSERVER
#define SQL_TIME_P_INSERT "%s insert into time_statistics (tag, task_name, s_time) values ('%d','PERF.POWER.Q%d', getdate());\\p\\g\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=getdate() where tag='%d' and task_name='PERF.POWER.Q%d';\\p\\g\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', getdate());\\p\\g\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=getdate() where task_name='PERF%d.THRUPUT.QS%d.Q%d';\\p\\g\n"
#define SQL_ISOLATION "SET TRANSACTION ISOLATION LEVEL READ COMMITTED;\\p\\g"
#define START_TRAN "BEGIN TRANSACTION\n"
#define END_TRAN "COMMIT TRANSACTION\n"
#define SQL_COMMIT ""
#endif /* SQLSERVER */

#ifdef INGRES_VECTORWISE
#define SQL_TIME_P_INSERT "%s insert into time_statistics (tag, task_name, s_time) values ('%d','PERF.POWER.Q%d', current_timestamp);\\p\\g\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=current_timestamp where tag='%d' and task_name='PERF.POWER.Q%d';\\p\\g\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', current_timestamp);\\p\\g\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d';\\p\\g\n"
#define SQL_ISOLATION "SET TRANSACTION ISOLATION LEVEL READ COMMITTED;\\p\\g"
#define START_TRAN "/*START*/\n"
#define END_TRAN "COMMIT;\\p\\g;\n"
#define SQL_COMMIT ""
#endif /* X100 */

#ifdef INGRES
#define SQL_TIME_P_INSERT "%s insert into time_statistics (tag, task_name, s_time) values ('%d','PERF.POWER.Q%d', current_timestamp);\\p\\g\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=current_timestamp where tag='%d' and task_name='PERF.POWER.Q%d';\\p\\g\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', current_timestamp);\\p\\g\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d';\\p\\g\n"
#define SQL_ISOLATION "SET TRANSACTION ISOLATION LEVEL READ COMMITTED;\\p\\g"
#define START_TRAN "/*START*/\n"
#define END_TRAN "COMMIT;\\p\\g;\n"
#define SQL_COMMIT ""
#endif /* INGRES */

#ifdef SAPDB
#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.POWER.Q%d', timestamp)\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.POWER.Q%d'\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', timestamp)\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d'\n"
#define SQL_ISOLATION "sql_execute set isolation level 2"
#define START_TRAN "START\n"
#define END_TRAN "COMMIT;\n"
#define SQL_EXE_PLAN "select * from show\n"
#define SQL_COMMIT "sql_execute commit"
#endif /* SAPDB */

#ifdef PGSQL
#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.POWER.Q%d', current_timestamp);\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.POWER.Q%d';\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', current_timestamp);\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d';\n"
#define SQL_ISOLATION "set default_transaction_isolation='read committed';"
#define START_TRAN "START\n"
#define END_TRAN "COMMIT;\n"
#define SQL_COMMIT ""
#endif /* PGSQL */

#ifdef MYSQL
#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name) values ('PERF%d.POWER.Q%d');\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=now() where task_name='PERF%d.POWER.Q%d';\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name) values ('PERF%d.THRUPUT.QS%d.Q%d');\n"
#define SQL_TIME_T_UPDATE  "%s update time_statistics set e_time=now() where task_name='PERF%d.THRUPUT.QS%d.Q%d';\n"
#define SQL_ISOLATION "set session tx_isolation='READ-COMMITTED';"
#define START_TRAN "START TRANSACTION;\n"
#define END_TRAN "COMMIT;\n"
#define SQL_COMMIT ""
#endif /* MYSQL */

#endif
