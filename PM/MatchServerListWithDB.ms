	macroscript MatchServerListWithDB 
	category:"Matanga"
(
	local dnFile = dotnetclass "System.IO.File"
	
	local myUserName=undefined
	
	local myMaxini=undefined
		
	--Get a computer database utility manager
	local theDBManager = undefined
	local myComputerTools = undefined
	local theSession= undefined
	
	local theList 

	function GetConfigFilePath =
	(
		thePath=""
		try(thePath= ((getDir #plugcfg)+"\\vray_dr.cfg") )catch()
		thePath
	)	
	
	function GetFormattedFarmList = 
	(
		theFinalText=""
	
		for o in theList do
		(
			newLine= myComputerTools.GetVrayConfigLine o myUserName
			theFinalText=theFinalText+newLine 
		)		
		theFinalText
	)
	
	function AddFormattedOptions theString=
	(
		AString=theString
		
		AString=AString+"restart_slaves 1"
		AString=AString+"\nlist_in_scene 0"
		AString=AString+"\nmax_servers 0"
		AString=AString+"\nuse_local_machine 1"
		AString=AString+"\ntransfer_missing_assets 0"
		AString=AString+"\nuse_cached_assets 1"
		AString=AString+"\ncache_limit_type 2"
		AString=AString+"\ncache_limit 100.000000"		
		
		aString
	)
		
	on execute do 
	(		
		myComputerTools = globalVars.get #ComputerDBUtilsStruct
		theSession = globalVars.get #currentSession		
		theDBManager = globalVars.get #DBManager
		
		--Update the DBManager in case there were changes
		theDBManager.Initialize()
		
		--Get the current User assigned pcs
		try(myUserName=theSession.myName)catch()
		
		--Get the current path for the config file in this computer
		myMaxini=GetConfigFilePath()

		--Delete the previous vray_dr.cfg file
		print myMaxini
		result = dnFile.Delete( myMaxini)

		--Get the list of computer 
		theList=myComputerTools.GetAllComputersNames()
			
		--Create the text for the new config File. First the servers and then the options
		theText= GetFormattedFarmList()
		theText = AddFormattedOptions theText		
			
		--Open the file, write into it. Then close it
		out_file = OpenFile myMaxini mode:"a"
		format "%" theText to:out_file
		close out_file		
	)
)