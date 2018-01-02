-- site.moon
sitegen = require "sitegen"
lfs = require 'lfs'
magick = require "magick"
date = require "date"

sitegen.create =>
	rss= {}
	comicDir = 'www/img/comics/'
	comicTable = {}
	-- add all our comics to a table
	for file in lfs.dir(comicDir)
		-- file is the current file or directory name
		if file != '.' and file != '..' 
			-- print( "Found file: " .. file )
			table.insert(comicTable, file)
	-- sort comics by name
	table.sort(comicTable)
	lfs.mkdir('c')

	deploy_to "daniel@chilidog.faith", "www/sanic/"
	local prev,next,first,last,frameHeight,frame

	prev = '01'
	for i=1,#comicTable

		comicNum = string.sub(comicTable[i], 1, string.find(comicTable[i],'.')+1)
		-- make empty markdown folder
		io.open('c/'..comicNum..'.md','a')
		io.flush()
		-- print comicDir .. comicTable[i]
		img = magick.load_image(comicDir..comicTable[i])
		
		w = img\get_width!
		h = img\get_height!
		frameHeight = math.floor(640*h/w)
		frame = tostring(frameHeight)..'px'

		if i == 1
			prev = '1'
			first = 'style="visibility: hidden"'
		else 
			prev = tostring(i-1)
			first = ''
		if i == #comicTable 
			next = tostring(#comicTable)
			last = 'style="visibility: hidden"'
		else 
			next = tostring(i+1)
			last = ''


		add 'c/'..comicNum..'.md', {
			template: 'comic', 
			target:tostring(i), 
			comicName:comicTable[i],
			leftLink:prev, 
			rightLink:next,
			num:i,
			leftVis:first,
			rightVis:last,
			lastNum:tostring(#comicTable),
			fheight:frame
		}

		rss[i] = {}
		rss[i]["file"] = comicTable[i]
		mod = lfs.attributes(comicDir..'/'..comicTable[i])["modification"]
		rss[i]["date"] = date os.date("*t",mod)["year"], os.date("*t",mod)["month"], os.date("*t",mod)["day"]
		rss[i]["title"] = 'new chilidog'
		rss[i]["link"] = 'http://chilidog.faith/'.. comicNum
		rss[i]["description"] = 'dog #'.. comicNum

	add 'c/index.md', {
		template: 'comic', 
		target:'index', 
		comicName:comicTable[#comicTable],
		leftLink:prev, 
		rightLink:next,
		num:#comicTable,
		leftVis:first,
		rightVis:last,
		lastNum:tostring(#comicTable),
		fheight:frame
	}
	add 'c/about.md', template:'about', latest:tostring(#comicTable), target:'about'


	feed = io.open("www/index.xml","w")
	io.write("")
	io.close(feed)
	feed = io.open("www/index.xml","a")
	io.output(feed)

	io.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>","\n")
	io.write("<rss version=\"2.0\"><channel><title>sanic comics</title>","\n")
	io.write("<link></link>","\n")
	io.write("<description></description>","\n")

	for i=#comicTable,1,-1
		io.write("<item><title>chilidog #".. i .."</title>","\n")
		io.write("<link>http://chilidog.faith/" .. i .."</link>","\n")
		io.write("<pubDate>".. rss[i]["date"] .."</pubDate>","\n")
		io.write("<description><![CDATA[")
		io.write("<a href=\"http://chilidog.faith/" .. i .. "\"><img src=\"http://chilidog.faith/img/comics/"..rss[i]["file"].."\"></a>")
		io.write("]]></description></item>","\n")

	io.write("</channel></rss>","\n")


	io.close(feed)


