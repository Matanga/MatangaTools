macroScript FarmAssigner
	category:"Matanga"
(
	local myDesignerTools
	local myComputerTools
	
	
	local selectedDesignerFarms
	
	
	
	
	function GetCurrDesignerAssigned theName =
	(
			
	)
			
	rollout RLTFarmAssigner "Assign Farms Utility"
	(
		label LBTitle "" offset:[0,20]
		
		Listbox lbTheDesigners items:(myDesignerTools.GetAllDesignersNames()) height:10 width:100 align:#left across:3
			
		listbox lbCurrSelected items:#() height:10 width:100 align:#middle
		
		multiListBox mlbAllFarms items:(myComputerTools.GetAllComputersNames()) height:10 width:100 align:#right			
			
		button btnMultiSelection "Assign selected"

		button btnFreeAll "Free All"
			
		button btnQueryDesigner "Query Designer"

			
		on btnQueryDesigner pressed do
		(

			theAsssigned = myComputerTools.QueryDesignerComputers lbTheDesigners.selected
			
			theText=("PCs Assigned to "+ lbTheDesigners.selected+" :")
			
			for o in theAsssigned do
			(
				theText=theText+"\n"+o
			)
			messageBox theText
		)


			
		on btnMultiSelection pressed do
		(
			--Create an array to hold the name of the selected computers
			theNames=#()
			--Add the names
			for o in mlbAllFarms.selection do
			(
				append theNames mlbAllFarms.items[o]
			)			
			--Update the Computer Database
			myComputerTools.AssignFarmsToDesigner theNames lbTheDesigners.selected
		)
		
		on btnFreeAll pressed do
		(
			myComputerTools.FreeAllFarms()
		)			
		
		
	)
	
	
	
	on execute do
	(
		try
		(
			myDesignerTools = globalVars.get #DesignerDBUtilsStruct
			myComputerTools = globalVars.get #ComputerDBUtilsStruct
			createDialog RLTFarmAssigner width:350 height:400
		)
		catch
		(
			messagebox "You must run KispTools as an admin before using this script"
		)
	)
)