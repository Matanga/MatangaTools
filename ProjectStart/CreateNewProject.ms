	/************************************
		 Macroscript that Sets up all the necessary information for creating a new projected
			--It finds out if the project already exists
			--It creates the project folder hierarchy
			--If requested it imports a base file
			--If requested it saves the file with the appropiate name 

	*/
	macroscript CreateNewProject
	category:"Matanga"
	tooltip:"Create the Folder Hierarchy for this project"
	(	
		-------------------------------------------------------------------------
		-------------------------------------------------------------------------
		----VARIABLES
		------------------------------------------------------------------------
		-------------------------------------------------------------------------
				--DOTNET CLASSES
				dotDirectory = dotNetClass "System.IO.Directory"		
				--Dotnet Object Path
				dotPath = dotNetClass "System.IO.Path"		
				
				
				--PATHS VARIABLES
				thePath =	"\\\\COMPARTIDA\Renderings\Jobs\\"								--The Root Path for all the projects
				templatePath ="\\\\COMPARTIDA\Renderings\Resources\KispTools\BaseMax"		--The path for the template starting scenes
				
				--ALL JOBS
				allJobsPaths=#()
				allJobsNames=#()
				
				
				--VARIABLES FOR CREATING THE PROJECT FOLDER STRUCTURE 
				local theProjectNumber=undefined
				local theProjectName=""		--The name of the project			
				
				
				--FLAGS
				pathAvailable=false			--Is the chosen path available to use FLAG						
				saveFile=false
				createDirectories= true
				
				--VARIABLES FOR THE TEMPLATE FILES
				selectedBaseFile=1
				
				
				myBaseFiles=#()	
				myBaseFilesNames=#()	
				

				
		-------------------------------------------------------------------------
		-------------------------------------------------------------------------
		----INITIALIZATION
		------------------------------------------------------------------------
		-------------------------------------------------------------------------
				--Function that gets all the folders names
				fn GetAllDirectories =
				(
					--Referencio todas las carpetas dentro de la carpeta JOBS
					allJobsPaths=dotDirectory.GetDirectories(thePath)	
					--Extract all the folder names from the list
					allJobsNames=for o in allJobsPaths collect (dotPath.GetFileName o)		
				)
				GetAllDirectories()
				/************************************
					USE:Function that fetches and stores all 
					available BaseFiles for starting the project
				*/
				fn GetBaseFiles myPath =
				(
					myBaseFiles=#()										--Vacio el array de archivos bases
					myBaseFilesNames=#()								--Vacio el array de nombres de props
					append 	myBaseFilesNames "None"						--Agrego la opcion de no empezar con ningun Base file
					myBaseFiles = getFiles ((templatePath)+"\\*.max" )	--Referencio los archivos max demtro del path en el array myProps
					for o in myBaseFiles do								--Referencio los nombres(string) de los archivos en myProps
					(	
						dotPath = dotNetClass "System.IO.Path"	
						append 	myBaseFilesNames ( dotPath.GetFileNameWithoutExtension(o))	
					)
				)	
				GetBaseFiles templatePath

		-------------------------------------------------------------------------
		-------------------------------------------------------------------------
		----SCRIPT UTILITIES
		------------------------------------------------------------------------
		-------------------------------------------------------------------------

				/************************************
					 USE:Function that creates the necessary
					folder structure
				*/			
				fn CreateDirectoriesHierarchy =
				(			
						makeDir (thePath+theProjectName+"\\Base") all:true
						makeDir (thePath+theProjectName+"\\Base\Info") all:true
						makeDir (thePath+theProjectName+"\\Final") all:true
						makeDir (thePath+theProjectName+"\\Preview") all:true				
				)	

				fn MergeBaseFile =
				(
					theBaseFileFullPath=myBaseFiles[selectedBaseFile-1]
					--print "merging"
					--print theBaseFileFullPath
					mergemaxfile theBaseFileFullPath  #select #mergeDups #useSceneMtlDups    -- Merge in the objects and select them
				
					renderSettingsPath=replace theBaseFileFullPath (theBaseFileFullPath.count-3) 4 ".rps" --Create the Path for the render presets to check if it exists

					--print renderSettingsPath
					--Check if a render presets files for this template exists and if so import it
					  if ((getfiles renderSettingsPath).count != 0) do	
					  (
						  --print "render presets exist"
						  renderpresets.LoadAll 0 renderSettingsPath
					  )
				)
		
		-------------------------------------------------------------------------
		-------------------------------------------------------------------------
		----UI UTILITIES
		------------------------------------------------------------------------
		-------------------------------------------------------------------------	
				
				/************************************
					USE:Finds out if the given project Number exists
					ARGUMENTS : 
							projectNum = string = the number of this project
				*/
				fn DoesProjectExist projectNum =
				(
					exists=false
					theVal="*"+projectNum+"*"
					for o=1 to allJobsNames.count by 1 do
					(
						if( matchPattern allJobsNames[o] pattern:theVal== true) do exists=true				
					)			
					exists
					
				)			

				/************************************
					USE: Checks if the input text in the number slot in the ui corresponds to an existing
						project number or not.
					ARGUMENTS :val= the string provided
					RETURNS :	Array --- Flag to know if project number is usable or not
									--- The string to show in the edit text UI( it is changed from the original  in some cases)
									--- The string to display in the Debug label in the UI
				*/
				fn CheckJobNumber val =
				(
					isUsable=false			-- Flag to know if project number is usable or not 
					theReturnString=val		-- The string to show in the edit text UI( it is changed from the original  in some cases)
					theReturnDebug=""		-- The string to display in the Debug label in the UI

					--We create a flag to chek if the input has the correct length
					isCorrectLength=true
					--If it is smaller than 6 we let the user know
					if(theReturnString.count < 6 ) do
					(
						isCorrectLength=false
						theReturnDebug="Number must have 6 digits"
					)						
					--If it is larger than 6 we contraint the string to have a maximum of 6 characters
					if( theReturnString.count > 6) do
					(
						theReturnString= substring theReturnString 1 6
						--edt_TheProjectNumber.text= theReturnString
					)
					--We create a flag to know if the input is a number
					isANumber=true
					--We check if the input is a number
					 if( isKindOf (theReturnString as number) integer ==false ) do
					(
						theReturnDebug="Please input a valid number"
						isANumber=false
					)
					--If the input passed all the tests
					if(isANumber==true and isCorrectLength==true) do
					(
						--Check if the project  number exists
						if( ( DoesProjectExist theReturnString) ==true ) then
						(
							theReturnDebug="Project Exists"								
						)
						else
						(
							theReturnDebug="Available"								
							isUsable=true
						)
					)
					--We create the return array and append the values
					theReturn=#()
					append theReturn isUsable
					append theReturn theReturnString
					append theReturn theReturnDebug
					
					theReturn
				)
				/************************************
					USE: Creates and returns the final project name by 
						adding the project number an "*" and the project name.
						if the project name has space characters it removes them.
					ARGUMENTS :  numVal  = the project Number 
								nameVal = The project Name
				*/
				fn ParseProjectName numVal nameVal =
				(
					theName=""
					
					nameVal=substituteString nameVal " " ""
					
					theName=numVal+"-"+nameVal
					
					
					theName
						
				)
				
		-------------------------------------------------------------------------
		-------------------------------------------------------------------------
		---- UI
		------------------------------------------------------------------------
		-------------------------------------------------------------------------		
				Rollout CreateProjectRollout "Create New Project"
				(	
					
					--ROOT PATH GROUP BEGIN
							Label lbl_theRoot thePath width:180 align:#left  offset:[0,15] across:2
							button btn_theRoot "Change" align:#Right offset:[0,12] 
							groupBox gb_TheRoot "Rooth Path "  	pos:[5,0] width: 340 height: 50
							on btn_theRoot pressed do
							(
								newPath = getSavepath()
								if(newPath != undefined) do
								(
									thePath=newPath
									lbl_theRoot.text = thePath
									GetAllDirectories()
								)				
							)			
					--ROOT PATH GROUP END						
							
							subrollout ProjectName "Project Name"

							button btn_Run "Create Project"  width: 150 height: 40 align:#center 	offset:[0,280]	
							on btn_Run pressed do
							(
									if(pathAvailable==true)then
									(		
										--Disable this button to prevent it from being pressed twice
										btn_Run.enabled=false
										--Create the folders if necessary
										if(createDirectories==true) do CreateDirectoriesHierarchy()
										--Import the corresponding Base File if necessary
										if(selectedBaseFile != 1) do MergeBaseFile()										
										--Save if necessary
										if(saveFile==true) do 
										(
											theSaveFilePath= thePath+theProjectName+"\\Base\\"+theProjectName+"_01.max"
											--print theSaveFilePath
											saveMaxFile theSaveFilePath quiet:true											
										)
										--Display the success message
										messageBox ("Project "+theProjectName  +" created succesfully! Matanga is a merciful god")
										destroyDialog CreateProjectRollout
									)
									else
									(
										messageBox "The Project Name hasnt been set or is unavailable"
									)
							)					
				)
				--ROLLOUT WITH THE PROJECT NAME OPTIONS
				rollout SubProjectName "ProjectName"
				(
					--Project Number
					edittext edt_TheProjectNumber "Number:" fieldWidth:80 labelOnTop:false  across:2			
					Label lbl_nameAvailable "Write project number" align:#Left offset:[-10,0] style_sunkenedge:true width:160 height:20
					
					--Project Name
					edittext edt_TheProjectName "Name:   " fieldWidth:250 labelOnTop:false 	enabled:false	
					
					Label lbl_space "" 

					--Final Project Name
					Label lbl_FinalNameTitle "Project Name:" align:#Left  style_sunkenedge:false width:100 across:2
					Label lbl_FinalName "" align:#Left offset:[-70,0]  style_sunkenedge:true width:220 height:18							
		
					
					on edt_TheProjectNumber changed val do 
					(									
						theResults= CheckJobNumber val				--Check the current Input												
						pathAvailable=theResults[1]						--First value is flag to know if usable or not
						edt_TheProjectNumber.text= theResults[2]		--Second value is the text that will appear in the edit text
						lbl_nameAvailable.text= theResults[3]			--Third value is the debug text			
						
						--If the number is valid we allow the Name to be set
						if(pathAvailable==true) then edt_TheProjectName.enabled=true								
												else edt_TheProjectName.enabled=false			
						--No matter what the Input is we will parse the final Folder Name
						lbl_FinalName.text = ParseProjectName edt_TheProjectNumber.text edt_TheProjectName.text
						theProjectName=lbl_FinalName.text
					)		
					
					on edt_TheProjectName changed val do
					(
						--No matter what the Input is we will parse the final Folder Name
						lbl_FinalName.text = ParseProjectName edt_TheProjectNumber.text edt_TheProjectName.text
						theProjectName=lbl_FinalName.text
					)							
				)
				--ROLLOUT WITH THE BASE FILE OPTIONS
				rollout SubOptions "Base File"
				(
					label lbl_BaseFile "Base File:"  align:#left across:3
					dropdownlist dd_BaseFile "" width:160 items:myBaseFilesNames align:#left offset:[-40,-2]
					checkbox cb_SaveFile "Save File" align:#right 
					
					on cb_SaveFile changed val do
					(
						saveFile=val
					)
					on dd_BaseFile selected val do
					(
						selectedBaseFile=val
					)					
				)
				--ROLLOUT WITH THE FOLDER HIERARCHY OPTIONS
				rollout SubFolders "Folder Hierarchy"
				(
					checkbox  setup "Create folder Hierarchy" checked:createDirectories tooltip:"Automatically create folder structure?"
					multiListBox mlb "" items:#("Base","Finals","Previews") selection:#(1,2,3) height:3					
					on setup changed val do (createDirectories=val)
				)
				

				
				--Try to destroy the Rollout in case it already exists
				try(t=windows.getChildHWND 0 "Create New Project"
				UIAccessor.CloseDialog t[1])catch()
				
				--Create the Rollout
				createDialog CreateProjectRollout width:350 height:400 
				--Add the ProjectName SubRollout
				AddSubRollout CreateProjectRollout.ProjectName SubProjectName
				--Add the Options SubRollout				
				AddSubRollout CreateProjectRollout.ProjectName SubOptions
				--Add the Folders SubRollout				
				AddSubRollout CreateProjectRollout.ProjectName SubFolders
				
				CreateProjectRollout.ProjectName.height += 270

	)