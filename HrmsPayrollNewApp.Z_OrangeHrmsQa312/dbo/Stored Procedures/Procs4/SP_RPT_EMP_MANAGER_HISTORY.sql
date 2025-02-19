


-- Developed By Muslim 16042014

CREATE PROCEDURE [dbo].[SP_RPT_EMP_MANAGER_HISTORY]
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
	
	
		   DECLARE @Show_Left_Employee_for_Salary AS TINYINT
  SET @Show_Left_Employee_for_Salary = 0

  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'

	
	CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
 
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else if @New_Join_emp = 1 
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
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			Order by Emp_ID
						
			Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				Where  Increment_effective_Date <= @to_date Group by emp_ID)

		end
	else if @Left_Emp = 1 
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
						
			Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				Where  Increment_effective_Date <= @to_date Group by emp_ID)
		end		
	else 
		begin

			
			Insert Into #Emp_Cons      
		      select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
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
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)	
		end
	
	-- First Table for Get 1st Record of Table with R_ID
		select ROW_NUMBER() OVER (PARTITION BY Alpha_EMP_CODE ORDER BY ALPHA_EMP_CODE) As R_ID , ERH.*, EMS.Alpha_Emp_Code as Emp_Code, EMS.Emp_Full_Name,RPT.MANAGER_CODE,RPT.MANAGER_NAME,EMS.Date_Of_Join into #t4 from dbo.T0080_EMP_MASTER EMS WITH (NOLOCK)  inner join
		(select * from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)) ERH on EMS.Emp_ID = ERH.Emp_id 
		Left outer join ( Select  EMH.row_id, EMS.Alpha_Emp_Code as MANAGER_CODE,EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) 
							Inner join T0090_EMP_REPORTING_DETAIL EMH WITH (NOLOCK) on EMS.Emp_ID = EMH.R_Emp_id  --and EMS.Cmp_ID = EMH.Cmp_id 
						) RPT on RPT.row_id = ERH.Row_id inner join
		#Emp_Cons EC on EMS.Emp_ID = EC.Emp_ID order by Emp_ID,ERH.Row_id 
		

		-- Second Table for Get All Record of Table
		select ERH.*, EMS.Alpha_Emp_Code as Emp_Code, EMS.Emp_Full_Name,RPT.MANAGER_CODE,RPT.MANAGER_NAME,EMS.Date_Of_Join into #t5 from dbo.T0080_EMP_MASTER EMS WITH (NOLOCK)  inner join
		(select * from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)) ERH on EMS.Emp_ID = ERH.Emp_id 
		Left outer join ( Select  EMH.row_id, EMS.Alpha_Emp_Code as MANAGER_CODE,EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) 
							Inner join T0090_EMP_REPORTING_DETAIL EMH WITH (NOLOCK) on EMS.Emp_ID = EMH.R_Emp_id  --and EMS.Cmp_ID = EMH.Cmp_id 
						) RPT on RPT.row_id = ERH.Row_id inner join
		#Emp_Cons EC on EMS.Emp_ID = EC.Emp_ID  order by Emp_ID,ERH.Row_id
	
	
		-- Union of Both Table (For Get First Record Two Times)
		select Row_ID,EMP_ID,R_EMP_ID,CMP_ID,Effect_Date,EMP_CODE,EMP_FULL_NAME,MANAGER_CODE,
			MANAGER_NAME,Date_Of_Join into #t6 from #t5
		--union all
		--select Row_ID,EMP_ID,R_EMP_ID,CMP_ID,Effect_Date,EMP_CODE,EMP_FULL_NAME,MANAGER_CODE,
		--	MANAGER_NAME,Date_Of_Join  from #t4 where R_ID = 1
		
		
		
		 -- Update First Record Report Mangager, Date of Join ,Manager Code,Manager_Name
		
		select ROW_NUMBER() OVER (PARTITION BY EMP_CODE ORDER BY EMP_CODE) As R_ID, * into #final  from #t6   order by Emp_id,Row_id 	
		update #final set R_Emp_id = #final.R_Emp_id, Effect_Date = #final.Date_OF_Join where Emp_id = #final.Emp_id and R_ID = 1
		-- Delete record which  Reporting Manager is not available
		delete from #final  where R_Emp_id = 0
		
	    update #final 
	    set MANAGER_CODE = ( Select  EMS.Alpha_Emp_Code as MANAGER_CODE from  dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) 
							where --EMS.Cmp_ID = #final.Cmp_id and 
							EMS.Emp_ID = #final.R_Emp_id)
		update #final 
		set MANAGER_NAME = ( Select  EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) 
							where-- EMS.Cmp_ID = #final.Cmp_id and 
							EMS.Emp_ID = #final.R_Emp_id)	
		
		select '="' + Emp_Code + '"' as EMP_CODE,Emp_Full_Name as EMPLOYEE_NAME,'="' + MANAGER_CODE + '"' as MANAGER_CODE,MANAGER_NAME,replace(CONVERT(varchar(25),Effect_Date,103),' ','/') as For_Date  from #final order by Emp_id,Effect_Date
		
		--Start----Below Code Comment By Ankit 11022015 After Update Effect Date Reporting Manager--
		
		-- -- First Table for Get 1st Record of Table with R_ID
		--select ROW_NUMBER() OVER (PARTITION BY Alpha_EMP_CODE ORDER BY ALPHA_EMP_CODE) As R_ID , ERH.*, EMS.Alpha_Emp_Code as Emp_Code, EMS.Emp_Full_Name,RPT.MANAGER_CODE,RPT.MANAGER_NAME,EMS.Date_Of_Join into #t4 from dbo.T0080_EMP_MASTER EMS  inner join
		--(select * from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY) ERH on EMS.Emp_ID = ERH.Emp_id 
		--Left outer join ( Select  EMH.row_id, EMS.Alpha_Emp_Code as MANAGER_CODE,EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS  
	 --   Inner join T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY EMH  on EMS.Emp_ID = EMH.New_R_Emp_id  and EMS.Cmp_ID = EMH.Cmp_id ) RPT on RPT.row_id = ERH.Row_id inner join
		--#Emp_Cons EC on EMS.Emp_ID = EC.Emp_ID order by Emp_ID,ERH.Row_id 
		

		---- Second Table for Get All Record of Table
		--select ERH.*, EMS.Alpha_Emp_Code as Emp_Code, EMS.Emp_Full_Name,RPT.MANAGER_CODE,RPT.MANAGER_NAME,EMS.Date_Of_Join into #t5 from dbo.T0080_EMP_MASTER EMS   inner join
		--(select * from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY) ERH on EMS.Emp_ID = ERH.Emp_id 
		--Left outer join ( Select  EMH.row_id, EMS.Alpha_Emp_Code as MANAGER_CODE,EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS  
	 --   Inner join T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY EMH  on EMS.Emp_ID = EMH.New_R_Emp_id  and EMS.Cmp_ID = EMH.Cmp_id ) RPT on RPT.row_id = ERH.Row_id inner join
		--#Emp_Cons EC on EMS.Emp_ID = EC.Emp_ID  order by Emp_ID,ERH.Row_id
		
		---- Union of Both Table (For Get First Record Two Times)
		--select Row_ID,EMP_ID,OLd_R_EMP_ID,NEW_R_EMP_ID,CMP_ID,CHANGE_DATE,EMP_CODE,EMP_FULL_NAME,MANAGER_CODE,MANAGER_NAME,Date_Of_Join into #t6 from #t5
		--union all
		--select Row_ID,EMP_ID,OLd_R_EMP_ID,NEW_R_EMP_ID,CMP_ID,CHANGE_DATE,EMP_CODE,EMP_FULL_NAME,MANAGER_CODE,MANAGER_NAME,Date_Of_Join  from #t4 where R_ID = 1
		
		
		-- -- Update First Record Report Mangager, Date of Join ,Manager Code,Manager_Name
		
		--select ROW_NUMBER() OVER (PARTITION BY EMP_CODE ORDER BY EMP_CODE) As R_ID, * into #final  from #t6   order by Emp_id,Row_id 	
		--update #final set New_R_Emp_id = #final.Old_R_Emp_id, Change_Date = #final.Date_OF_Join where Emp_id = #final.Emp_id and R_ID = 1
		---- Delete record which  Reporting Manager is not available
		--delete from #final  where New_R_Emp_id = 0
		
	 --   update #final set MANAGER_CODE = ( Select  EMS.Alpha_Emp_Code as MANAGER_CODE from  dbo.T0080_EMP_MASTER EMS  where EMS.Cmp_ID = #final.Cmp_id and EMS.Emp_ID = #final.New_R_Emp_id)
		--update #final set MANAGER_NAME = ( Select  EMS.Emp_Full_Name as MANAGER_NAME from  dbo.T0080_EMP_MASTER EMS  where EMS.Cmp_ID = #final.Cmp_id and EMS.Emp_ID = #final.New_R_Emp_id)	
		
		--select '="' + Emp_Code + '"' as EMP_CODE,Emp_Full_Name as EMPLOYEE_NAME,'="' + MANAGER_CODE + '"' as MANAGER_CODE,MANAGER_NAME,replace(CONVERT(varchar(25),Change_date,103),' ','/') as For_Date  from #final order by Emp_id,Change_date
		
	--;with CTE as(
	--		 select ROW_NUMBER() OVER (PARTITION BY EMP_CODE ORDER BY EMP_CODE,R_ID) As Final_ID,Emp_ID,Emp_Code as EMP_CODE,Emp_Full_Name as EMPLOYEE_NAME ,MANAGER_CODE,MANAGER_NAME,Change_date as Join_date from #final		
	--	)	
	
																																																																														
	--select case when  Final_ID = 1 then '="' + EMP_CODE + '"' else '' end as Emp_Code,
	--	   case when  Final_ID = 1 then EMPLOYEE_NAME else '' end as EMPLOYEE_NAME,
	--	    '="' + MANAGER_CODE + '"' as MANAGER_CODE,MANAGER_NAME,replace(CONVERT(varchar(25),Join_Date,103),' ','/') as Join_Date from CTE  Order By Emp_id
	--Start----Below Code Comment By Ankit 11022015 After Update Effect Date Reporting Manager--
		
	RETURN


