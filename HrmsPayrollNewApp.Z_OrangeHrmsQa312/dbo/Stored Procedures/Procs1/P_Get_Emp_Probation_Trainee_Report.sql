

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Get_Emp_Probation_Trainee_Report]
@Cmp_ID numeric,
@Probation_Evaluation_ID numeric,
@flag varchar(15),
@Type varchar(15)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	DECLARE @TYPE_Value as NUMERIC
	DECLARE @Training_Id as varchar(250)=''
	DECLARE @Desig_Id as NUMERIC
	DECLARE @Max_rate as NUMERIC
	DECLARE @Dept_Id AS INT
	DECLARE @setting_value AS INT
	
	IF @flag = 'Trainee'
		set @TYPE_Value=1
	ELSE
		set @TYPE_Value=0
	
	CREATE table #Training_det
	(
		Probation_Evaluation_ID NUMERIC,
		Training_name varchar(250)
	)
	SELECT @setting_value=setting_value from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@cmp_id and Setting_Name='Enable Probation/Trainee Assessment With Score'
	PRINT @setting_value
	if @Type='Admin'
		BEGIN		
			select @Training_Id=Training_ID,@Desig_Id=Desig_Id,@Dept_Id=Dept_ID from VIEW_TRAINEE_PROBATION_APPROVAL where Cmp_ID=@Cmp_ID and Probation_Evaluation_ID=@Probation_Evaluation_ID and Flag=@flag		
			select TP.*,co.Cmp_Name,co.Cmp_Address,PM.Major_Strength AS [Self_Strength] from VIEW_TRAINEE_PROBATION_APPROVAL TP
			inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on TP.cmp_id=co.cmp_id
			left join T0115_EMP_PROBATION_MASTER_LEVEL PM WITH (NOLOCK) ON PM.Probation_Evaluation_ID=TP.Probation_Evaluation_ID AND PM.Is_Self_Rating=1
			where TP.Cmp_ID=@Cmp_ID and TP.Probation_Evaluation_ID=@Probation_Evaluation_ID and TP.Flag=@flag
			
			if @Training_Id <> ''	
				BEGIN
					insert into #Training_det 
					SELECT @Probation_Evaluation_ID,Training_name 
						--INTO #Training_det
						FROM   T0040_Hrms_Training_master WITH (NOLOCK) 
					WHERE  Training_id IN(select  cast(data  as numeric) from dbo.Split (@Training_Id,'#') WHERE DATA <> '')
				END
				
			select * from #Training_det
			
			--SELECT EP.*,AM.Attribute_Name FROM T0100_EMP_PROBATION_ATTRIBUTE_DETAIL EP
			--INNER JOIN T0040_ATTRIBUTE_MASTER AM ON AM.Attribute_ID = EP.Attribute_ID 
			--WHERE Emp_Prob_ID=@Probation_Evaluation_ID  
			
			--SELECT EP.*,SM.Skill_Name FROM T0100_EMP_PROBATION_SKILL_DETAIL EP
			--INNER JOIN T0040_SKILL_MASTER SM ON SM.Skill_ID = EP.Skill_ID 
			--WHERE Emp_Prob_ID=@Probation_Evaluation_ID  
			-- DECLARE @Emp_ID as INT
			-- CREATE TABLE #Scheme_Table
			--(
			--	Emp_id		NUMERIC		DEFAULT 0,		
			--	Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
			--	Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
			--	Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
			--	Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
			--	Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
			--	Max_Level	int	
			--)		
			
			--CREATE TABLE #Lable
			--(
			--Def_ID INT,
			--Lable_name VARCHAR(MAX),
			--Emp_Id INT,
			--Employee_Rating	Varchar(500) DEFAULT NUll,
			--Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
			--Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
			--Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
			--Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
			--Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
			--)
			
			--DECLARE @From_date	DATETIME 
			--SET @From_date = GETDATE()	
			--set @Emp_ID=15626
			
			--INSERT INTO #Scheme_Table
			--exec SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_date,@To_Date=@From_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@Constraint=@Emp_Id,@Report_Type = @flag
			
			----INSERT INTO #Lable(Def_ID,Lable_name,Emp_Id)
			----SELECT 0, 'Employee Record',@Emp_ID
			
			----SELECT * FROM #Lable
			----SELECT * FROM #Scheme_Table
				
			--UPDATE #Lable
			--SET	Employee_Rating ='Self Rating',
			--	Rpt_Mgr_1  = ST.Rpt_Mgr_1,
			--	Rpt_Mgr_2  = ST.Rpt_Mgr_2,
			--	Rpt_Mgr_3  = ST.Rpt_Mgr_3,
			--	Rpt_Mgr_4  = ST.Rpt_Mgr_4,
			--	Rpt_Mgr_5  = ST.Rpt_Mgr_5
			--FROM #Lable L INNER JOIN #Scheme_Table ST ON L.Emp_id = ST.Emp_id
			--WHERE L.Lable_name = 'Employee Record'
						
			--SELECT DISTINCT Rpt_Level,EP.Tran_Id,ESD.Skill_ID,ESD.Skill_Rating INTO #Prob_Level FROM T0115_EMP_PROBATION_MASTER_LEVEL EP
			--INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL ESD ON EP.Tran_Id=ESD.Tran_ID 
			--where Probation_Evaluation_ID=@Probation_Evaluation_ID						
			
			SELECT @Max_rate=Max(To_Rate)  FROM T0040_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID   		
			PRINT @setting_value
			--	SELECT @Desig_Id,@Dept_Id         
			IF @setting_value=1
				BEGIN		                                                         
					SELECT DISTINCT SW.Skill_ID,SM.Skill_Name,SW.Weightage,ESD.Emp_Prob_ID,ESD.Skill_Rating,ESD.Emp_ID,
					((SW.Weightage/@Max_rate)*ESD.Skill_Rating)as skill_total,ES.Skill_Weightage,ESD.Strengths,ESD.Other_Factors,ESD.Remarks,
					EL1.Skill_Rating AS m1			 
					FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						INNER JOIN 
						(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
						((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and 
						[TYPE]=@TYPE_Value) Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM  WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						INNER JOIN T0100_EMP_PROBATION_SKILL_DETAIL ESD WITH (NOLOCK) ON ESD.Skill_ID=SM.Skill_ID 
						INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EL WITH (NOLOCK) ON ESD.Emp_Prob_ID=el.Probation_Evaluation_ID
						INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EL1 WITH (NOLOCK) ON EL1.Skill_ID=SM.Skill_ID AND EL1.Tran_ID=EL.Tran_Id
					WHERE ES.Cmp_ID = @Cmp_ID AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value AND ESD.Emp_Prob_ID=@Probation_Evaluation_ID
					Order By Skill_Name ASC
					
					
				END
			ELSE
				BEGIN
				PRINT 'KK'                                  
					SELECT DISTINCT SW.Skill_ID,SM.Skill_Name,SW.Weightage,ESD.Emp_Prob_ID,ESD.Skill_Rating,ESD.Emp_ID,
					RM.Title,ES.Skill_Weightage,ESD.Strengths,ESD.Other_Factors,ESD.Remarks,0 as skill_total			 
					FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						INNER JOIN 
						(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
						((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and 
						[TYPE]=@TYPE_Value) Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						INNER JOIN T0100_EMP_PROBATION_SKILL_DETAIL ESD WITH (NOLOCK) ON ESD.Skill_ID=SM.Skill_ID 
						--left join T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL ED1 ON ED1.Tran_ID=ESD.Prob_Skill_ID
						INNER JOIN T0040_RATING_MASTER RM WITH (NOLOCK) ON RM.Rating_ID=ESD.Skill_Rating
					WHERE ES.Cmp_ID = @Cmp_ID AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value AND ESD.Emp_Prob_ID=@Probation_Evaluation_ID
					Order By Skill_Name ASC
					
					--SELECT DISTINCT SW.Skill_ID,SM.Skill_Name,SW.Weightage,EML.Probation_Evaluation_ID AS Emp_Prob_ID,ED1.Skill_Rating,ED1.Emp_ID,
					--RM.Title,ES.Skill_Weightage,ED1.Strengths,ED1.Other_Factors,ED1.Remarks,0 as skill_total,ED1.Row_ID			 
					--FROM T0100_EMP_Skill_Attr_Assign ES 
					--	INNER JOIN 
					--	(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WHERE Cmp_ID = @Cmp_ID AND 
					--	((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and 
					--	[TYPE]=@TYPE_Value) Qry ON Es.Effect_Date = Qry.Effect_date 
					--	INNER JOIN T0110_SKILL_WEIGHTAGE SW ON ES.Tran_ID = SW.Tran_Id 
					--	INNER JOIN T0040_SKILL_MASTER SM ON SM.Skill_ID = SW.Skill_ID 
					--	--INNER JOIN T0100_EMP_PROBATION_SKILL_DETAIL ESD ON ESD.Skill_ID=SM.Skill_ID 
					--	LEFT JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL ED1 ON ED1.Skill_ID=SM.Skill_ID
					--	INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EML ON EML.Emp_id=ED1.Emp_Id AND ED1.Tran_ID=EML.Tran_Id
					--	INNER JOIN T0040_RATING_MASTER RM ON RM.Rating_ID=ED1.Skill_Rating
					--WHERE ES.Cmp_ID = @Cmp_ID AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id)
					--OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value AND 
					--EML.Probation_Evaluation_ID=@Probation_Evaluation_ID
					--Order By ED1.Row_ID ASC
				END
				
				
			SELECT DISTINCT AW.Attr_Id As Attribute_ID,AM.Attribute_Name,AW.Weightage,EAD.Attr_Rating,EAD.Emp_Prob_ID,EAD.Emp_ID, 
			((AW.Weightage/@Max_rate)*EAD.Attr_Rating)as attribute_total,ES.Attr_Weightage 
			FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
				INNER JOIN
				(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id))and [TYPE]=@TYPE_Value) Qry 
				ON Es.Effect_Date = Qry.Effect_date 
				INNER JOIN T0110_Attribute_Weightage AW WITH (NOLOCK) ON ES.Tran_ID = AW.Tran_Id 
				INNER JOIN T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) ON AM.Attribute_ID = AW.Attr_Id 
				INNER JOIN T0100_EMP_PROBATION_ATTRIBUTE_DETAIL EAD WITH (NOLOCK) ON EAD.Attribute_ID=AM.Attribute_ID 
			WHERE ES.Cmp_ID = @Cmp_ID AND EAD.Emp_Prob_ID=@Probation_Evaluation_ID
			AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value Order By Attribute_Name ASC
		END
	ELSE
		BEGIN	
			IF @flag = 'Trainee'
				BEGIN
					select @Training_Id=Training_ID,@Desig_Id=Desig_Id,@Dept_Id=Dept_Id from VIEW_TRAINEE_FINAL_N_LEVEL_APPROVAL 
					where Cmp_ID=@Cmp_ID and Tran_Id=@Probation_Evaluation_ID 	
					
					select TP.*,TP.Tran_Id as Probation_Evaluation_ID,co.Cmp_Name,co.Cmp_Address,'Trainee' as flag,
					'' as Review_By,'' as [Self_Strength] from VIEW_TRAINEE_FINAL_N_LEVEL_APPROVAL TP
					inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on TP.cmp_id=co.cmp_id
					where TP.Cmp_ID=@Cmp_ID and TP.Tran_Id=@Probation_Evaluation_ID 
				END
			ELSE
				BEGIN
					select @Training_Id=Training_ID,@Desig_Id=Desig_Id,@Dept_Id=Dept_Id from VIEW_PROBATION_FINAL_N_LEVEL_APPROVAL 
					where Cmp_ID=@Cmp_ID and Tran_Id=@Probation_Evaluation_ID	
					
					select TP.*,TP.Tran_Id as Probation_Evaluation_ID,co.Cmp_Name,co.Cmp_Address,'Probation' as flag,
					'' as Review_By,'' as [Self_Strength] from VIEW_PROBATION_FINAL_N_LEVEL_APPROVAL TP
					inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on TP.cmp_id=co.cmp_id
					where TP.Cmp_ID=@Cmp_ID and TP.Tran_Id=@Probation_Evaluation_ID 
				END
				PRINT @Desig_Id	
			if @Training_Id <> ''	
				BEGIN
					insert into #Training_det 
					SELECT @Probation_Evaluation_ID,Training_name 
						--INTO #Training_det
						FROM   T0040_Hrms_Training_master WITH (NOLOCK)
					WHERE  Training_id IN(select  cast(data  as numeric) from dbo.Split (@Training_Id,'#')WHERE DATA <> '')
				END
				
			select * from #Training_det
			
			IF @setting_value=1				
				BEGIN
					SELECT @Max_rate=Max(To_Rate)  FROM T0040_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID                                                                      
					SELECT DISTINCT SW.Skill_ID,SM.Skill_Name,SW.Weightage,ESD.Tran_ID as Emp_Prob_ID,ESD.Skill_Rating,ESD.Emp_ID,
					((SW.Weightage/@Max_rate)*ESD.Skill_Rating)as skill_total,ES.Skill_Weightage,ESD.Strengths,ESD.Other_Factors,ESD.Remarks 
					FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK) 
						INNER JOIN 
						(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
						 AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and 
						[TYPE]=@TYPE_Value) Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL ESD WITH (NOLOCK) ON ESD.Skill_ID=SM.Skill_ID 
					WHERE ES.Cmp_ID = @Cmp_ID AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value AND ESD.Tran_ID=@Probation_Evaluation_ID
					Order By Skill_Name ASC
				END	 
			ELSE
				BEGIN	
				print 'nn'
					SELECT @Max_rate=Max(To_Rate)  FROM T0040_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID                                                                      
					SELECT DISTINCT SW.Skill_ID,SM.Skill_Name,SW.Weightage,ESD.Tran_ID as Emp_Prob_ID,ESD.Skill_Rating,ESD.Emp_ID,
					0 as skill_total,RM.Title,ES.Skill_Weightage,ESD.Strengths,ESD.Other_Factors,ESD.Remarks 
					FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						INNER JOIN 
						(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)  WHERE Cmp_ID = @Cmp_ID
						 AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and 
						[TYPE]=@TYPE_Value) Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL ESD WITH (NOLOCK) ON ESD.Skill_ID=SM.Skill_ID 
						INNER JOIN T0040_RATING_MASTER RM WITH (NOLOCK) ON RM.Rating_ID=ESD.Skill_Rating
					WHERE ES.Cmp_ID = @Cmp_ID AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value AND ESD.Tran_ID=@Probation_Evaluation_ID
					Order By Skill_Name ASC							
				END
				
			SELECT DISTINCT AW.Attr_Id As Attribute_ID,AM.Attribute_Name,AW.Weightage,EAD.Attr_Rating,EAD.Tran_ID as Emp_Prob_ID,EAD.Emp_ID, 
			((AW.Weightage/@Max_rate)*EAD.Attr_Rating)as attribute_total,ES.Attr_Weightage 
			FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
				INNER JOIN
				(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id))
				and [TYPE]=@TYPE_Value) Qry 
				ON Es.Effect_Date = Qry.Effect_date 
				INNER JOIN T0110_Attribute_Weightage AW WITH (NOLOCK) ON ES.Tran_ID = AW.Tran_Id 
				INNER JOIN T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) ON AM.Attribute_ID = AW.Attr_Id 
				INNER JOIN T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL EAD WITH (NOLOCK) ON EAD.Attribute_ID=AM.Attribute_ID 
			WHERE ES.Cmp_ID = @Cmp_ID AND EAD.Tran_ID=@Probation_Evaluation_ID
			AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@TYPE_Value Order By Attribute_Name ASC
		END
		
		--IF @flag = 'Trainee'
		--	BEGIN
		--		SELECT @Scheme_ID=Scheme_ID FROM T0095_EMP_SCHEME WHERE [Type]='Trainee' AND Emp_ID=@EMP_ID
		--	END
		--ELSE
		--	BEGIN
		--		SELECT @Scheme_ID=Scheme_ID FROM T0095_EMP_SCHEME WHERE [Type]='Probation' AND Emp_ID=@EMP_ID
		--	END	
		--IF EXISTS(SELECT 1 from T0115_EMP_PROBATION_MASTER_LEVEL WHERE  Probation_Evaluation_ID=@Probation_Evaluation_ID and Cmp_id=@cmp_id)
		--BEGIN
		IF @Type='Admin'
			BEGIN		
				SELECT PM.Probation_Evaluation_ID,EM.Emp_ID,S_Emp_ID,[Status],(EM.Alpha_Emp_Code +'-'+EM.Emp_Full_Name)Manager_Name,PM.Rpt_Level,Evaluation_Date				 
				FROM T0115_EMP_PROBATION_MASTER_LEVEL PM WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON PM.S_Emp_ID=EM.Emp_ID AND EM.Cmp_ID=PM.Cmp_id
				WHERE  Probation_Evaluation_ID=@Probation_Evaluation_ID and pm.Cmp_id=@cmp_id		
			END
		ELSE
			--BEGIN		
			--	IF @flag = 'Trainee'
			--		BEGIN
			--			SELECT PM.Probation_Evaluation_ID,EM.Emp_ID,S_Emp_ID,[Status],(EM.Alpha_Emp_Code +'-'+EM.Emp_Full_Name)Manager_Name,PM.Rpt_Level,Evaluation_Date 
			--			FROM T0115_EMP_PROBATION_MASTER_LEVEL PM 
			--			INNER JOIN T0080_EMP_MASTER EM ON PM.S_Emp_ID=EM.Emp_ID AND EM.Cmp_ID=PM.Cmp_id
			--			WHERE  PM.Tran_Id=@Probation_Evaluation_ID and pm.Cmp_id=@cmp_id		
			--		END
			--	ELSE
					BEGIN
						SELECT PM.Probation_Evaluation_ID,EM.Emp_ID,S_Emp_ID,[Status],(EM.Alpha_Emp_Code +'-'+EM.Emp_Full_Name)Manager_Name,PM.Rpt_Level,Evaluation_Date 
						FROM T0115_EMP_PROBATION_MASTER_LEVEL PM WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON PM.S_Emp_ID=EM.Emp_ID AND EM.Cmp_ID=PM.Cmp_id
						WHERE  PM.Tran_Id=@Probation_Evaluation_ID and pm.Cmp_id=@cmp_id		
					END
			--END
			
END
