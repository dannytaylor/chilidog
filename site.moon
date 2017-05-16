-- site.moon
sitegen = require "sitegen"
lfs = require 'lfs'




sitegen.create =>

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
	-- feed "feed.moon", "feed.xml"
	local prev,next,first,last

	prev = '01'
	for i=1,#comicTable

		comicNum = string.sub(comicTable[i], 1, string.find(comicTable[i],'.')+1)
		-- make empty markdown folder
		io.open('c/'..comicNum..'.md','w')
		io.flush()

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
			lastNum:tostring(#comicTable)
		}
	add 'c/index.md', template:'index', latest:tostring(#comicTable), target:'index'
