


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_PF_Statement]
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
						
			Delete From #Emp_Cons Where Increment_ID Not In
			(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
			(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
			Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
			Where Increment_effective_Date <= @to_date) 

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
						
			Delete From #Emp_Cons Where Increment_ID Not In
			(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
			(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
			Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
			Where Increment_effective_Date <= @to_date) 
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
						
				Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date) 
		end
																																																																																									---when 0 then 1 end as Month_exp
			select Distinct E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name, bm.Branch_Name as Branch, 
					case when PFS.AD_DEF_ID = 2 or PFS2.AD_DEF_ID = 2 or PFS3.AD_DEF_ID = 2 then  
							case when PFS.AD_ACTIVE = 1 or PFS2.AD_ACTIVE = 1 or PFS3.AD_ACTIVE = 1 then 
							'Y' 
							else 
							'N' 
							end
					else
							'N'  
					end as PF,
					case when PFS.AD_DEF_ID = 5  or PFS2.AD_DEF_ID = 5 or PFS3.AD_DEF_ID = 5 then  
								case when PFS.AD_ACTIVE = 1 or  PFS2.AD_ACTIVE = 1 or PFS3.AD_ACTIVE = 1 then 
								'Y' 
								else 
								'N' 
								end  
					else
							'N' 
							end as CPF,
					case when I_Q.Emp_Full_PF = 1 then 'Y' else 'N' end as Full_PF,
					case when I_Q.Emp_Auto_Vpf = 1 then 'Y' else 'N' end as Full_CPF,
					case when PFS.AD_DEF_ID = 4 or PFS2.AD_DEF_ID = 4 or PFS3.AD_DEF_ID = 4  then  
								case when PFS.AD_ACTIVE = 1 or PFS2.AD_ACTIVE = 1 or PFS3.AD_ACTIVE = 1  then 
								'Y' 
								else 
								'N' 
								end
					else
							'N'   
							end as VPF
					from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			( select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf  from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 11092014 for Same Date Increment
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
					dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Left Outer Join
					
					( select  Meed.Emp_Id,IED.AD_ID,Meed.AD_ACTIVE,Meed.AD_DEF_ID,Meed.AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION IED WITH (NOLOCK) inner join 
					( select Sub_IED.ad_id,max(FOR_DATE) as For_Date ,Sub_IED.Emp_ID,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  from T0100_EMP_EARN_DEDUCTION Sub_IED WITH (NOLOCK) Inner Join T0050_AD_MASTER ADM WITH (NOLOCK) on Sub_IED.AD_ID =  ADM.AD_ID 
					 where Sub_IED.Cmp_ID = @Cmp_ID and ADM.AD_DEF_ID = 2 
					group by Sub_IED.Emp_ID, Sub_IED.ad_id,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  ) Meed on
					 Meed.EMP_ID = IED.EMP_ID and Meed.For_Date = IED.FOR_DATE  and Meed.AD_ID  = IED.AD_ID) PFS 
					 on E.Emp_ID = PFS.Emp_ID Left Outer Join
					 
					( select  Meed.Emp_Id,IED.AD_ID,Meed.AD_ACTIVE,Meed.AD_DEF_ID,Meed.AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION IED WITH (NOLOCK) inner join 
					( select Sub_IED.ad_id,max(FOR_DATE) as For_Date ,Sub_IED.Emp_ID,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  from T0100_EMP_EARN_DEDUCTION Sub_IED WITH (NOLOCK) Inner Join T0050_AD_MASTER ADM WITH (NOLOCK) on Sub_IED.AD_ID =  ADM.AD_ID 
					 where Sub_IED.Cmp_ID = @Cmp_ID and ADM.AD_DEF_ID = 4 
					group by Sub_IED.Emp_ID, Sub_IED.ad_id,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  ) Meed on
					 Meed.EMP_ID = IED.EMP_ID and Meed.For_Date = IED.FOR_DATE  and Meed.AD_ID  = IED.AD_ID) PFS2  
					 on E.Emp_ID = PFS2.Emp_ID  Left Outer Join
					 
					 ( select  Meed.Emp_Id,IED.AD_ID,Meed.AD_ACTIVE,Meed.AD_DEF_ID,Meed.AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION IED WITH (NOLOCK) inner join 
					( select Sub_IED.ad_id,max(FOR_DATE) as For_Date , Sub_IED.Emp_ID,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  from T0100_EMP_EARN_DEDUCTION Sub_IED WITH (NOLOCK) Inner Join T0050_AD_MASTER ADM WITH (NOLOCK) on Sub_IED.AD_ID =  ADM.AD_ID 
					 where Sub_IED.Cmp_ID = @Cmp_ID and ADM.AD_DEF_ID = 5 
					 group by Sub_IED.Emp_ID, Sub_IED.ad_id,ADM.AD_ACTIVE,ADM.AD_DEF_ID,ADM.AD_SORT_NAME  ) Meed on
					  Meed.EMP_ID = IED.EMP_ID and  Meed.For_Date = IED.FOR_DATE   and Meed.AD_ID  = IED.AD_ID) PFS3 
			
					  on E.Emp_ID = PFS3.Emp_ID  Inner join
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

		WHERE E.Cmp_ID = @Cmp_Id	
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
		ORDER BY E.ALPHA_EMP_CODE,E.Emp_Full_Name,PF,CPF,VPF,Branch_Name,Full_PF,Full_CPF 
		
	RETURN


