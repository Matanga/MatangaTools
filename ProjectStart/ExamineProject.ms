
macroscript ExamineProject
	category:"Matanga"
	tooltip:"Examine a project folder"
(	
	--The Root Path
	thePath =	"\\\\COMPARTIDA\Renderings\Jobs\\"			
	--Dotnet Object Directory
	dotDirectory = dotNetClass "System.IO.Directory"		
	--Dotnet Object Path
	dotPath = dotNetClass "System.IO.Path"												
	
	
	--All full paths of the directories in the Jobs directory
	allSubfolders=#()
	--Only the names of all the folders
	allNames=#()
	
	--Search Variables
	theMatchesIndex=#()
	theMatchesNames=#()
	
	--The full path of the selected project to examine
	theProjectName=""
	
	
	theListTree=undefined
	theSubFolders=#()
	
	
	
	--Function that gets all the folders names
	fn GetJobsFolders =
	(
		--Referencio todas las carpetas dentro de la carpeta JOBS
		allSubfolders=dotDirectory.GetDirectories(thePath)	
		--Extract all the folder names from the list
		allNames=for o in allSubfolders collect (dotPath.GetFileName o)			
	)
	GetJobsFolders()

	
	fn dnColor c:[0,0,0] a:255 =((dotNetClass "system.drawing.color").FromArgb a c.x c.y c.z)
	fn dnSize s:[10,10] = (dotnetObject "system.drawing.size" s.x s.y)
	fn dnRec  p:[0,0] s:[10,10] =(dotNetObject "system.drawing.rectangle" p.x p.y s.x s.y )

	
	
	
	fn ClassifyFiles parentNode =
	(			
			thisPath =theProjectName+"\\"+ parentNode.fullpath 
		
			allFiles= dotDirectory.GetFiles(thisPath)
		
			for m in allFiles do
			(
				theName= dotPath.GetFileName m

				n=(dotNetObject "System.Windows.Forms.TreeNode" theName)
				parentNode.nodes.add n					
			)
		
	)	
	
	fn ClassifyDirectories parentNode =
	(
			--print ("classifying " +theProjectName+"\\"+ parentNode.fullpath )
		
			thisPath =theProjectName+"\\"+ parentNode.fullpath 
		
			pathSubFolders= dotDirectory.GetDirectories(thisPath)

			for o in pathSubFolders do
			(					
				theName= dotPath.GetFileName o
				newNode=(dotNetObject "System.Windows.Forms.TreeNode" o)	
				newNode.text=theName	
				
				--newNode.FullPath=o
				--newNode.backColor= 	dnColor c:[50,128,50] a:255			
				parentNode.nodes.add (newNode)	
				
				--newNode.ToolTipText =theProjectName+"\\"+ newNode.fullpath 
				
				ClassifyDirectories newNode
				
				ClassifyFiles newNode
			)
						
		
		/*
			theSubFolders= dotDirectory.GetDirectories(theProjectName)
		
			for o in theSubFolders do
			(				
				theName= dotPath.GetFileName o
				newNode=(dotNetObject "System.Windows.Forms.TreeNode" o)	
				newNode.text=theName				
				--newNode.FullPath=o
				--newNode.backColor= 	dnColor c:[50,128,50] a:255			
				theListTree.nodes.add (newNode)	
				
				ClassifyDirectories newNode
				
				ClassifyFiles newNode
			)		
		*/
	)
		
	fn PopulateTreeView =
	(				
			--print theProjectName
			theSubFolders= dotDirectory.GetDirectories(theProjectName)
			
			for o in theSubFolders do
			(				
				
				theName= dotPath.GetFileName o
				newNode=(dotNetObject "System.Windows.Forms.TreeNode" o)	
				newNode.text=theName	
				
				--newNode.FullPath=o
				--newNode.backColor= 	dnColor c:[50,128,50] a:255			
				theListTree.nodes.add (newNode)	
				newNode.ToolTipText =theProjectName+"\\"+ newNode.fullpath 
				
				ClassifyDirectories newNode
				
				ClassifyFiles newNode		

			)

	)
	
	fn DoTreeViewPanel sender =
	(
				--------------------------------
				--FLOW LAYOUT
				--FLOW LAYOUT
				--------------------------------
				/*Create the flow layout*/dnFlow= dotNetObject "flowLayoutPanel"
				/*Set the backcolor*/dnFlow.backColor= dnColor c:[128,128,128] a:255
				/*Set the flow direction*/dnFlow.Flowdirection = dnFlow.Flowdirection.TopDown
				/*Set the border style*/dnFlow.BorderStyle=dnFlow.BorderStyle.none	
				/*Set the size of the flow to the size of the panel*/dnFlow.bounds =dnRec s:[sender.width, sender.height]

				sender.controls.add dnFlow
		

						--------------------------------
						--TREE VIEW 		 				
						--TREE VIEW 						
						--------------------------------
						
						treeView= dotnetObject"TreeView"
						treeView.bounds =dnRec s:[dnFlow.width-7, 200]
		
						theListTree=treeView
		
						dotNet.addEventHandler treeView "AfterSelect" ( 
							fn CreateDirMacro = 
							(
								--print ExcelAnalizer.theTreeView.SelectedNode.Name
								print theListTree.SelectedNode.ToolTipText
							)  
						)
						--THIS OPENS THE CURRENT SELECTED NODE ON AN EXPLORER
						dotNet.addEventHandler treeView "MouseDoubleClick" ( 
							fn CreateDirMacro = 
							(
								--print ExcelAnalizer.theTreeView.SelectedNode.Name
								--print theListTree.SelectedNode.ToolTipText
								thisPath =theProjectName+"\\"+ theListTree.SelectedNode.fullpath 

								extension = dotPath.GetExtension(theListTree.SelectedNode.fullpath )
								
								--Folders ""  ---- Images ".jpg" ----- PDF ".pdf"
								if(extension ==""or extension ==".jpg" or extension ==".pdf" ) do
								(
									shellLaunch "explorer.exe" thisPath
									--print "Folder double clicked"
								)								

								if(extension ==".max") do
								(
									theVal= yesNoCancelBox "Do you want to open this file inside this current max session?\nYes: Opens in this max \nNo: opens a new max" title:"Open File Dialog"
									if(theVal==#Yes) do
									(
										--print "opening here"
										loadMaxFile thisPath
									)
									if(theVal==#No) do
									(									
										--print "opening new"
										shellLaunch "explorer.exe" thisPath
									)
								)	

								if(extension==".dwg")do
								(			

									theVal= queryBox  "Do you want to import this file?" title:"Import CAD File Dialog"

									if(theVal==true)do importfile thisPath								
								)
								
							)  
						)						
						dotNet.setLifetimeControl treeView #dotnet								
		
		
		
						/*
						dotNet.addEventHandler treeView "AfterSelect" ( 
							fn CreateDirMacro = 
							(
								--print ExcelAnalizer.theTreeView.SelectedNode.Name
								print ExcelAnalizer.theTreeView.SelectedNode.Text
							)  
						)

						dotNet.addEventHandler treeView "DoubleClick" ( 
							fn CreateDirMacro = 
							(
								ExcelAnalizer.theMatTextBox.text =ExcelAnalizer.theTreeView.SelectedNode.Text
								--print ExcelAnalizer.theTreeView.SelectedNode.Text
								ExcelAnalizer.currentMaterial = ExcelAnalizer.theTreeView.SelectedNode.Text
								ExcelAnalizer.StartSearch()
							)  
						)
						dotNet.setLifetimeControl treeView #dotnet								
						*/
						
						dnFlow.controls.add treeView

	)

	rollout ProjectInfo "Project Info"
	(
		--label lbl_nameAvailable theProjectName align:#left

		dotnetcontrol maxControl "MaxCustomControls.MaxUserControl"  \
				width: (ProjectInfo.width)\
				height:(ProjectInfo.height)\
				offset:[-13,-5]

				
		on ProjectInfo open do
		(
			sp = dotnetobject "SplitContainer"
			sp.orientation = sp.orientation.horizontal
			sp.splitterDistance=20
			sp.splitterWidth=2			
			
			sp.bounds =dnRec s:[maxControl.width, maxControl.height-5]			
			
			sp.panel1.backColor =dnColor c:[128,128,100] a:128
			
			dnButton= dotnetObject "button"
			dnButton.Size = dnSize s:[sp.panel1.width, sp.panel1.height]	

			
			dotNet.addEventHandler dnButton "click" ( 
				fn CreateDirMacro = 
				(
					shellLaunch "explorer.exe" theProjectName
				)  
			)
			dotNet.setLifetimeControl dnButton #dotnet		
			

			

			dnButton.text = dotPath.GetFileName theProjectName
			sp.panel1.controls.add dnButton
			
			sp.panel2.backColor =dnColor c:[100,100,100] a:255

			
			maxControl.controls.add sp
			
			DoTreeViewPanel sp.panel2
			PopulateTreeView()
			
		)
		
	)

	rollout ExamineProject "Find Project"
	(
		editText searchTerm "Name" width:150 
		label lbl_nameAvailable "" align:#left
		listbox lb_Matches items:#() height:10
		
		on searchTerm changed val do 
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
			--Display on the rollout the amount of matches
			lbl_nameAvailable.text= ("Matches: "+theMatchesIndex.count as string)					
			--Reset the list of matching names
			theMatchesNames=#()				
			--If the amount is less than 20 then show the matches in the listbox			
			if(theMatchesIndex.count <=50) do
			(									
				for o in theMatchesIndex do	append theMatchesNames allNames[o]					
			)
			lb_Matches.items=theMatchesNames						
			
		)		

		on lb_Matches doubleClicked val do
		(
			theProjectName = allSubfolders[ theMatchesIndex[ lb_Matches.selection]]	
			
			CreateDialog ProjectInfo width:300 height:300
			DestroyDialog ExamineProject

		)				
		
	)
	try(t=windows.getChildHWND 0 "Find Project"
	UIAccessor.CloseDialog t[1])catch()
	CreateDialog ExamineProject width:250 height:200

)