# load env script
. ./setenv.sh

#kill all torq procs
echo 'Shutting down TorQ...'
q torq.q -load code/processes/kill.q -proctype kill -procname killtick -.servers.CONNECTIONS sortslave iexfeed feed rdb tickerplant chainedtp hdb gateway housekeeping monitor discovery wdb sort reporter compression metrics wap checker  </dev/null >$KDBLOG/torqkill.txt 2>&1 &
