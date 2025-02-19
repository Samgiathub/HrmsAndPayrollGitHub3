
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_License_Details]
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
																																																																																									---when 0 then 1 end as Month_exp
		;with CTE as(	select Distinct  ROW_NUMBER() OVER(PARTITION BY E.Emp_Full_Name ORDER BY E.Emp_Full_Name) As RowID, E.Emp_ID, E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name, bm.Branch_Name as Branch,dm.Dept_Name as Department,ELD.Lic_Name as License_Name,
						ELD.Lic_For as License_Type,ELD.Lic_Number as License_Number, ELD.Lic_St_Date as Issue_Date,ELD.Lic_End_Date as Expired_Date,
						ELD.Lic_Comments as Comments,case when ELD.Is_Expired = 1 then 'Yes' else 'No' end as Expired 
					from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			( select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf  from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 11092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  INNER JOIN
						( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1	WITH (NOLOCK) --Ankit 27092014
							WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
						) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE  LEFT OUTER JOIN 
					dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
					dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID   Left outer join 
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on E.Dept_ID = DM.Dept_Id Inner join
					V0090_Emp_License_Detail_Get ELD on ELD.Emp_ID = E.Emp_ID Inner Join
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

		WHERE E.Cmp_ID = @Cmp_Id	
		 )
		
SELECT  case when RowID =1 then Emp_Code else '' end as Emp_Code,
Case When RowID = 1 then Employee_Name else '' end as Employee_Name,
Case When RowID = 1 then Branch else '' end as Branch,
Case When RowID = 1 then Department else '' end as Department,License_Name,License_Type,License_Number,Issue_Date,Expired_Date,Comments,Expired
FROM CTE  order by emp_id

	RETURN


