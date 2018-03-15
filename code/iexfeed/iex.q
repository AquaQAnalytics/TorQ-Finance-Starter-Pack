\d .iex

main_url:@[value;`main_url;"https://api.iextrading.com"];
convert_epoch:@[value;`convert_epoch;{{"p"$1970.01.01D+1000000j*x}}];
reqtype:@[value;`reqtype;`both];
syms:@[value;`syms;`CAT`DOG];
callback:@[value;`callback;".u.upd"];
callbackhandle:@[value;`callbackhandle;0i];
callbackconnection:@[value;`callbackconnection;`];
quote_suffix:@[value;`quote_suffix;{{[sym] "/1.0/stock/",sym,"/quote"}}];
trade_suffix:@[value;`trade_suffix;{{[sym]"/1.0/tops/last?symbols=",sym}}];
upd:@[value;`upd;{{[t;x].iex.callbackhandle(.iex.callback;t; value flip x)}}];
timerperiod:@[value;`timerperiod;0D00:00:02.000];
lvcq:@[value;`lvcq;1!flip `sym`bid`ask`bsize`asize`mode`ex`srctime!()];
lvct:@[value;`lvct;1!flip`sym`price`size`stop`cond`ex`srctime!()];
qcols:@[value;`qcols;`bid`ask`bsize`asize`mode`ex];
nullq:@[value;`nullq;qcols!(0f;0f;0;0;" ";" ")];
tcols:@[value;`tcols;`price`size`stop`cond`ex];
nullt:@[value;`nullt;tcols!(0f;0;"B"$();" ";" ")];

init:{[x]
  if[`main_url in key x;.iex.main_url:x`main_url];
  if[`quote_suffix in key x;.iex.quote_suffix:x`quote_suffix];
  if[`trade_suffix in key x;.iex.trade_suffix:x`trade_suffix];
  if[`syms in key x;.iex.syms:upper x`syms];
  if[`reqtype in key x;.iex.reqtype:x`reqtype];
  if[`callbackconnection in key x;.iex.callbackhandle:neg hopen .iex.callbackconnection:x`callbackconnection];
  if[`callbackhandle in key x;.iex.callbackhandle:x`callbackhandle];
  if[`callback in key x;.iex.callback:$[.iex.callbackhandle=0;string @[value;x`callback;{[x;y]x set{[t;x]x}}[x`callback]];x`callback]];
  if[`upd in key x;.iex.upd:x`upd];
  .iex.timer:$[not .iex.reqtype in key .iex.timer_dict;'`timer;.iex.timer_dict .iex.reqtype];
 };

get_data:{[main_url;suffix].Q.hg`$main_url,suffix};

get_last_trade:{
  .t.t:tab:{[syms]
    / This function can run for multiple securities.
    syms:$[1<count syms;"," sv string[upper syms];string[upper syms]];
    / Construct the GET request
    suffix:.iex.trade_suffix[syms];
    / Parse json response and put into table. Trade data from https://iextrading.com/developer/
    data:.j.k .iex.get_data[.iex.main_url;suffix];
    :createtable[`.trd;data];
   }[.iex.syms]; 
  tab:check_dup[;;`.iex.lvct;tcols;nullt]/[0#tab;tab]; 
  if[count tab;.iex.upd[`trade_iex;tab]];
 };

get_quote:{
  .p.p:tab:raze{[sym]
    sym:string[upper sym];
    suffix:.iex.quote_suffix[sym];
    / Parse json response and put into table
    data: enlist .j.k .iex.get_data[.iex.main_url;suffix];
    :createtable[`.qte;data];
   }'[.iex.syms,()];
  / Check for duplicate data
  tab:check_dup[;;`.iex.lvcq;qcols;nullq]/[0#tab;tab];
  if[count tab;.iex.upd[`quote_iex;tab]];
 };

timer_both:{.iex.get_last_trade[];.iex.get_quote[]};
timer_dict:`trade`quote`both!(.iex.get_last_trade;.iex.get_quote;timer_both);

timer:{
  @[$[not .iex.reqtype in key .iex.timer_dict;
  {'`$"timer request type not valid: ",string .iex.reqtype};
  .iex.timer_dict[.iex.reqtype]];
  [];
  {.lg.e[`iextimer;"failed to run iex timer function: ",x]}]
 };

check_dup:{[x;y;lvc;c;n]
  / Checks for duplicates and nulls
  i:any(n;c#value[lvc]y`sym)~\:c#y;
  if[not i;lvc upsert y;x,:y];
  :x; 
 };

createtable:{[x;data] update .iex.convert_epoch[srctime] from x[`ncol]xcol flip x[`typ]$x[`ocol]#flip data};

\d . 
