local mysql = require 'resty.mysql'

local db,err = mysql:new()

if not db then
  ngx.say('failed to instantiate mysql:',err)
  return
end

--timeout 1s
db.set_timeout(1000)

local ok,err,errno,sqlstate = db:connect{
  host='192.168.156.122',
  port=3306,
  database=demo,
  user=root,
  password=root,
  max_packet_size=1024*1024
}

if not ok then
  ngx.say('failed to connect:',err,":",errno," ",sqlstate)
  return
end

ngx.say('connected to mysql')

local res,err,errno,sqlstate=db:query('drop table if exists test')
if not res then
  ngx.say('bad result:',err,":",errno,": ",sqlstate,".")
  return
end

res,err,errno,sqlstate=db:query("create table test" .. "(id int primary key auto_increment," .. "name varchar(20));")
if not res then
  ngx.say('bad result:',err,":",errno,": ",sqlstate,".")
  return
end

ngx.say('table test created')

res,err,errno,sqlstate = db:query('insert into test(name)' .. "values(\'thomas\'),(\'hello\'),(\'world\')")
if not res then
  ngx.say('bad result:',err,":",errno,": ",sqlstate,".")
  return
end

ngx.say(res.affected_rows,'rows inserted into table test ','(last insert id :',res.insert_id,')')

--sql injected
local req_id = [[1';drop table test;--]]
res,err,errno,sqlstate=db:query(string.format([[select * from test where id = '%s']],req_id))

if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

local cjson = require 'cjson'
ngx.say('result:',cjson.encode(res))

res,err,errno,sqlstate=db:query([[select * from test where id = 1]])
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

db:set_keepalive(10000,100)
