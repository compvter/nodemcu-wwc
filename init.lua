print("Ready to start soft ap")
     
local str=wifi.ap.getmac();
local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
     
cfg={}
cfg.ssid="ESP8266_"..ssidTemp;
cfg.pwd="12345678"
wifi.ap.config(cfg)
     
cfg={}
cfg.ip="192.168.1.1";
cfg.netmask="255.255.255.0";
cfg.gateway="192.168.1.1";
wifi.ap.setip(cfg);
wifi.setmode(wifi.SOFTAP)
     
str=nil;
ssidTemp=nil;
     
print("Soft AP started")
print("Heep:(bytes)"..node.heap());
print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());

print(wifi.sta.getip())
led1 = 4
gpio.mode(led1, gpio.OUTPUT)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
			print(vars.."\r\n");        
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server </h1>";
        buf = buf.."<form action=\"?\" method=\"GET\">";
        buf = buf.."<input type=\"hidden\" name=\"op\" value=\"host\">";
        buf = buf.."ssid<input type=\"text\" name=\"ssid\">&nbsp;";
        buf = buf.."password<input type=\"text\" name=\"passwd\">";
        buf = buf.."<input type=\"submit\" value=\"set router\">";
        buf = buf.."</form><hr>";
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;";
        buf = buf.."<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        local _on,_off = "",""
        
		if(_GET.op=="host")then
			--local ssid = "Alice-63537521";
			local ssid = _GET.ssid;
			ssid=ssid:gsub("0000","-");
			local passwd = _GET.passwd;
			wifi.setmode(wifi.STATION);
			wifi.sta.config(ssid,passwd);
			print("SSID:"..ssid.."\r\n PASSWD:"..passwd.."\r\n");
			--print(wifi.sta.getip())
		end	
        
        if(_GET.pin == "ON1")then
            gpio.write(led1, gpio.LOW);
        elseif(_GET.pin == "OFF1")then
            gpio.write(led1, gpio.HIGH);
        end
        
        
        
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
