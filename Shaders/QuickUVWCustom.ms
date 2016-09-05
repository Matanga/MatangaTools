macroScript AddSpecificUVW
category:"Matanga"
(	
		fn AddUVW size type =
		(
			myUVW = Uvwmap ()
			myUVW.length = size
			myUVW.width = size
			myUVW.height = size	
			if(type==1) do myUVW.maptype = 0
			if(type==2) do myUVW.maptype = 4
			
			for o in $ do
			(		
				try(	addmodifier o myUVW		)
				catch (print "couldnt add UVW")
			)				
		)	
		
		fn GetUnit unit UnitType =
		(
			test=""
			
			if(UnitType== 1) do test= "cm"
			if(UnitType== 2) do test= "\""
			if(UnitType== 3) do test = "'"
			if(UnitType== 4) do test ="m"
			
			--print test
			valueToDecode= unit as string+ test
			--print valueToDecode
			theUnit = units.decodeValue valueToDecode
			--print theUnit
			return  theUnit		
		)
		
		rollout UVWOptions "Quick Add UVW"
		(			
			dropdownlist scale_dd "" items:#("Planar", "Box") align:#left across:3
			dropdownlist dd_unit "" items:#("cm", "Inches","Feet","Meter")  align:#left 
			spinner  spn_size "" align:#left type:#integer fieldwidth:50			
			button btn_Doit "Add to selected"
			
			on btn_Doit pressed do
			(
				 theValue =GetUnit spn_size.value dd_unit.selection
				AddUVW theValue scale_dd.selection
			)				
		)				
		createDialog UVWOptions width:200	
)