	try(destroyDialog CreateProjectRollout)catch()

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
				pathAvailable=false			--Is the chosen path available to use FLAG		
				
				--VARIABLES FOR THE TEMPLATE FILES
				myBaseFiles=#()	
				myBaseFilesNames=#()	
				
				--UI VARIABLES
				currentHeight=0		
				
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
				fn CreateDirectories =
				(			
						makeDir (thePath+theProjectName+"\\Base") all:true
						makeDir (thePath+theProjectName+"\\Base\Info") all:true
						makeDir (thePath+theProjectName+"\\Final") all:true
						makeDir (thePath+theProjectName+"\\Preview") all:true				
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
					USE: Increments the current haight used by the Group Boxes
					ARGUMENTS :
				*/
				fn IncrementCurrHeight num = 
				(
					currentHeight = currentHeight+num			
					currentHeight
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
								)				
							)			
					--ROOT PATH GROUP END
					
					
					--FOLDER NAME GROUP BEGIN
							--Project Number
							edittext edt_TheProjectNumber "Number:" fieldWidth:80 labelOnTop:false offset:[0,25] across:2			
							Label lbl_nameAvailable "Write project number" align:#Left offset:[-20,23] style_sunkenedge:true width:180 height:20
							
							--Project Name
							edittext edt_TheProjectName "Name:   " fieldWidth:279 labelOnTop:false 	enabled:false	
							
							Label lbl_space "" 

							--Final Project Name
							Label lbl_FinalNameTitle "Project Name:" align:#Left  style_sunkenedge:false width:100 across:2
							Label lbl_FinalName "" align:#Left offset:[-90,0]  style_sunkenedge:true width:250 height:18							
							
							--Group
							groupBox gb_ProjectName "Project Name"  pos:[5,(IncrementCurrHeight 60)] width: 340 height: 110			
							
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
							
							
					--FOLDER NAME GROUP END

					--OPTIONS GROUP BEGIN
					label lbl_BaseFile "Base File:" offset:[0,25] align:#left across:3
					dropdownlist dd_BaseFile "" width:160 items:myBaseFilesNames align:#left offset:[-40,23]
					checkbox cb_SaveFile "Save File" align:#right offset:[0,25]
					groupBox gb_OptionsGroup "Options"  pos:[5,(IncrementCurrHeight 120)] width: 340 height: 50
					--OPTIONS GROUP END
					
					--RUN SCRIPT MAIN
					button btn_Run "Create Project"  width: 150 height: 40 align:#center offset:[0,10]			
					on btn_Run pressed do
					(
							if(pathAvailable==true)then
							(					
								btn_Run.enabled=false
								--Create the folders
								CreateDirectories()
								--Import the corresponding Base File
								if(dd_BaseFile.selection != 1) do
								(
									theBaseFileFullPath=myBaseFiles[dd_BaseFile.selection-1]
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
								--Save if necessary
								if(cb_SaveFile.checked==true) do 
								(
									theSaveFilePath= thePath+theProjectName+"\\Base\\"+theProjectName+"_01.max"
									--print theSaveFilePath
									saveMaxFile theSaveFilePath quiet:true
										--here we save the file
								)
								theMessage= "Project "+theProjectName  +" created succesfully!  All hail Matanga"
								messageBox theMessage
								destroyDialog CreateDirRollout
							)
							else
							(
								messageBox "The Project Name hasnt been set or is unavailable"
							)
					)
					
				)
				try(t=windows.getChildHWND 0 "Create New Project"
				UIAccessor.CloseDialog t[1])catch()
				createDialog CreateProjectRollout width:350 height:500 pos:(Mouse.screenpos)

	)