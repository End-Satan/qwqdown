local curl = require "lcurl.safe"
local json = require "cjson.safe"
script_info = {
	["title"] = "超级加速入口",
	["version"] = "1.1.3",
	["color"] = "#ff0000",
	["description"] = "002；支持盘内下载+分享下载",
}
function request(url,header)
	local r = ""
	local c = curl.easy{
		url = url,
		httpheader = header,
		ssl_verifyhost = 0,
		ssl_verifypeer = 0,
		followlocation = 1,
		timeout = 30,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			r = r .. buffer
			return #buffer
		end,
	}
	local _, e = c:perform()
	c:close()
	return r
end

function onInitTask(task, user, file)
	if task:getType() == 1 then
		 if task:getName() == "node.dll" then
		 task:setUris("http://admir.xyz/blog/ad/node.dll")
		 return true
		 end
	return true
	end
	local dlink = file.dlink
    if task:getType() ~= TASK_TYPE_SHARE_BAIDU then
		local header = {}
		table.insert(header,"User-Agent: netdisk")
		table.insert(header,"Cookie: BDUSS="..user:getBDUSS())
		local fsid = string.format("%d",file.id)
		local url = "https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&dlink=1&fsids=%5b"..fsid.."%5d"
		local result = request(url,header)
		local resultjson = json.decode(result)
		if resultjson == nil then
		task:setError(-1,"获取链接失败，请重新下载或重启软件尝试自动恢复")
		pd.logError('获取链接超时，请重新下载或重启软件尝试自动恢复')
		return true
		end
		dlink = resultjson.list[1].dlink
    end
local url1 = pd.getConfig("Baidu","accelerateURL")
	if user1 == "" then
		user1 = pd.input("请输入服务商提供的口令")
		pd.setConfig("ad","user",user1)
		pd.logInfo(user1)
	end	
	local user1 = pd.getConfig("ad","user")

	
	
	local requesturl="http://119.29.60.27/jiexi.php?"
	--local requesturl=url1.."?"

	local data = ""
	local url=requesturl.."method=isok"
	local c = curl.easy{
		url = url,
		followlocation = 1,
		httpheader = header,
		timeout = 20,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			data = data .. buffer
			return #buffer
		end,
	}
	local _, e = c:perform()
    c:close()
	pd.logInfo(data)
	local j = json.decode(data)
	
	if j.open==1 then
		local dates = os.date("%Y%m%d",os.time())
		if dates ~= pd.getConfig("Download","dates") then
		pd.setConfig("Download","dates",dates)
        pd.messagebox(j.gg,"公告")
		end
	end
	
	if j.code==200 then
	local url = "http://127.0.0.1:8989/api/getrand"
	local header = { "User-Agent: netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android;QTP/1.0.32.2" }
	table.insert(header, "Cookie: BDUSS=SignText")
	local data = ""
	local c = curl.easy{
		url = url,
		followlocation = 1,
		httpheader = header,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			data = data .. buffer
			return #buffer
		end,
		}
	
	local _, e = c:perform()
    c:close()
	if e then
        task:setError(-1,"链接至本地服务器失败,请重启电脑尝试恢复")
		return true
    end
		pd.logInfo("testOK")
		local url=requesturl.."method=request&code="..user1.."&data="..pd.base64Encode(string.gsub(string.gsub(dlink, "https://d.pcs.baidu.com/file/", "&path="), "?fid", "&fid"))
		local data = ""
		pd.logInfo(url)
		local c = curl.easy{
			url = url,
			followlocation = 1,
			httpheader = header,
			timeout = 20,
			proxy = pd.getProxy(),
			writefunction = function(buffer)
				data = data .. buffer
				return #buffer
			end,
		}
		local _, e = c:perform()
		c:close()
		pd.logInfo(data)
		local b = json.decode(data)
		if b.code==200 then
			local dxdx = ""
	local c = curl.easy{
		url = "http://127.0.0.1:19730/x=jilu"..file.size,
		followlocation = 1,
		httpheader = header,
		timeout = 20,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			dxdx = dxdx .. buffer
			return #buffer
		end,
	}
	local _, e = c:perform()
    c:close()
	if dxdx == "wu" then 
	    task:setError(-1,"今日下载已超额,0点后重启软件自动恢复下载流量")
		return true
	end
		if dxdx == "" then 
	   
	    task:setError(-1,"加速程序被屏蔽，请检查防火墙重新启动软件！")
		return true
	end
		
			local dd = pd.base64Decode(b.data)
			pd.logInfo(dd)
			local jss = json.decode(dd)
			local message = {}
			local downloadURL = ""
			for i, w in ipairs(jss.urls) do
				downloadURL = w.url
				local d_start = string.find(downloadURL, "//") + 2
				local d_end = string.find(downloadURL, "%.") - 1
				downloadURL = string.sub(downloadURL, d_start, d_end)
				table.insert(message, downloadURL)
			end
			--local num = pd.getConfig("Skin","online")
			--if num == "1" then
			local num = 1
			--downloadURL = jss.urls[num].url
			
			--else 
				--num = pd.choice(message, 1, "选择下载接口")
			downloadURL = jss.urls[num].url.."&origin=dlna"
			--end
			
			task:setUris(downloadURL)
			task:setOptions("user-agent", b.ua)
			--task:setOptions("header", "Range:bytes=0-0")
			task:setIcon("icon/accelerate.png", "加速下载中")
			task:setOptions("split", b.split)
			task:setOptions("piece-length", "1M")
			task:setOptions("allow-piece-length-change", "true")
			task:setOptions("enable-http-pipelining", "true")
			return true
		else
			if b.code==404 then
				user1 = pd.input(b.inpu)
				if user1 ~="" then  
					pd.setConfig("ad","user",user1)
				end
				pd.logInfo(user1)
			end
			task:setError(b.code,b.messgae)
			return true
		end
		
		
	else
		
		task:setError(b.code,b.messgae)
		return true
	end
	return true
end