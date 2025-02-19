
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_AGAINST_GATEPASS]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME
	,@Branch_ID		VARCHAR(MAX)
	,@Cat_ID		VARCHAR(MAX)
	,@Grade_ID		VARCHAR(MAX)
	,@Type_ID		VARCHAR(MAX)
	,@Dept_Id		VARCHAR(MAX)
	,@Desig_Id		VARCHAR(MAX)
	,@Emp_ID		VARCHAR(MAX)
	,@Constraint	VARCHAR(MAX)
	,@Salary_Cycle_id	NUMERIC
	,@Segment_Id	VARCHAR(MAX)
	,@Vertical_Id	VARCHAR(MAX)
	,@SubVertical_Id	VARCHAR(MAX)
	,@SubBranch_Id		VARCHAR(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',0,0,'',0,0,0,'0',0,0

	--added by jimit 04082016
	DECLARE @GatePass_caption as Varchar(20)	
	SELECT @GatePass_caption = Isnull(Alias,'Gate Pass') from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and SortingNo = 33
	--ended
	
	


	SELECT Distinct --LT.For_date ,LM.Leave_Name, 
		Emp_Full_Name,e.Emp_ID,Alpha_Emp_Code,Emp_First_Name,g.Grd_Name,b.BRanch_Address,b.Comp_name
		,b.Branch_Name,d.Dept_Name,Desig_Name,Cmp_Name,Cmp_Address ,@From_Date P_From_Date ,@To_Date P_To_Date,b.Branch_ID,t.type_name 
		,dgm.Desig_Dis_No  ,VS.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name
		,@GatePass_caption as caption          --added by jimit 04082016
	FROM #Emp_Cons EC INNER JOIN T0150_EMP_Gate_Pass_INOUT_RECORD EG WITH (NOLOCK) ON EC.Emp_ID = EG.emp_id 
		INNER JOIN T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON EG.emp_id = LT.Emp_ID --AND EG.For_date = LT.For_Date 
		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID 
		INNER JOIN T0080_EMP_MASTER e  WITH (NOLOCK) ON EC.Emp_ID =e.Emp_ID 
		INNER JOIN 
		--T0095_Increment I ON EC.Increment_ID = I.Increment_ID INNER JOIN
		( SELECT I.Emp_Id ,Grd_ID,Branch_ID,Dept_ID,Desig_ID,TYPE_ID,Vertical_ID,SubVertical_ID,subBranch_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
			( SELECT MAX(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI WITH (NOLOCK) INNER JOIN
				( SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID FROM T0095_Increment WITH (NOLOCK)
					WHERE Cmp_ID = @Cmp_ID AND Increment_effective_Date <= @to_date GROUP BY emp_ID
				) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
			  WHERE TI.Cmp_ID = @Cmp_ID AND TI.Increment_effective_Date <= @to_date GROUP BY ti.emp_id
			) Qry ON I.Increment_Id = Qry.Increment_Id
			--	( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment
			--		WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
			--	) Qry ON I.Emp_ID = Qry.Emp_ID	AND I.Increment_ID = Qry.Increment_ID
		) IQ ON EC.Emp_ID = iq.Emp_ID 
		INNER JOIN T0040_GRADE_MASTER  g WITH (NOLOCK) ON IQ.Grd_ID =g.Grd_ID 
		INNER JOIN T0030_Branch_Master b WITH (NOLOCK) ON IQ.Branch_ID = b.Branch_ID 
		LEFT OUTER JOIN T0040_Department_Master d WITH (NOLOCK) ON IQ.dept_ID =d.Dept_ID  
		LEFT OUTER JOIN  T0040_TYPE_MASTER t WITH (NOLOCK) ON IQ.Type_ID = t.Type_ID 
		LEFT OUTER JOIN T0040_Designation_Master dgm WITH (NOLOCK) ON IQ.desig_ID =dgm.Desig_ID 
		INNER JOIN  T0010_Company_master AS CM WITH (NOLOCK) ON e.cmp_ID = cm.Cmp_ID 
		LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON VS.Vertical_ID=IQ.vertical_ID 
		LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID=IQ.SubVertical_ID 
		LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON SB.SubBranch_ID=IQ.subBranch_ID
	WHERE --(LT.Leave_Used > 0 OR LT.CompOff_Used > 0) AND
	EG.Cmp_ID = @Cmp_ID
		AND 
		EG.For_date >= @From_Date AND EG.For_date <= @To_date
	--ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500) , EG.For_date
	
	
	
RETURN 

