macroScript FindTexture
	category:"Matanga"
	tooltip:"Find a texture"
(	

	--hon
	--wilson art
	--national
	--Inscape
	
	
	--SERVER SEARCH VARIABLES
	--SERVER SEARCH VARIABLES
	
	--The Root Paths	
	local thePathsNames= #("Steelcase","Teknion","Haworth","Design Tex","All Steel","Maharam","Herman Miller","Knoll")
	local thePaths =#(
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Steelcase Tileable Maps\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Teknion\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\HAWORTH\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Design Tex\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Allsteel\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Maharam\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Herman Miller\\",
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Knoll\\"
	)	
	--Dotnet Object Directory
	local dotDirectory = dotNetClass "System.IO.Directory"		
	--Dotnet Object Path
	local dotPath = dotNetClass "System.IO.Path"												
	--Indexed fodler files
	local allFiles=#()	
	--Only the names of all the folders
	local allNames=#()	
	--Search Variables
	local theMatchesIndex=#()
	local theMatchesNames=#()
	
	
	--DotNET Control References
	local myLV = undefined
	global RLTFindTexture = undefined
	local myLVItems =#()
	local bmpDisplayed
	local bmpRectangle	
	
	
	local googleBaseURL="https://www.google.com.ar/search?q=ssd&safe=off&biw=1920&bih=983&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjd6K2o9ebOAhUDi5AKHekTDoIQ_AUIBigB#safe=off&tbm=isch&q="
	local steelcaseBaseURL="http://finishlibrary.steelcase.com/index.php/catalogsearch/result/?q="
	local haworthBaseURL="http://surfaces.haworth.com/surface-search#SearchText="	
	local designTexBaseURL ="http://www.designtex.com/vescom/catalogsearch/result/?q="
	local allSteelBaseURL ="http://cms.allsteeloffice.com/pages/search.aspx?keywords="
	local maharamBaseURL="http://maharam.com/search?query="
	local hermanMillerBaseURL ="http://www.hermanmiller.com/design-resources/materials/search-materials/cmf-search.html#rpp=60,s="
	local knollBaseURL="http://www.knoll.com/design-plan/resources/surface-finishes?searchtext="
	local inscapeBaseURL="http://inscapesolutions.com/resources/finishes/?type=&grade=&prodcat=&prodline=&app=&keywords="
	
	
	fn DisplayImage thePath =
	(
		bmpDisplayed = dotNetObject "System.Drawing.Bitmap" thePath
		bmpRectangle = dotNetObject "System.Drawing.Rectangle" 0 0 (bmpDisplayed.width) (bmpDisplayed.height)
		
		rollout uiDotNetPictureBox "Image" 
		(
			dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" pos:[0,0] width:(bmpDisplayed.width) height:(bmpDisplayed.height)

			on uiPictureBox Paint senderArg paintEventArgs do
			(
			Graphics = paintEventArgs.Graphics
			Graphics.DrawImage bmpDisplayed bmpRectangle
			)
		)

		try(destroyDialog uiDotNetPictureBox) catch()
		createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu) width:(bmpDisplayed.width) height:(bmpDisplayed.height)
	
		
	)
	
	--Function that gets all the folders names
	fn GetAllFiles thePath =
	(
		free allFiles
		free allNames
		--Referencio todas las carpetas dentro de la carpeta JOBS
		allFiles=dotDirectory.GetFiles(thePath)	
		--Extract all the folder names from the list
		allNames=for o in allFiles collect (dotPath.GetFileName o)	
		print allfiles.count
	)
		
	fn GetMatches val =
	(
		--Define the search term
		theText="*"+val+"*"
		--Reset the matches list
		theMatchesIndex=#()
		
		--Search in the folders list for all matches
		for o=1 to allNames.count by 1 do
		(					
			if (matchPattern allNames[o] pattern:theText ==true) do  append theMatchesIndex o				
		)			
		--Reset the list of matching names
		theMatchesNames=#()				
		--If the amount is less than 40 then show the matches in the listbox			
		if(theMatchesIndex.count <=40) do
		(									
			for o in theMatchesIndex do	append theMatchesNames allNames[o]					
		)
	)
	
	fn AddColumns theLv columnsAr=
	(
		w=(theLv.width/columnsAr.count)-1
		for x in columnsAr do
		(
			theLv.columns.add x w
		)
	)	
	
	fn UpdateListViewItems =
	(
		myLV.items.clear()
		myLVItems=#()
		for o=1 to theMatchesNames.count by 1 do
		(
			theItem = dotnetObject "ListViewItem"
			theItem.text = theMatchesNames[o]
			theItem.subitems.add (allFiles[theMatchesIndex[o]])
			theItem.ToolTipText=(allFiles[theMatchesIndex[o]])
			--theItem.backcolor= (dotnetclass "System.Drawing.Color").salmon
				
			append myLVItems theItem		
		)
		myLV.items.addRange myLVItems		
	)
				

	rollout RLTFindTexture "Find Texture"
	(
		local dragFlag = false		
		
		editText searchTerm "Name" width:200  align:#left across:2
		label lbl_nameAvailable " Matches: " style_sunkenedge:true align:#right width:100 height:18
		
		label lbl_spacing "" offset:[0,10]
		
		listbox lb_ServerPaths "Libraries" items:thePathsNames width:75 height:10 selection:1 across:2 
		
		dotNetControl dnListView_Textures "System.Windows.Forms.ListView" width:240 height:150 align:#left offset:[-80,0]
	
		on lb_ServerPaths selected val do
		(
			GetAllFiles thePaths[val]		
			if(RLTFindTexture.searchTerm.text!="")do
			(
				GetMatches RLTFindTexture.searchTerm.text
				--Update the list
				UpdateListViewItems()		
				RLTFindTexture.lbl_nameAvailable.text= (" Matches: "+theMatchesIndex.count as string)
			)			
		)

		on dnListView_Textures DoubleClick  sender args do ( DisplayImage sender.focuseditem.SubItems.Item[1].text )
		on dnListView_Textures itemDrag sender args do dragFlag = true
		on dnListView_Textures mouseUp sender args do dragFlag = false
		on dnListView_Textures lostFocus sender args do if dragFlag == true do
		(
			local theFilePath = sender.focuseditem.SubItems.Item[1].text
			
			--place the max-string into a dotnet-string-array
			local dropfilePath = dotnetobject "System.String[]" 1 --this isn't a string, but an array of strings with one member
			dropfilePath.setvalue theFilePath 0
			
			--feed the string into a special dataObject
			local dataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfilePath 
			sender.dodragdrop dataobj ((dotnetclass "DragDropEffects").Copy) 
			print "dragging"
		)	
		
		label lbl_Tutorial "\n    Click the Site where you would like to search for the finish" style_sunkenedge:true width:300 height:40 offset:[0,30]
		button btn_startSearchSteelcase "Steelcase" 	width:70 across:4 
		button btn_startSearchHaworth 	"Haworth"		width:70
		button btn_startSearchDesignTex "Design Tex"	width:70 
		button btn_startSearchAllSteel	"All Steel"		width:70  
		button btn_startSearchMaharam	"Maharam"		width:70 across:4
		button btn_startSearchHerman	"Herman Mill"	width:70 
		button btn_startSearchKnoll		"Knoll"			width:70 
		button btn_startSearchInscape	"Inscape"		width:70 

		button btn_startSearchGoogle 	"Google"       	width:100 height:30 
		
		
		on btn_startSearchGoogle pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=googleBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchSteelcase pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=steelcaseBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchHaworth pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=haworthBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchDesignTex pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=designTexBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchAllSteel pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=allSteelBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchMaharam pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=maharamBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)	
		on btn_startSearchHerman pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=hermanMillerBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)
		on btn_startSearchKnoll pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=knollBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)
		on btn_startSearchInscape pressed do
		(
			if(RLTFindTexture.searchTerm.text!="") do 	
			(
				theUrl=inscapeBaseURL+RLTFindTexture.searchTerm.text		
				try (shelllaunch "firefox.exe"  theUrl)
				catch (shelllaunch "chrome.exe"  theUrl)
			)
		)		
		on searchTerm changed val do 
		(
			--Get all the matching textures
			GetMatches val
			--Update the list
			UpdateListViewItems()				
			--Display on the rollout the amount of matches
			lbl_nameAvailable.text= (" Matches: "+theMatchesIndex.count as string)		
		)
		
		groupBox group1 "Server Search" pos:[5,35] width:338 height:182	
		
		groupBox group2 "Web Search" pos:[5,220] width:338 height:157
		
		on RLTFindTexture open do 
		(
			myLv = dnListView_Textures
			addColumns myLv #("Name","Path")
			myLv.view = (dotnetclass "System.Windows.Forms.View").Details
			myLv.gridlines=true
			myLv.FullRowSelect = true
		)	
	
	)	
	

	
	on execute do
	(
		GetAllFiles thePaths[1]	
		CreateDialog RLTFindTexture width:350 height:380		
	)
	
)