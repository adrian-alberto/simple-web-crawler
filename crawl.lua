http = require "socket.http"

function main(root, depth)
	if not root then
		print("Usage: lua5.1 crawl.lua http://website.com [depth]")
		return
	end

	depth = depth or 5
	local queue = {root}
	local visited = {}
	for i = 1, depth do
		local numEntries = #queue
		for j = 1, numEntries do
			crawl(table.remove(queue, 1), queue,visited)
		end
	end
end

function crawl(url, queue, visited)
	if visited[url] then
		--already visited
		return
	end
	visited[url] = true
	print(url)

	local contents, code, meta = http.request(url)
	if not contents then
		print("error: " .. url)
		return
	end	
	doSomething(contents)	
	if meta["content-type"] and string.match(meta["content-type"], "text") then
		--Crawl it for more links
	
		for x in string.gmatch(contents, [[href%s-=%s-"(.-)"]]) do
			
			if x == "/" or x == "" then
				--do nothing
			elseif not string.match(x, "^https?://.+") then
				x = string.match(url, "(https?://.-)/?$").. "/" .. string.match(x, "^/?(.+)")
				table.insert(queue, x)
			else
				table.insert(queue, x)
			end
		end


		--Also crawl for images	
		for x in string.gmatch(contents, [[src%s-=%s-"(.-)"]]) do
			
			if x == "/" or x == "" then
				--do nothing
			elseif not string.match(x, "^https?://.+") then
				x = string.match(url, "(https?://.-)/?$").. "/" .. string.match(x, "^/?(.+)")
				table.insert(queue, x)
			else
				table.insert(queue, x)
			end
		end

	elseif string.match(meta["content-type"] or "", "image") then
		print("Image found!", url)
		--[[
		-- You can write this file out if you want.
		local fname = string.match(url, "/?(%w+%.%a+)$")

		--alternative filename if you want the whole path, no duplicates
		local fname2 = string.gsub(url, "([/-:?]+)", "-")
		
		local outfile = io.open(fname, "w")
		outfile:write(content)
		outfile:close()

		--i didn't test any of this btw
		--]]
	end
	
end

function doSomething(content)
	print("> " .. string.sub(string.gsub(content, "\n", ""),1,40))
end

main(arg[1], arg[2])
