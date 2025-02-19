

-- Developed By Muslim 02042014
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_Reference_Details]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		
	,@Vertical_Id numeric = 0		
	,@SubVertical_Id numeric = 0	 
	,@SubBranch_Id numeric = 0
	,@Reference_Status VARCHAR(64) = 'Default'
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id =NULL

	if @Branch_ID = 0
		set @Branch_ID = null
		
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
		
	if @Dept_ID = 0
		set @Dept_ID = null
		
	if @Grd_ID = 0
		set @Grd_ID = null
		
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	
	If @Segment_Id = 0		 
		set @Segment_Id = null
	
	If @Vertical_Id = 0		 
		set @Vertical_Id = null
	
	If @SubVertical_Id = 0	 
		set @SubVertical_Id = null	
	
	If @SubBranch_Id = 0	 
		set @SubBranch_Id = null	
	
	if @Reference_Status = ''
		set @Reference_Status = 'Default'
		
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )      
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',@New_Join_emp,@Left_Emp,0,'0',0,0               
   

	/*
	 CODE COMMENTED BY RAMIZ ON 26/11/2018 AND ADDED NEW LOGIC
		
	  DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	  SET @Show_Left_Employee_for_Salary = 0

	  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
	  FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
  
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) 
			FROM dbo.Split(@Constraint,'#')
		END
	ELSE IF @New_Join_emp = 1 
		BEGIN
			Insert Into #Emp_Cons      
			Select distinct emp_id,branch_id,Increment_ID 
			From V_Emp_Cons Where Cmp_id=@Cmp_ID 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			Order by Emp_ID
						
			Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
				Where  Increment_effective_Date <= @to_date Group by emp_ID)
		END
	ELSE IF @Left_Emp = 1 
		begin

			Insert Into #Emp_Cons      
			Select distinct emp_id,branch_id,Increment_ID 
			From V_Emp_Cons Where Cmp_id=@Cmp_ID 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))			
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))		 
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Left_date >=@From_Date and Left_Date <=@to_Date
			Order by Emp_ID
						
			Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
				Where  Increment_effective_Date <= @to_date Group by emp_ID)
		end		
	else 
		begin
		
	        	Insert Into #Emp_Cons      
		        select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
		  where 
		     cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
		   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       
		   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
		   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  
		   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )
						OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						) 
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
				where  Increment_effective_Date <= @to_date
				group by emp_ID)	
		end
		
		;WITH CTE AS
			(SELECT DISTINCT  ROW_NUMBER() OVER(PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name) As RowID, E.Emp_ID, E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name, 
			 bm.Branch_Name as Branch,dm.Dept_Name as Department,REPLACE(CONVERT(VARCHAR(11),E.Date_Of_Join,103), ' ','/') as Join_Date,
			 STM.Source_Type_Name as Source_Type,(CASE WHEN Source_Type_Name = 'Employee Referral' THEN '' else ST.Source_Name END) as Source_Name,
			 CASE WHEN RD.R_EMP_ID is not null then EM.Alpha_Emp_Code else '' end as Ref_Given_Code,CASE WHEN RD.R_EMP_ID is not null then Em.Emp_full_Name else '' end as Ref_Given_By,
			 REPLACE(CONVERT(VARCHAR(11),RD.For_Date,103), ' ','/') as Payment_Date,RD.Ref_Description as Ref_Description, RD.Amount,RD.Comments as Comments, Rd.Contact_Person as Ref_Contact_Person,
			 case when RD.Mobile = '0' then '' else RD.Mobile end as Ref_Contact_Number,RD.City,RD.Designation,
				(
					CASE WHEN Isnull(Ref_Month,0) <> 0 THEN LEFT(DATENAME(MONTH,'2015-'+ Cast(Ref_Month AS varchar(100)) +'-01'),3)  +'-'+ Cast(Ref_Year AS varchar(100)) else ' ' END) as Payment_Month_Year
					FROM dbo.T0080_EMP_MASTER E 
					LEFT OUTER JOIN dbo.T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID 
					INNER JOIN
						(
							SELECT  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf 
							FROM dbo.T0095_Increment I 
							INNER JOIN 
								( 
									select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	-- Ankit 11092014 for Same Date Increment
									where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
									group by emp_ID  
								) Qry on I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
						) I_Q ON E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN dbo.T0040_GENERAL_SETTING GS on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  
					INNER JOIN
							( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1	--Ankit 27092014
								WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
							) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE  
					LEFT OUTER JOIN dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID
					INNER JOIN		dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID   
					LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM on E.Dept_ID = DM.Dept_Id 
					LEFT JOIN		dbo.T0090_EMP_REFERENCE_DETAIL RD on I_Q.Emp_ID = RD.Emp_ID
					LEFT OUTER JOIN dbo.t0030_source_type_master  STM on  RD.Source_Type = STM.Source_Type_Id 
					LEFT JOIN		dbo.t0040_source_master ST on STM.Source_Type_Id  = RD.Source_Type and RD.Source_Name =  ST.Source_Id
					INNER JOIN		#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
					LEFT OUTER JOIN 
						(
							SELECT EM.Emp_ID,EM.Emp_Full_Name, EM.Alpha_Emp_Code from dbo.T0080_EMP_MASTER EM 						
						)	EM ON EM.Emp_ID = RD.R_EMP_ID

			WHERE E.Cmp_ID = @Cmp_Id	
			 )

	*/	
																																																																																									
			;WITH CTE AS
				(
					SELECT DISTINCT  ROW_NUMBER() OVER(PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name) As RowID, E.Emp_ID, E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name, 
						bm.Branch_Name as Branch,dm.Dept_Name as Department,REPLACE(CONVERT(VARCHAR(11),E.Date_Of_Join,103), ' ','/') as Join_Date,
						STM.Source_Type_Name as Source_Type,(CASE WHEN Source_Type_Name = 'Employee Referral' THEN '' else ST.Source_Name END) as Source_Name,
						CASE WHEN RD.R_EMP_ID is not null then EM.Alpha_Emp_Code else '' end as Ref_Given_Code,CASE WHEN RD.R_EMP_ID is not null then Em.Emp_full_Name else '' end as Ref_Given_By,
						REPLACE(CONVERT(VARCHAR(11),RD.For_Date,103), ' ','/') as Payment_Date,RD.Ref_Description as Ref_Description, RD.Amount,RD.Comments as Comments, Rd.Contact_Person as Ref_Contact_Person,
						CASE WHEN RD.Mobile = '0' then '' else RD.Mobile end as Ref_Contact_Number,RD.City,RD.Designation,
						CASE WHEN Isnull(Ref_Month,0) <> 0 THEN LEFT(DATENAME(MONTH,'2015-'+ Cast(Ref_Month AS varchar(100)) +'-01'),3)  +'-'+ Cast(Ref_Year AS varchar(100)) else ' ' END as Payment_Month_Year,
						vs.Vertical_Name , sv.SubVertical_Name , BS.Segment_Name	--Added By Ramiz on 19/06/2018
					FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK)
						INNER JOIN		#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
						INNER JOIN		dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Emp_ID = ec.Emp_ID AND I_Q.Increment_ID = ec.Increment_ID 
						LEFT OUTER JOIN dbo.T0100_LEFT_EMP L WITH (NOLOCK) ON E.Emp_ID =  L.Emp_ID 
						LEFT OUTER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
						INNER JOIN		dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID   
						LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id 
						LEFT JOIN		dbo.T0090_EMP_REFERENCE_DETAIL RD WITH (NOLOCK) on I_Q.Emp_ID = RD.Emp_ID
						LEFT OUTER JOIN dbo.T0030_SOURCE_TYPE_MASTER  STM WITH (NOLOCK) on  RD.Source_Type = STM.Source_Type_Id 
						LEFT JOIN		dbo.T0040_SOURCE_MASTER ST WITH (NOLOCK) on STM.Source_Type_Id  = RD.Source_Type and RD.Source_Name =  ST.Source_Id
						LEFT OUTER JOIN dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.R_EMP_ID --AND EM.CMP_ID = RD.CMP_ID
						LEFT OUTER JOIN dbo.T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID and I_Q.Cmp_ID = VS.Cmp_ID
						LEFT OUTER JOIN dbo.T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID and I_Q.Cmp_ID = SV.Cmp_ID
						LEFT OUTER JOIN dbo.T0040_Business_Segment BS WITH (NOLOCK) ON I_Q.Segment_ID = BS.Segment_ID AND I_Q.Cmp_ID = BS.Cmp_ID
				 )
			
			--AS THE SAME TABLE WILL BE USED IN 3 DIFFERENT CASES , TAKING THE SAME IN TEMP TABLE.
			SELECT * INTO #CTE FROM CTE
	
		IF @Reference_Status = 'Default'
			BEGIN
				SELECT  
				CASE WHEN RowID = 1 THEN Emp_Code ELSE '' END AS Emp_Code,
				CASE WHEN RowID = 1 THEN Employee_Name ELSE '' END AS Employee_Name,
				CASE WHEN RowID = 1 THEN Branch ELSE '' END AS Branch,
				CASE WHEN RowID = 1 THEN Department ELSE '' END AS Department,
				CASE WHEN RowID = 1 THEN Join_Date ELSE '' END AS Join_Date,
				CASE WHEN RowID = 1 THEN Vertical_Name ELSE '' END AS Vertical_Name,
				CASE WHEN RowID = 1 THEN SubVertical_Name ELSE '' END AS SubVertical_Name,
				CASE WHEN RowID = 1 THEN Segment_Name ELSE '' END AS Segment_Name,
				Source_Type, Source_Name,Ref_Given_Code,Ref_Given_By,Ref_Description,
				Amount,Payment_Date as Reference_Date,Comments,Designation,Ref_Contact_Person,
				Ref_Contact_Number,City,Payment_Month_Year
				FROM #CTE  
				ORDER BY EMP_ID
			END
		ELSE IF @Reference_Status = 'Left Reference' --IF ALL REFERENCE OF AN EMPLOYEE ARE LEFT , THEN IT WILL BE LISTED IN THIS LIST
			BEGIN
				
				/* NEW LOGIC BASED ON EMP_CODE AS EMP_ID LOGIC WAS NOT WORKING IN COMPANY TRANSFER CASE */
				SELECT 
					CASE WHEN RowID = 1 THEN CTE1.Emp_Code ELSE '' END AS Emp_Code,
					CASE WHEN RowID = 1 THEN Employee_Name ELSE '' END AS Employee_Name,
					CASE WHEN RowID = 1 THEN Branch ELSE '' END AS Branch,
					CASE WHEN RowID = 1 THEN Department ELSE '' END AS Department,
					CASE WHEN RowID = 1 THEN Join_Date ELSE '' END AS Join_Date,
					CASE WHEN RowID = 1 THEN Vertical_Name ELSE '' END AS Vertical_Name,
					CASE WHEN RowID = 1 THEN SubVertical_Name ELSE '' END AS SubVertical_Name,
					CASE WHEN RowID = 1 THEN Segment_Name ELSE '' END AS Segment_Name,
					Source_Type, Source_Name,Ref_Given_Code,Ref_Given_By,Ref_Description,
					Amount,Payment_Date as Reference_Date,Comments,Designation,Ref_Contact_Person,
					Ref_Contact_Number,City,Payment_Month_Year
				FROM #CTE CTE1
				INNER JOIN
					(
						SELECT  C.Emp_Code , COUNT(C.Emp_Code) AS Total_Rows , 
								SUM(CASE EM.Emp_Left WHEN 'Y' THEN 1 ELSE 0 END) Employee_Left
						FROM #CTE C
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON C.Ref_Given_Code = EM.Alpha_Emp_Code
						GROUP BY C.Emp_Code
					)T ON T.Emp_Code = CTE1.Emp_Code
				WHERE T.Total_Rows = T.Employee_Left
				ORDER BY CTE1.EMP_ID
			END
		ELSE IF @Reference_Status = 'No Reference' --IF REFERENCE ARE NOT ADDED
			BEGIN
				
				SELECT  
				CASE WHEN RowID = 1 THEN Emp_Code ELSE '' END AS Emp_Code,
				CASE WHEN RowID = 1 THEN Employee_Name ELSE '' END AS Employee_Name,
				CASE WHEN RowID = 1 THEN Branch ELSE '' END AS Branch,
				CASE WHEN RowID = 1 THEN Department ELSE '' END AS Department,
				CASE WHEN RowID = 1 THEN Join_Date ELSE '' END AS Join_Date,
				CASE WHEN RowID = 1 THEN Vertical_Name ELSE '' END AS Vertical_Name,
				CASE WHEN RowID = 1 THEN SubVertical_Name ELSE '' END AS SubVertical_Name,
				CASE WHEN RowID = 1 THEN Segment_Name ELSE '' END AS Segment_Name,
				Source_Type, Source_Name,Ref_Given_Code,Ref_Given_By,Ref_Description,
				Amount,Payment_Date as Reference_Date,Comments,Designation,Ref_Contact_Person,
				Ref_Contact_Number,City,Payment_Month_Year
				FROM #CTE
				WHERE Source_Type IS NULL
				ORDER BY EMP_ID
				
			END
			
	RETURN




