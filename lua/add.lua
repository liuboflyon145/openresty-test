
-- 使用access阶段完成准入阶段处理
local black_ips = {["127.0.0.1"]=true}
local ip = ngx.var.remote_addr
if false == black_ips[ip] then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

local a = tonumber(ngx.var.arg_a) or 0
local b = tonumber(ngx.var.arg_b) or 0
ngx.say("sum: ", a + b )
