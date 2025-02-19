



CREATE VIEW [dbo].[V0100_ALLOCATED_MACHINES]
AS
	SELECT	MAM.Allocation_ID , MAM.Cmp_ID , MAM.Emp_ID , MAM.Shift_ID , MAM.Machine_ID , MAM.Effective_Date, EM.Alpha_Emp_Code , EM.Emp_Full_Name,EM.Emp_First_Name, 
			SM.Shift_Name, MAM1.Current_Allocation , I.Branch_ID , I.Grd_ID , I.Dept_ID , i.Desig_Id , I.Cat_ID ,
			I.Type_ID , I.Vertical_ID , I.SubVertical_ID , I.Segment_ID , I.subBranch_ID , T.Machine_Name
	FROM	T0040_MACHINE_ALLOCATION_MASTER  MAM WITH (NOLOCK)
			LEFT OUTER JOIN (SELECT	EMP_ID ,MAX(Effective_Date) as Current_Allocation
	 						 FROM	T0040_MACHINE_ALLOCATION_MASTER MAM1 WITH (NOLOCK)
	 						 WHERE	Effective_Date <= GETDATE()
	 						 GROUP BY EMP_ID
	 						 ) MAM1 ON MAM.Emp_ID=MAM1.Emp_ID and MAM.Effective_Date=MAM1.Current_Allocation
	 		INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = MAM.Shift_ID AND SM.Cmp_ID = MAM.Cmp_ID
	 		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = MAM.Emp_ID AND EM.Cmp_ID = MAM.Cmp_ID
	 		--INNER JOIN T0040_Machine_Master MM ON MM.Machine_ID = MAM.Machine_ID AND MM.Cmp_ID = MAM.Cmp_ID
	 		INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = MAM.Emp_ID AND i.Cmp_ID = MAM.Cmp_ID
 			INNER JOIN 
					( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
						FROM T0095_INCREMENT I  WITH (NOLOCK)
						INNER JOIN 
							(
								SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM T0095_INCREMENT I3 WITH (NOLOCK)
								WHERE I3.Increment_effective_Date <= GETDATE()
								GROUP BY I3.EMP_ID  
							) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID = I3.Emp_ID	
					   WHERE I.INCREMENT_EFFECTIVE_DATE <= GETDATE() 
					   GROUP BY I.EMP_ID  
					) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
			CROSS APPLY (SELECT STUFF((SELECT	',' + MM.Machine_Name
								   FROM		T0040_Machine_Master MM WITH (NOLOCK)
								   WHERE	CHARINDEX('#' + CAST(MM.Machine_ID AS VARCHAR(10)) + '#', '#' + MAM.Machine_ID + '#') > 0
											FOR XML PATH('')), 1,1,'') AS Machine_Name) T
	 		



