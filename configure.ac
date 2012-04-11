AC_PREREQ(2.59)

dnl Process this file with autoconf to produce a configure script.
AC_INIT(dbt3, 1.10, osdldbt-general@lists.sourceforge.net)
AM_INIT_AUTOMAKE

dnl Function that checks for cygwin host
AC_CANONICAL_HOST 
OS_HOST=linux
case $host_os in
  *cygwin* ) OS_HOST=cygwin;;
   *[lL]inux* ) OS_HOST=linux;;
esac
AC_SUBST(OS_HOST)

if test "$OS_HOST" = "cygwin"; then
  AC_MSG_NOTICE([===============================================])
  AC_MSG_NOTICE([== We are on CYGWIN                          ==])  
  AC_MSG_NOTICE([===============================================]) 
fi

dnl Checks for programs.
AC_PATH_PROGS([GAWK], [gawk], ,
             [$PATH])
if test -z "$GAWK"; then
  AC_MSG_ERROR([*** error: gawk not found])
fi

AC_PATH_PROGS([GCC], [gcc], ,
             [$PATH])
if test -z "$GCC"; then
  AC_MSG_ERROR([*** error: gcc not found])
fi

dnl Checks for header files.
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS(strings.h sys/time.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_SIZE_T
AC_HEADER_TIME
AC_STRUCT_TM

dnl Large file support?
AC_SYS_LARGEFILE

CFLAGS="-Wall $CFLAGS"
AC_CHECK_LIB(m, main)

dnl AC_ARG_ENABLE(tpch, [  --enable-tpch (default)],
dnl ENABLE_TPCH="yes" ENABLE_TPCR="no", ENABLE_TPCH="yes" ENABLE_TPCR="no")
dnl AC_ARG_ENABLE(tpcr, [  --enable-tpcr], ENABLE_TPCR="yes" ENABLE_TPCH="no")
dnl if test "$ENABLE_TPCH" = "yes"; then
dnl   AC_DEFINE(TPCH, 1)
dnl fi
dnl if test "$ENABLE_TPCR" = "yes"; then
dnl   AC_DEFINE(TPCR, 1)
dnl fi


AC_PATH_PROGS([SAR], [sar bsdsar], ,
             [$PATH:/usr/local/bin:/usr/bin])
if test -z "$SAR"; then
  AC_MSG_WARN([*** sar or bsdsar not found some scripts may not be usable])
  SAR=
fi

AC_PATH_PROGS([IOSTAT], [iostat], ,
             [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
if test -z "$IOSTAT"; then
  AC_MSG_WARN([*** iostat not found some scripts may not be usable])
  IOSTAT=
fi

AC_PATH_PROGS([VMSTAT], [vmstat], ,
             [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
if test -z "$VMSTAT"; then
  AC_MSG_WARN([*** vmstat not found some scripts may not be usable])
  VMSTAT=
fi

AC_PATH_PROGS([BC], [bc], ,
             [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
if test -z "$BC"; then
  AC_MSG_ERROR([*** could not find bc program])
  BC=
fi

dnl AC_PATH_PROGS([LOCKFILECREATE], [lockfile-create], , 
dnl              [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
dnl if test -z "$LOCKFILECREATE"; then 
dnl   AC_MSG_ERROR([Couldn't find lockfile-create program!])
dnl fi 

dnl AC_PATH_PROGS([LOCKFILEREMOVE], [lockfile-remove], , 
dnl              [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
dnl if test -z "$LOCKFILEREMOVE"; then 
dnl   AC_MSG_ERROR([Couldn't find lockfile-remove program!])
dnl fi 

dnl AC_PATH_PROGS([LOCKFILETOUCH], [lockfile-touch], , 
dnl              [$PATH:/usr/local/bin:/usr/bin:/usr/X11R6/bin])
dnl if test -z "$LOCKFILETOUCH"; then 
dnl   AC_MSG_ERROR([Couldn't find lockfile-touch program!])
dnl fi 

dnl> Configuration options for different databases, MySQL is default.
AC_ARG_WITH(postgresql,
    [ AC_HELP_STRING([ --with-postgresql=DIR], [])],
    [ PGSQL_PATH=$withval DATABASE_TO_USE="PGSQL" DATABASE_DEF="PGSQL=1"],
    [])
AC_ARG_WITH(mysql,
    [ AC_HELP_STRING([ --with-mysql=DIR], [Default.])],
    [ MYSQL_PATH=$withval DATABASE_TO_USE="MYSQL" DATABASE_DEF="MYSQL=1"],
    [])
AC_ARG_WITH(sapdb,
    [  --with-sapdb],
    [DATABASE_TO_USE="SAPDB" DATABASE_DEF="SABDB=1"], [])
AC_ARG_WITH(ingres,
    [  --with-ingres],
    [DATABASE_TO_USE="INGRES" DATABASE_DEF="INGRES=1"], [])
AC_ARG_WITH(ingres-vectorwise,
    [  --with-ingres-vectorwise],
    [DATABASE_TO_USE="INGRES_VECTORWISE" DATABASE_DEF="INGRES_VECTORWISE=1"], [])

AC_DEFINE(WORKLOAD,"TPCH")
AC_DEFINE(TPCH)
TOPDIR=`pwd`
AC_SUBST(TOPDIR)
AC_SUBST(DATABASE_TO_USE)

if test "$DATABASE_TO_USE" = "MYSQL"; then
  dnl check if the user has the mysql binaries we need
  if test "$MYSQL_PATH" = "yes"; then
    MYSQL_TEST_PATH=$PATH
    MYSQL_BASEDIR_CNF=
    MYSQL_BASEDIR=.
  else
    MYSQL_TEST_PATH=$MYSQL_PATH/bin:$MYSQL_PATH/sbin:$MYSQL_PATH/libexec:$MYSQL_PATH/scripts
    MYSQL_BASEDIR_CNF="basedir=$MYSQL_PATH"
    MYSQL_BASEDIR="$MYSQL_PATH"
  fi

  AC_SUBST(MYSQL_BASEDIR)
  AC_SUBST(MYSQL_BASEDIR_CNF)

dnl  REQUIRE_PROG(MYSQL_CONFIG, mysql_config, [$MYSQL_TEST_PATH])

  dnl check for mysql_config
  AC_PATH_PROGS(MYSQL_CONFIG, mysql_config, ,
    [$MYSQL_TEST_PATH]
  )
  if test -z "$MYSQL_CONFIG" ; then
    AC_MSG_ERROR([*** mysql_config is required])
  fi

dnl REQUIRE_PROG(MYSQL_CLIENT, mysql, [$MYSQL_TEST_PATH])

  dnl check for mysql
  dnl AC_PATH_PROGS(MYSQL_CLIENT, mysql, ,
  dnl   [$MYSQL_TEST_PATH]
  dnl )
  dnl if test -z "$MYSQL_CLIENT" ; then
  dnl  AC_MSG_ERROR([*** mysql is required])
  dnl fi

dnl REQUIRE_PROG(MYSQL_ADMIN, mysqladmin, [$MYSQL_TEST_PATH])

  dnl check for mysqladmin
  AC_PATH_PROGS(MYSQL_ADMIN, mysqladmin, ,
    [$MYSQL_TEST_PATH]
  )
  if test -z "$MYSQL_ADMIN" ; then
    AC_MSG_ERROR([*** mysqladmin is required])
  fi

dnl REQUIRE_PROG(MYSQLIMPORT, mysqlimport, [$MYSQL_TEST_PATH])

  dnl check for mysqlimport
  AC_PATH_PROGS(MYSQLIMPORT, mysqlimport, ,
    [$MYSQL_TEST_PATH]
  )
  if test -z "$MYSQLIMPORT" ; then
    AC_MSG_ERROR([*** mysqlimport is required])
  fi

  MY_CNF=$TOPDIR/scripts/mysql/my.cnf
  MYSQL_CLIENT="${MYSQL_CLIENT} --defaults-file=${MY_CNF}"
  MYSQL_ADMIN="${MYSQL_ADMIN} --defaults-file=${MY_CNF}"
  MYSQLIMPORT="${MYSQLIMPORT} --defaults-file=${MY_CNF}"
  
  AC_SUBST(MYSQL_ADMIN)

  AC_ARG_WITH(mysql-datadir,
    [ AC_HELP_STRING([ --with-mysql-datadir=DIR],[])],
    [ MYSQL_DATADIR=$withval],
    [ MYSQL_DATADIR=${TOPDIR}/scripts/mysql/mydata ])
  AC_SUBST(MYSQL_DATADIR)
  AC_ARG_WITH(mysql-engine,
    [ AC_HELP_STRING([ --with-mysql-engine=ENGINE],[Default MyISAM])],
    [ MYSQL_ENGINE=$withval],
    [ MYSQL_ENGINE=MyISAM])
  myengine=`echo $MYSQL_ENGINE | tr 'A-Z' 'a-z'`
  case $myengine in
    myisam)
      MYSQL_ENGINE_TUNING="--skip-innodb --key-buffer-size=500M"
      ;;
    innodb)
      MYSQL_ENGINE_TUNING="--key-buffer-size=16M --innodb_log_file_size=100M --innodb_buffer_pool_size=500M --innodb-doublewrite=false --innodb_flush_method=O_DIRECT "
      ;;
    nitro)
      MYSQL_ENGINE_TUNING="--skip-innodb --nitro_attempt_query_rewrite=0 --nitro_batch_enabled=1 --nitro_bulk_load_enabled=1 --sql-mode='TRADITIONAL' "
      ;;
    *)
      MYSQL_ENGINE_TUNING=""
      ;;
  esac
  AC_SUBST(MYSQL_ENGINE)  
  AC_SUBST(MYSQL_ENGINE_TUNING)

  MYSQL_PID=$MYSQL_DATADIR/mysql.pid
  MYSQL_SOCK=$MYSQL_DATADIR/mysql.sock
  AC_SUBST(MYSQL_PID)
  AC_SUBST(MYSQL_SOCK)

  AC_DEFINE(MYSQL, 1)

elif test "$DATABASE_TO_USE" = "PGSQL"; then
  dnl check if the user has specified path for pgsql
  if test "$pgsql_path" = "yes"; then
    AC_PATH_PROGS(PG_CONFIG, pg_config, no)
  else
    AC_PATH_PROGS(PG_CONFIG, pg_config, no, "$PGSQL_PATH/bin")
  fi
  AC_SUBST(PG_CONFIG)
  BINDIR=`$PG_CONFIG --bindir`

  AC_DEFINE(PGSQL, 1)

  dnl check for createdb
  AC_PATH_PROGS(CREATEDB, createdb, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$CREATEDB" ; then
    AC_MSG_ERROR([*** createdb is required])
  fi

  dnl check for dropdb
  AC_PATH_PROGS(DROPDB, dropdb, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$DROPDB" ; then
    AC_MSG_ERROR([*** dropdb is required])
  fi

  dnl check for psql
  AC_PATH_PROGS(PSQL, psql, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$PSQL" ; then
    AC_MSG_ERROR([*** psql is required])
  fi

  dnl check for vacuumdb
  AC_PATH_PROGS(VACUUMDB, vacuumdb, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$VACUUMDB" ; then
    AC_MSG_ERROR([*** vacuumdb is required])
  fi

  dnl check for vacuumdb
  AC_PATH_PROGS(PG_CTL, pg_ctl, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$PG_CTL" ; then
    AC_MSG_ERROR([*** pg_ctl is required])
  fi

  dnl check for initdb
  AC_PATH_PROGS(INITDB, initdb, ,
    [$BINDIR:$PATH:/bin:/usr/bin:/usr/local/bin]
  )
  if test -z "$INITDB" ; then
    AC_MSG_ERROR([*** initdb is required])
  fi

  AC_CONFIG_FILES([scripts/pgsql/clear-time-statistics.sh],
      [chmod +x scripts/pgsql/clear-time-statistics.sh])
  AC_CONFIG_FILES([scripts/pgsql/get_query_plan.sh],
      [chmod +x scripts/pgsql/get_query_plan.sh])
  AC_CONFIG_FILES([scripts/pgsql/get_version.sh],
      [chmod +x scripts/pgsql/get_version.sh])
  AC_CONFIG_FILES([scripts/pgsql/run_power_query.sh],
      [chmod +x scripts/pgsql/run_power_query.sh])
  AC_CONFIG_FILES([scripts/pgsql/run_rf1.sh],
      [chmod +x scripts/pgsql/run_rf1.sh])
  AC_CONFIG_FILES([scripts/pgsql/run_rf2.sh],
      [chmod +x scripts/pgsql/run_rf2.sh])
  AC_CONFIG_FILES([scripts/pgsql/run_throughput_stream.sh],
      [chmod +x scripts/pgsql/run_throughput_stream.sh])
  AC_CONFIG_FILES([scripts/pgsql/create_db.sh],
      [chmod +x scripts/pgsql/create_db.sh])
  AC_CONFIG_FILES([scripts/pgsql/create_indexes.sh],
      [chmod +x scripts/pgsql/create_indexes.sh])
  AC_CONFIG_FILES([scripts/pgsql/create_tables.sh],
      [chmod +x scripts/pgsql/create_tables.sh])
  AC_CONFIG_FILES([scripts/pgsql/db_stats.sh],
      [chmod +x scripts/pgsql/db_stats.sh])
  AC_CONFIG_FILES([scripts/pgsql/drop_db.sh],
      [chmod +x scripts/pgsql/drop_db.sh])
  AC_CONFIG_FILES([scripts/pgsql/drop_tables.sh],
      [chmod +x scripts/pgsql/drop_tables.sh])
  AC_CONFIG_FILES([scripts/pgsql/grant.sh],
      [chmod +x scripts/pgsql/grant.sh])
  AC_CONFIG_FILES([scripts/pgsql/pgsql_profile],
      [chmod +x scripts/pgsql/pgsql_profile])
  AC_CONFIG_FILES([scripts/pgsql/q_time.sh],
      [chmod +x scripts/pgsql/q_time.sh])
  AC_CONFIG_FILES([scripts/pgsql/start_db.sh],
      [chmod +x scripts/pgsql/start_db.sh])
  AC_CONFIG_FILES([scripts/pgsql/stop_db.sh],
      [chmod +x scripts/pgsql/stop_db.sh])
  AC_CONFIG_FILES([scripts/pgsql/update_statistics.sh],
      [chmod +x scripts/pgsql/update_statistics.sh])
  AC_CONFIG_FILES([scripts/pgsql/load_test.sh],
      [chmod +x scripts/pgsql/load_test.sh])
  AC_CONFIG_FILES([scripts/pgsql/power_test.sh],
      [chmod +x scripts/pgsql/power_test.sh])
  AC_CONFIG_FILES([scripts/pgsql/throughput_test.sh],
      [chmod +x scripts/pgsql/throughput_test.sh])
  AC_CONFIG_FILES([scripts/pgsql/throughput_stream_wrapper.sh],
      [chmod +x scripts/pgsql/throughput_stream_wrapper.sh])
  AC_CONFIG_FILES([scripts/pgsql/record_end.sh],
      [chmod +x scripts/pgsql/record_end.sh])
  AC_CONFIG_FILES([scripts/pgsql/record_start.sh],
      [chmod +x scripts/pgsql/record_start.sh])
elif test "$DATABASE_TO_USE" = "SAPDB"; then
  AC_DEFINE(SAPDB, 1)

  AC_CONFIG_FILES([data_collect/sapdb/dbt3_stats.sh],
      [chmod +x data_collect/sapdb/dbt3_stats.sh])
  AC_CONFIG_FILES([data_collect/sapdb/power_test_stats.sh],
      [chmod +x data_collect/sapdb/power_test_stats.sh])
  AC_CONFIG_FILES([data_collect/sapdb/single_query_stats.sh],
      [chmod +x data_collect/sapdb/single_query_stats.sh])
  AC_CONFIG_FILES([data_collect/sapdb/throughput_query_stats.sh],
      [chmod +x data_collect/sapdb/throughput_query_stats.sh])
  AC_CONFIG_FILES([data_collect/sapdb/throughput_test_stats.sh],
      [chmod +x data_collect/sapdb/throughput_test_stats.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/explain_single_query.sh],
      [chmod +x dbdriver/scripts/sapdb/explain_single_query.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/explain_power_query.sh],
      [chmod +x dbdriver/scripts/sapdb/explain_power_query.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_dbt3.sh],
      [chmod +x dbdriver/scripts/sapdb/run_dbt3.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_load_test.sh],
      [chmod +x dbdriver/scripts/sapdb/run_load_test.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_single_query.sh],
      [chmod +x dbdriver/scripts/sapdb/run_single_query.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_perf_test.sh],
      [chmod +x dbdriver/scripts/sapdb/run_perf_test.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_power_query.sh],
      [chmod +x dbdriver/scripts/sapdb/run_power_query.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_power_test.sh],
      [chmod +x dbdriver/scripts/sapdb/run_power_test.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_refresh_stream.sh],
      [chmod +x dbdriver/scripts/sapdb/run_refresh_stream.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_rf1.sh],
      [chmod +x dbdriver/scripts/sapdb/run_rf1.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_rf2.sh],
      [chmod +x dbdriver/scripts/sapdb/run_rf2.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_throughput_query.sh],
      [chmod +x dbdriver/scripts/sapdb/run_throughput_query.sh])
  AC_CONFIG_FILES([dbdriver/scripts/sapdb/run_throughput_test.sh],
      [chmod +x dbdriver/scripts/sapdb/run_throughput_test.sh])
  AC_CONFIG_FILES([scripts/sapdb/backup_db.sh],
      [chmod +x scripts/sapdb/backup_db.sh])
  AC_CONFIG_FILES([scripts/sapdb/build_db.sh],
      [chmod +x scripts/sapdb/build_db.sh])
  AC_CONFIG_FILES([scripts/sapdb/create_db.sh],
      [chmod +x scripts/sapdb/create_db.sh])
  AC_CONFIG_FILES([scripts/sapdb/create_indexes.sh],
      [chmod +x scripts/sapdb/create_indexes.sh])
  AC_CONFIG_FILES([scripts/sapdb/create_tables.sh],
      [chmod +x scripts/sapdb/create_tables.sh])
  AC_CONFIG_FILES([scripts/sapdb/drop_tables.sh],
      [chmod +x scripts/sapdb/drop_tables.sh])
  AC_CONFIG_FILES([scripts/sapdb/load_db.sh],
      [chmod +x scripts/sapdb/load_db.sh])
  AC_CONFIG_FILES([scripts/sapdb/restore_db.sh],
      [chmod +x scripts/sapdb/restore_db.sh])
  AC_CONFIG_FILES([scripts/sapdb/sapdb_profile],
      [chmod +x scripts/sapdb/sapdb_profile])
  AC_CONFIG_FILES([scripts/sapdb/update_statistics.sh],
      [chmod +x scripts/sapdb/update_statistics.sh])

dnl
dnl Ingres
dnl

elif test "$DATABASE_TO_USE" = "INGRES"; then
  AC_DEFINE(INGRES, 1)

  dnl check for ingstatus
  AC_PATH_PROGS(INGSTATUS, ingstatus, ,
    [$PATH]
  )
  if test -z "$INGSTATUS" ; then
    AC_MSG_ERROR([*** ingstatus is required])
  fi

  dnl check for ingstart
  AC_PATH_PROGS(INGSTART, ingstart, ,
    [$PATH]
  )
  if test -z "$INGSTART" ; then
    AC_MSG_ERROR([*** ingstart is required])
  fi

  dnl check for ingstop
  AC_PATH_PROGS(INGSTOP, ingstop, ,
    [$PATH]
  )
  if test -z "$INGSTOP" ; then
    AC_MSG_ERROR([*** ingstop is required])
  fi

  dnl check for createdb
  AC_PATH_PROGS(CREATEDB, createdb, ,
    [$PATH]
  )
  if test -z "$CREATEDB" ; then
    AC_MSG_ERROR([*** createdb is required])
  fi

  dnl check for destroydb
  AC_PATH_PROGS(DESTROYDB, destroydb, ,
    [$PATH]
  )
  if test -z "$DESTROYDB" ; then
    AC_MSG_ERROR([*** destroydb is required])
  fi

  dnl check for sql
  AC_PATH_PROGS(SQL, sql, ,
    [$PATH]
  )
  if test -z "$SQL" ; then
    AC_MSG_ERROR([*** sql is required])
  fi

  dnl check for statdump
  AC_PATH_PROGS(STATDUMP, statdump, ,
    [$PATH]
  )
  if test -z "$STATDUMP" ; then
    AC_MSG_ERROR([*** statdump is required])
  fi

  dnl check for optimizedb
  AC_PATH_PROGS(OPTIMIZEDB, optimizedb, ,
    [$PATH]
  )
  if test -z "$OPTIMIZEDB" ; then
    AC_MSG_ERROR([*** optimizedb is required])
  fi
  
  AC_CONFIG_FILES([scripts/ingres/sort_param])
  AC_CONFIG_FILES([scripts/ingres/secondary_list])
  AC_CONFIG_FILES([scripts/ingres/location_names.template],
      [cp scripts/ingres/location_names.template scripts/ingres/location_names.`uname -n`])   
  AC_CONFIG_FILES([scripts/ingres/sort_flat_files.sh],
      [chmod +x scripts/ingres/sort_flat_files.sh])   
  AC_CONFIG_FILES([scripts/ingres/modify_tables.sh],
      [chmod +x scripts/ingres/modify_tables.sh])     
  AC_CONFIG_FILES([scripts/ingres/clear-time-statistics.sh],
      [chmod +x scripts/ingres/clear-time-statistics.sh])
  AC_CONFIG_FILES([scripts/ingres/create_db.sh],
      [chmod +x scripts/ingres/create_db.sh])
  AC_CONFIG_FILES([scripts/ingres/create_indexes.sh],
      [chmod +x scripts/ingres/create_indexes.sh])
  AC_CONFIG_FILES([scripts/ingres/create_fk.sh],
      [chmod +x scripts/ingres/create_fk.sh])     
  AC_CONFIG_FILES([scripts/ingres/create_si.sh],
      [chmod +x scripts/ingres/create_si.sh])
  AC_CONFIG_FILES([scripts/ingres/create_tables.sh],
      [chmod +x scripts/ingres/create_tables.sh])
  AC_CONFIG_FILES([scripts/ingres/drop_db.sh],
      [chmod +x scripts/ingres/drop_db.sh])
  AC_CONFIG_FILES([scripts/ingres/drop_tables.sh],
      [chmod +x scripts/ingres/drop_tables.sh])
  AC_CONFIG_FILES([scripts/ingres/grant.sh],
      [chmod +x scripts/ingres/grant.sh])
  AC_CONFIG_FILES([scripts/ingres/ingres_profile],
      [chmod +x scripts/ingres/ingres_profile])
  AC_CONFIG_FILES([scripts/ingres/start_db.sh],
      [chmod +x scripts/ingres/start_db.sh])
  AC_CONFIG_FILES([scripts/ingres/stop_db.sh],
      [chmod +x scripts/ingres/stop_db.sh])
  AC_CONFIG_FILES([scripts/ingres/update_statistics.sh],
      [chmod +x scripts/ingres/update_statistics.sh])
  AC_CONFIG_FILES([scripts/ingres/load_test.sh],
      [chmod +x scripts/ingres/load_test.sh])
  AC_CONFIG_FILES([scripts/ingres/power_test.sh],
      [chmod +x scripts/ingres/power_test.sh])
  AC_CONFIG_FILES([scripts/ingres/record_end.sh],
      [chmod +x scripts/ingres/record_end.sh])
  AC_CONFIG_FILES([scripts/ingres/record_start.sh],
      [chmod +x scripts/ingres/record_start.sh])  
  AC_CONFIG_FILES([scripts/ingres/get_query_plan.sh],
      [chmod +x scripts/ingres/get_query_plan.sh])
  AC_CONFIG_FILES([scripts/ingres/run_rf1.sh],
      [chmod +x scripts/ingres/run_rf1.sh])
  AC_CONFIG_FILES([scripts/ingres/run_rf2.sh],
      [chmod +x scripts/ingres/run_rf2.sh])   
  AC_CONFIG_FILES([scripts/ingres/run_power_query.sh],
      [chmod +x scripts/ingres/run_power_query.sh])   
  AC_CONFIG_FILES([scripts/ingres/throughput_test.sh],
      [chmod +x scripts/ingres/throughput_test.sh])
  AC_CONFIG_FILES([scripts/ingres/run_throughput_stream.sh],
      [chmod +x scripts/ingres/run_throughput_stream.sh])
dnl  AC_CONFIG_FILES([scripts/ingres/q_time.sh],
dnl      [chmod +x scripts/ingres/q_time.sh])
dnl  AC_CONFIG_FILES([scripts/ingres/get_version.sh],
dnl      [chmod +x scripts/ingres/get_version.sh])
dnl  AC_CONFIG_FILES([scripts/ingres/throughput_stream_wrapper.sh],
dnl      [chmod +x scripts/ingres/throughput_stream_wrapper.sh])

dnl
dnl Ingres VectorWise
dnl

elif test "$DATABASE_TO_USE" = "INGRES_VECTORWISE"; then
  AC_DEFINE(INGRES_VECTORWISE, 1)

  dnl check for $II_SYSTEM
  if test -z "$II_SYSTEM"; then
    AC_MSG_ERROR([*** II_SYSTEM is not set])
  fi
  
  if test "$OS_HOST" != "cygwin"; then
	dnl check for ingstatus
	AC_PATH_PROGS(INGSTATUS, ingstatus, ,
		[$PATH]
	)
	if test -z "$INGSTATUS" ; then
		AC_MSG_ERROR([*** ingstatus is required in PATH])
	fi
  fi
  
  dnl check for ingstart
  AC_PATH_PROGS(INGSTART, ingstart, ,
    [$PATH]
  )
  if test -z "$INGSTART" ; then
    AC_MSG_ERROR([*** ingstart is required in PATH])
  fi

  dnl check for ingstop
  AC_PATH_PROGS(INGSTOP, ingstop, ,
    [$PATH]
  )
  if test -z "$INGSTOP" ; then
    AC_MSG_ERROR([*** ingstop is required in PATH])
  fi

  dnl check for createdb
  AC_PATH_PROGS(CREATEDB, createdb, ,
    [$PATH]
  )
  if test -z "$CREATEDB" ; then
    AC_MSG_ERROR([*** createdb is required in PATH])
  fi

  dnl check for destroydb
  AC_PATH_PROGS(DESTROYDB, destroydb, ,
    [$PATH]
  )
  if test -z "$DESTROYDB" ; then
    AC_MSG_ERROR([*** destroydb is required in PATH])
  fi

  dnl check for sql
  AC_PATH_PROGS(SQL, sql, ,
    [$PATH]
  )
  if test -z "$SQL" ; then
    AC_MSG_ERROR([*** sql is required in PATH])
  fi

  dnl check for statdump
  AC_PATH_PROGS(STATDUMP, statdump, ,
    [$PATH]
  )
  if test -z "$STATDUMP" ; then
    AC_MSG_ERROR([*** statdump is required in PATH])
  fi

  dnl check for optimizedb
  AC_PATH_PROGS(OPTIMIZEDB, optimizedb, ,
    [$PATH]
  )
  if test -z "$OPTIMIZEDB" ; then
    AC_MSG_ERROR([*** optimizedb is required in PATH])
  fi
  
  AC_CONFIG_COMMANDS([location_names], [cp scripts/ingres_vectorwise/location_names.template scripts/ingres_vectorwise/location_names.`uname -n`])

  case $OS_HOST in
	cygwin )
	         AC_CONFIG_COMMANDS([make_cygwin_acid], [cp -f scripts/ingres_vectorwise/acid/Makefile.cyg scripts/ingres_vectorwise/acid/Makefile])
	         AC_CONFIG_COMMANDS([make_cygwin_cons], [cp -f scripts/ingres_vectorwise/acid/cons/Makefile.cyg scripts/ingres_vectorwise/acid/cons/Makefile])
			 AC_CONFIG_COMMANDS([make_cygwin_dur], [cp -f scripts/ingres_vectorwise/acid/dur/Makefile.cyg scripts/ingres_vectorwise/acid/dur/Makefile]);;
	linux ) 
	         AC_CONFIG_COMMANDS([make_linux_acid], [cp -f scripts/ingres_vectorwise/acid/Makefile.lnx scripts/ingres_vectorwise/acid/Makefile])
	         AC_CONFIG_COMMANDS([make_linux_cons], [cp -f scripts/ingres_vectorwise/acid/cons/Makefile.lnx scripts/ingres_vectorwise/acid/cons/Makefile])
			 AC_CONFIG_COMMANDS([make_linux_dur], [cp -f scripts/ingres_vectorwise/acid/dur/Makefile.lnx scripts/ingres_vectorwise/acid/dur/Makefile]);;			 
  esac
  
  AC_CONFIG_FILES([scripts/ingres_vectorwise/.topdir])
  AC_CONFIG_FILES([scripts/ingres_vectorwise/acid/.topdir])
  AC_CONFIG_FILES([scripts/ingres_vectorwise/acid/atom/.topdir])
  AC_CONFIG_FILES([scripts/ingres_vectorwise/acid/cons/.topdir])
  AC_CONFIG_FILES([scripts/ingres_vectorwise/acid/dur/.topdir])
  AC_CONFIG_FILES([scripts/ingres_vectorwise/acid/iso/.topdir])

  chmod +x  scripts/ingres_vectorwise/create_db.sh  
  chmod +x  scripts/ingres_vectorwise/grant.sh
  chmod +x  scripts/ingres_vectorwise/start_db.sh
  chmod +x  scripts/ingres_vectorwise/update_statistics.sh
  chmod +x  scripts/ingres_vectorwise/create_tables.sh
  chmod +x  scripts/ingres_vectorwise/load_test.sh
  chmod +x  scripts/ingres_vectorwise/stop_db.sh  
  chmod +x  scripts/ingres_vectorwise/drop_db.sh
  chmod +x  scripts/ingres_vectorwise/power_test.sh
  chmod +x  scripts/ingres_vectorwise/sort_flat_files.sh  

fi

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([scripts/dbt3_profile], [chmod +x scripts/dbt3_profile])
AC_CONFIG_FILES([scripts/get_composite.sh], [chmod +x scripts/get_composite.sh])
AC_CONFIG_FILES([scripts/get_config.sh], [chmod +x scripts/get_config.sh])
AC_CONFIG_FILES([scripts/gen_data.sh], [chmod +x scripts/gen_data.sh])
AC_CONFIG_FILES([scripts/gen_html.sh], [chmod +x scripts/gen_html.sh])
AC_CONFIG_FILES([scripts/run_workload.sh], [chmod +x scripts/run_workload.sh])
AC_CONFIG_FILES([scripts/init_seed.sh], [chmod +x scripts/init_seed.sh])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([src/dbgen/Makefile])
AC_CONFIG_FILES([tpch_tools/Makefile])

AC_OUTPUT
