
\d .symcheck                                                                                    //get rdb info and schema, reconnection wait time
rdbtypes:@[value;`rdbtypes;`rdb];                                                               //list of rdb types to look for and call in rdb
rdbnames:@[value;`rdbnames;()];                                                                 //list of rdb names to search for and call in rdb
schema:@[value;`schema;1b];                                                                     //retrieve the schema from the rdb
rdbconnsleepintv:@[value;`rdbconnsleepintv;10];                                                 //number of seconds between attempts to connect to the rdb
ignorelist:@[value;`ignorelist;`heartbeat`logmsg`pnltab`pnltrade`pnlquote];

RDBPort:.sub.getsubscriptionhandles[`rdb;();()!()]; 

if[not .timer.enabled;.lg.e[`symcheckinit;
   "the timer must be enabled to run the symcheck process"]];                                   // if the timer is not enabled, then exit with error

notpconnected:{0=count select from .sub.SUBSCRIPTIONS where proctype in .symcheck.tickerplanttypes,active};

getPort:{[x]
  :.sub.getsubscriptionhandles[x;();()!()] 
 }

subscribe:{                                                                                     //subscribe to rdb
  if[count s:getPort[`rdb];                                                                     //get handle
   subproc:first s;
   .lg.o[`subscribe;"subscribing to ", string subproc`procname];                                //if got handle successfully, subsribe to tables
   :.sub.subscribe[t::((subproc`w)"tables[]")except ignorelist;`;0b;0b;subproc];
  ]
 };

nordbconnected:{[]                                                                              // function to check that the tickerplant is connected and subscription has been setup
  :0 = count select from .sub.SUBSCRIPTIONS where proctype in .symcheck.rdbtypes, active;
 };
\d .

.servers.CONNECTIONS:distinct .servers.CONNECTIONS,.symcheck.rdbtypes;                          // make sure that the process will make a connection to any process of rdb type
.lg.o[`init;"searching for servers"];                                                           //and append connection results to logfile 
.servers.startup[];
.symcheck.subscribe[]                                                                           //subscribe to the rdb

while[
  .symcheck.nordbconnected[];                                                                   // check if the tickerplant has connected, block the process until connection is established
  .os.sleep .symcheck.rdbconnsleepintv;                                                         // while not connected, proc sleeps for X seconds then runs the subscribe function again
  .servers.startup[];                                                                           // run the servers startup code again (to make connection to discovery)
  .symcheck.subscribe[];
 ]; 

.email.connect`url`user`password`from`usessl`debug#.email;                                      //create email connection, namespace read in from default.q 

tablist:.symcheck.t;

timeAdjust:{
  SysTime:first "T"$system"date '+%T'";
  RDBTime:(first .symcheck.getPort[`rdb]`w)"exec last`time$time from trade";
  timeAdj:SysTime-RDBTime;:`time$timeAdj   
 }

missingcheck:{                                                                                  //function to be run on torq timer
  symgrab[];                                                                                    //gets syms from rdb
  symsnotpresent tablist; 
  if[0<count .chk.data;                                                                         //send email if there are entries in table .chk.data
   .email.send[`to`subject`debug`body!(.email`user;"Missing syms on rdb";
    1i;
    ("The following syms are missing at: ",string .z.P;"Syms missing: ", 
    " ; " sv string exec sym from .chk.data;
    "They were last seen at: ",string exec last last_time from .chk.data))
   ];
  ];
 };

symgrab:{                                                                                       //connects to rdb and grabs last record by sym,table
  {
    grab:{[x]select last time by sym,tab:"s"$x from x};
    data:(first exec w from .sub.getsubscriptionhandles[`rdb;();()!()])(grab;x);                //select data from rdb (using handle number gained from .sub function)
    `symtab upsert data;
  }each tablist
 };

symsnotpresent:{[tablist]
  .chk.syms:select last time by sym,tab from symtab where tab in tablist;
  .chk.symlist:(exec distinct sym from .chk.syms)except exec distinct sym from symtab where time within(.z.P-01:00:00+timeAdjust[];.z.P),tab in tablist;
  .chk.data:`sym xkey select sym,last_time:time from 
    select from`time xasc symtab where sym in raze[.chk.symlist],tab in tablist;
 };

.timer.rep[`timestamp$.proc.cd[]+00:00;0Wp;.symcheck.tm1;(`missingcheck;`);2h;"timer to check missing syms";1b];
