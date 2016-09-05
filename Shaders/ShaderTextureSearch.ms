
struct ShaderTextureSearch
(	
	/*
	----------------------------
		editTex    |  50 px
		space 		|
	----------------------------
	   Search Type panel   | 50 px
	----------------------------		
	*/
	
	--------------------------------------------
	-- UI REFERENCES
	--------------------------------------------	
	myInst=undefined,			--The Main rollout	
	
	baseHeight=85,
	
	theMainController=undefined,
	theMainPanel=undefined,	--The Main Panel
	theMainFlow=undefined, 	--The Main flow layout
	
	
	searchTerm="",		--The string to be searched

	--------------------------------------------
	--------------------------------------------
	-- TEXTURE REFERENCES
	-- TEXTURE REFERENCES
	--------------------------------------------
	--------------------------------------------	
	--Dotnet Object Directory
	dotDirectory = dotNetClass "System.IO.Directory",		
	--Dotnet Object Path
	dotPath = dotNetClass "System.IO.Path",	
	
	 dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects",
	
	--The Root Path
	steelcaseTileablePath =	"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Steelcase Tileable Maps\\",		
	
	theMapsPaths=#
	(
		"\\\\COMPARTIDA\Renderings\Resources\Textures\Mapas\Steelcase Tileable Maps\\"
		
	),
	
	--All the Files in the Directory										
	allFiles=#(),	
	--Only the names of the Files
	allNames=#(),	
	--Search Variables
	theMatchesIndex=#(),
	theMatchesNames=#(),
	
	theTreeView=undefined,
	currentHoveredNode=undefined,
	--------------------------------------------
	--------------------------------------------
	-- DOTNET UTILITIES
	-- DOTNET UTILITIES
	--------------------------------------------
	--------------------------------------------	
	include "\\\\COMPARTIDA\Renderings\Resources\KispTools\KispToolsUtils.ms" 
	
	--------------------------------------------
	--------------------------------------------
	-- UI UTILITIES
	-- UI UTILITIES
	--------------------------------------------
	--------------------------------------------
	
	fn ResizeRollout newSize =
	(
		theSize=ShaderTextureSearch.baseHeight+newSize
		ShaderTextureSearch.myInst.height=theSize
		
		theMainController.height=theSize
		
		--ShaderTextureSearch.theMainPanel.height=theSize
		ShaderTextureSearch.theMainPanel.Size = ShaderTextureSearch.dnSize s:[250, theSize]				

		--ShaderTextureSearch.theMainFlow.height=theSize
		ShaderTextureSearch.theMainFlow.Size = ShaderTextureSearch.dnSize s:[250, theSize]				
		
	),	
	
	fn GetNewPanel theHeight =
	(
			newPanel=dotnetObject "panel"
			newPanel.Size = ShaderTextureSearch.dnSize s:[ShaderTextureSearch.theMainPanel.width, theHeight]	
			newPanel.margin= newPanel.margin.empty	
		
			newPanel
	),
	
	fn ClearFlowLayout = 
	(
		if(ShaderTextureSearch.theMainFlow.controls.count>1)do
		(			
			for x=1 to ShaderTextureSearch.theMainFlow.controls.count by 1 do
			(
				ShaderTextureSearch.theMainFlow.controls.RemoveAt x
			)
			
		)	
	),	
	
	fn GetDropFile thePath=
	(
			theIniFile = getdir #maxData  + "3dsmax.ini" 
			theKeys = getIniSetting theIniFile "FileList" 
			maxfilearray = for o in theKeys where o != "MaxFiles" collect getIniSetting theIniFIle "FileList" o 
			--filenameString =  maxfilearray[1]

			dropfile = dotnetobject "System.String[]" 1
			dropfile.setvalue thePath 0	
			dropfile				
	),
	--------------------------------------------
	--------------------------------------------
	-- TEXTURE SEARCH UTILITIES
	-- TEXTURE SEARCHUTILITIES
	--------------------------------------------
	--------------------------------------------	
	--Function that gets all the folders names
	fn GetAllFiles thePath =
	(
		--Referencio todas las carpetas dentro de la carpeta JOBS
		ShaderTextureSearch.allFiles=ShaderTextureSearch.dotDirectory.GetFiles(thePath)	
		--Extract all the folder names from the list
		ShaderTextureSearch.allNames=for o in ShaderTextureSearch.allFiles collect (ShaderTextureSearch.dotPath.GetFileName o)
	),
	
	fn GetMatchingTextures  =
	(
			--Define the search term
			theText="*"+ShaderTextureSearch.searchTerm+"*"
			--Reset the matches list
			ShaderTextureSearch.theMatchesIndex=#()
			
			--Search in the folders list for all matches
			for o=1 to ShaderTextureSearch.allNames.count by 1 do
			(					
				if (matchPattern ShaderTextureSearch.allNames[o] pattern:theText ==true) do  append ShaderTextureSearch.theMatchesIndex o				
			)				
			--Display on the rollout the amount of matches
			
			------lbl_nameAvailable.text= ("Matches: "+theMatchesIndex.count as string)					
			
			--Reset the list of matching names
			ShaderTextureSearch.theMatchesNames=#()				
			--If the amount is less than 20 then show the matches in the listbox			
			if(ShaderTextureSearch.theMatchesIndex.count <=20) do
			(									
				for o in ShaderTextureSearch.theMatchesIndex do	append ShaderTextureSearch.theMatchesNames allNames[o]					
			)
	),
	
	--------------------------------------------
	--------------------------------------------
	-- TEXTURE SEARCH UI
	-- TEXTURE SEARCH UI
	--------------------------------------------
	--------------------------------------------
	

	
	fn initPanelTexture =
	(		
		--First we clear the flowLayoutPanel
		ShaderTextureSearch.ClearFlowLayout()
		

		
		--
		if(ShaderTextureSearch.searchTerm!= "") then
		(
			--Get all the files from the provided Path
			ShaderTextureSearch.GetAllFiles ShaderTextureSearch.steelcaseTileablePath
			--print ShaderTextureSearch.allNames.count
			--Get all the matching files from the collected Files
			ShaderTextureSearch.GetMatchingTextures()
			--print ShaderTextureSearch.theMatchesNames.count

			--Resize the main rollout
			ShaderTextureSearch.ResizeRollout 300
			
			----------------------
			--PANEL
			--PANEL
			----------------------
			--Generate a new Panel for the results
			newPanel = ShaderTextureSearch.GetNewPanel 300
			--Add the panel to the Main Flow Layout
			ShaderTextureSearch.theMainFlow.controls.add newPanel
			--Debug the color to see if its working
			newPanel.backColor =ShaderTextureSearch.dnColor c:[120,10,120] a:255
			

				------------------
				--TREE VIEW
				--TREE VIEW
				------------------
				--Create the tree view
				treeView= dotnetObject"TreeView"
				ShaderTextureSearch.theTreeView=treeView
				--Definethe bounds
				treeView.bounds =dnRec s:[ShaderTextureSearch.theMainFlow.width, 300]		
				--Add it to its parent controls
				newPanel.controls.add treeView


				parentNode=(dotNetObject "System.Windows.Forms.TreeNode" "Steelcase Tileable Maps")	
				---newNode.text=theName							
				--newNode.FullPath=o
				--newNode.backColor= 	dnColor c:[50,128,50] a:255
				
				treeView.nodes.add (parentNode)	
				--parentNode.ToolTipText =theProjectName+"\\"+ newNode.fullpath 


				for o in ShaderTextureSearch.theMatchesNames do
				(					
					newNode=(dotNetObject "System.Windows.Forms.TreeNode" o)	
					--newNode.text=theName	
					--print "addedNode"
					--newNode.FullPath=o
					--newNode.backColor= 	dnColor c:[50,128,50] a:255			
					parentNode.nodes.add (newNode)						
					--newNode.ToolTipText =theProjectName+"\\"+ newNode.fullpath 
				)
				parentNode.Expand()


							
				dotNet.addEventHandler treeView "click" ( 
					fn CreateDirMacro sender args = 
					(
						ShaderTextureSearch.formatprops args
						--print (ShaderTextureSearch.allFiles[ShaderTextureSearch.theMatchesIndex[args.item.index+1]])
					)  
				)
	
				
				
				dotNet.addEventHandler treeView "ItemDrag" ( 
					fn CreateDirMacro sender args = 
					(
						
						--Get the drop file
						dropfile= ShaderTextureSearch.GetDropFile ( ShaderTextureSearch.allFiles[ShaderTextureSearch.theMatchesIndex[args.item.index+1]])
						--Create the Data Object
						DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfile
						--Start the Drag and drop
						sender.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)				

					)  
				)



		)
		else
		(
			ShaderTextureSearch.ResizeRollout 0								

			messageBox "No search term has been defined."
		)
	),
		
	--------------------------------------------
	--------------------------------------------
	-- SHADERS SEARCH UI
	-- SHADERS SEARCH UI
	--------------------------------------------
	--------------------------------------------	
	fn initPanelShader =
	(
		--print (ShaderTextureSearch.theMainFlow.controls.count)
		if(ShaderTextureSearch.theMainFlow.controls.count>1)do
		(			
			for x=1 to ShaderTextureSearch.theMainFlow.controls.count-1 by 1 do
			(
				ShaderTextureSearch.theMainFlow.controls.RemoveAt x
			)			
		)
		
		
		if(ShaderTextureSearch.searchTerm!= "") then
		(
			ShaderTextureSearch.ResizeRollout 200											
		)
		else
		(
			ShaderTextureSearch.ResizeRollout 0											

			messageBox "No search term has been defined."
		)
	),
	--------------------------------------------
	--------------------------------------------
	-- MAIN PANELS
	-- MAIN PANELS
	--------------------------------------------
	--------------------------------------------


	fn InitSearchTypePanel sender =
	(		
		-- PANEL
		-- PANEL
			newPanel= ShaderTextureSearch.GetNewPanel 50

		
					--FLOW
					--FLOW
					panelFlow =dotnetobject "flowLayoutPanel"		
					panelFlow.Size = ShaderTextureSearch.dnSize s:[sender.width, 50]	
					panelFlow.backColor =ShaderTextureSearch.dnColor c:[120,10,10] a:255
		
					newPanel.controls.add panelFlow	

		
								--BUTTON SEARCH SHADER
								--BUTTON SEARCH SHADER
		
								dnButtonShader=dotNetObject "button"
								dnButtonShader.backColor =ShaderTextureSearch.dnColor c:[120,120,120] a:255
								dnButtonShader.flatStyle=dnButtonShader.flatStyle.Flat
								--dnButtonShader.margin= dnButtonShader.margin.empty
								dnButtonShader.Size = ShaderTextureSearch.dnSize s:[110, 35]						
								
								dnButtonShader.text="Search Shader"	
								panelFlow.controls.add dnButtonShader
						
								dotNet.addEventHandler dnButtonShader "click" ( 
									fn CreateDirMacro = 
									(						
										ShaderTextureSearch.initPanelShader()											
									)  
								)
								dotNet.setLifetimeControl dnButtonShader #dotnet	
								
								
								--BUTTON SEARCH TEXTURE
								--BUTTON SEARCH TEXTURE
								
								dnButtonTexture=dotNetObject "button"
								dnButtonTexture.backColor =ShaderTextureSearch.dnColor c:[120,120,120] a:255
								dnButtonTexture.flatStyle=dnButtonTexture.flatStyle.Flat
								--dnButtonTexture.margin= dnButtonTexture.margin.empty	
								dnButtonTexture.Size = ShaderTextureSearch.dnSize s:[110, 35]		
								
								
								dnButtonTexture.text="Search Texture"	
								panelFlow.controls.add dnButtonTexture
								
								dotNet.addEventHandler dnButtonTexture "click" ( 
									fn CreateDirMacro = 
									(						
										ShaderTextureSearch.initPanelTexture()										
									)  
								)
								dotNet.setLifetimeControl dnButtonTexture #dotnet	
								
								sender.controls.add newPanel
		
	),
	
	
	fn initMainFlow sender =
	(
		ShaderTextureSearch.theMainPanel= sender		--Store the reference

		--sender.margin = sender.margin.empty		
		print "doing mainFlow panel"
		--FLOW PANEL
		--FLOW PANEL
		dnFlow =dotnetobject "flowLayoutPanel"		
		ShaderTextureSearch.theMainFlow= dnFlow	--Store the reference
		
		dnFlow.Flowdirection = dnFlow.Flowdirection.LeftToRight
		--dnFlow.margin = dnFlow.margin.empty
		dnFlow.backColor =ShaderTextureSearch.dnColor c:[10,10,150] a:255
		dnFlow.BorderStyle=dnFlow.BorderStyle.none		
		dnFlow.bounds = ShaderTextureSearch.dnRec s:[250, 50]
		dnFlow.Size = ShaderTextureSearch.dnSize s:[sender.width, 50]				
		sender.controls.add dnFlow		
		
		ShaderTextureSearch.InitSearchTypePanel dnFlow				

	),
	
	--------------------------------------------
	--------------------------------------------
	-- LAUNCH  UI
	-- LAUNCH  UI
	--------------------------------------------
	--------------------------------------------
	fn ui =
	(	
		rollout uiR "The UI" width:232 height:85		(
			edittext et_cc "Search:"
			on et_cc changed val do
			(
				ShaderTextureSearch.searchTerm=val
				--print ShaderTextureSearch.searchTerm
			)
			label lb_Space""
			
			dotnetcontrol mainContr "MaxCustomControls.MaxUserControl"   \
			width: (uiR.width)\
			height:(uiR.height-45)\
			offset:[-14,-5]
			
			on uiR open do
			(
				ShaderTextureSearch.theMainController=mainContr

				--Create the Main Panel
				mainPanel = dotnetobject "panel"	
				--Set color to  Green
				mainPanel.backColor =ShaderTextureSearch.dnColor c:[10,120,10] a:255
				mainPanel.Size = ShaderTextureSearch.dnSize s:[uiR.width, uiR.height-45]	
				mainPanel.padding= mainPanel.padding.empty
				mainContr.controls.add mainPanel		
				
				initMainFlow mainPanel

			)
			
		)		
		createDialog uiR
		myInst =uiR
	),
	
	fn run=
	(
		if(myInst == undefined) then
		(
			ui()
		)
		else
		(
			destrotDialog myInst
			myInst=undefined
		)
		
	)
	
)

global ShaderTextureSearch=ShaderTextureSearch()
ShaderTextureSearch.run()