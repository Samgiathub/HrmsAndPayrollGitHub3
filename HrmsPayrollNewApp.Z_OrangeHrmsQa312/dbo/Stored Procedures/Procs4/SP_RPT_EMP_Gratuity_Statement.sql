


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_Gratuity_Statement]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	--,@Branch_ID		numeric   = 0
	--,@Cat_ID		numeric  = 0
	--,@Grd_ID		numeric = 0
	--,@Type_ID		numeric  = 0
	--,@Dept_ID		numeric  = 0
	--,@Desig_ID		numeric = 0
	,@Branch_ID		varchar(max) = ''
	,@Cat_ID		varchar(max) = ''
	,@Grd_ID		varchar(max) = ''
	,@Type_ID		varchar(max) = ''
	,@Dept_ID		varchar(max) = ''
	,@Desig_ID		varchar(max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	--,@Segment_Id  numeric = 0		
	--,@Vertical_Id numeric = 0		
	--,@SubVertical_Id numeric = 0	 
	--,@SubBranch_Id numeric = 0
	,@Segment_Id  varchar(max) = ''		
	,@Vertical_Id varchar(max) = ''		
	,@SubVertical_Id varchar(max) = ''	 
	,@SubBranch_Id varchar(max) = ''		
	,@Format	   varchar(10) = ''
	,@Status Varchar(10) = 'All'  --Added By Jaina 03-09-2016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE table #Emp_Cons 
    (      
       Emp_ID numeric ,     
       Branch_ID numeric,
       Increment_ID numeric    
	)      
 
    exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,0

	/*
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
  FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'

	
	CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
 
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id ,@New_Join_emp,@Left_Emp

	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
	--	end
	--else if @New_Join_emp = 1 
	--	begin

	--		Insert Into #Emp_Cons      
	--		Select distinct emp_id,branch_id,Increment_ID 
	--		From V_Emp_Cons Where Cmp_id=@Cmp_ID 
	--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
	--			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
	--			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
	--			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
	--			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
	--			and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
	--			and Increment_Effective_Date <= @To_Date 
	--			and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
	--		Order by Emp_ID
						
	--		Delete From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
	--			Where  Increment_effective_Date <= @to_date Group by emp_ID)

	--	end
	--else if @Left_Emp = 1 
	--	begin

	--		Insert Into #Emp_Cons      
	--		Select distinct emp_id,branch_id,Increment_ID 
	--		From V_Emp_Cons Where Cmp_id=@Cmp_ID 
	--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
	--			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))			
	--			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))		 
	--			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
	--			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
	--			and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
	--			and Increment_Effective_Date <= @To_Date 
	--			and Left_date >=@From_Date and Left_Date <=@to_Date
	--		Order by Emp_ID
						
	--		Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
	--			Where  Increment_effective_Date <= @to_date Group by emp_ID)
	--	end		
	--else 
	--	begin

	--		-- below condition changed by mitesh on 05072013
	--		Insert Into #Emp_Cons      
	--	      select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
	--	        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
	--						inner join 
	--						(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
	--						GROUP BY emp_id) Qry
	--						on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
	--	       ON QrySC.eid = V_Emp_Cons.Emp_ID
	--	  where 
	--	     cmp_id=@Cmp_ID 
	--	       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
	--	   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
	--	   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       
	--	   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
	--	   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  
	--	   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
	--	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
	--	      and Increment_Effective_Date <= @To_Date 
	--	      and 
 --                     ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--					or (Left_date is null and @To_Date >= Join_Date)      
	--					or (@To_Date >= left_date  and  @From_Date <= left_date )
	--					OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
	--					) 
	--					order by Emp_ID
						
	--		delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
	--			where  Increment_effective_Date <= @to_date
	--			group by emp_ID)	
	--	end */
		
	
	--when 0 then 1 end as Month_exp
	
	--Added By Jaina 03-09-2016 Start
	 Declare @Emp_Left as Char(1) = ''
	 Declare @Branch_Count As numeric = 0
	
	if @Branch_ID <> ''
	BEGIN
		select @Branch_Count = Count(Data) from dbo.Split(@Branch_ID, '#')
	END
	
	 if @Status = 'Active'
		 Begin
			set @Emp_Left ='N'
		 End
	 ELSE
		 Begin
		 	set @Emp_Left ='Y'
		 End
	--Added By Jaina 03-09-2016 End
	Declare @Group_Joining_Date as datetime
	If @Status <> 'All'
	Begin
	
	 if @Format = 'Eligibilty'
	 begin
		
			select I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,(I_Q.Basic_Salary + isnull(EED.E_AD_AMOUNT,0)) as Basic_Salary,E.Emp_Full_Name ,E.Alpha_Emp_Code,Cmp_Name,
					CASE @Branch_Count WHEN 1 THEN  --Added By Jaina 05-09-2016
					BM.Branch_Address
					ELSE
					Cmp_Address END as Cmp_Address
					,Grd_Name,type_Name,Dept_Name,Desig_Name,
					Case isnull(gs.Gr_Days,0) 
						    when 0 then 
								(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0))) * 
								case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
								when 0 then 1 
								else 
									Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
										Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
									else
										CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
									End
								end  
					else
					--((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days))  *	--Commented By Ramiz on 16102015
					 ((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / Case when I_Q.Wages_Type = 'Daily' then 1 else isNull(Gs.Gr_PRORATA_Cal,30) End) * Gs.Gr_Days))  *	--Added By Ramiz on 16102015 for Daily Wages 
					 case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
					 when 0 then 1 
					 else
						Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
							Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
						else
							CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
						End
			 
					 end  
					end as Gratuity,dbo.F_GET_AGE(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),GETDATE(),'Y','N') as Works_Year_Month,ISNULL(E.GroupJoiningDate,E.Date_Of_Join) as Group_Joining_Date,
					gs.Gr_Min_Year,gs.Gr_Days
					,E.Date_Of_Join , E.Date_Of_Birth, -- added by mitesh on 02012014
					Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
							Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
						else
							CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
							--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
						End	As Calculation_Years
						,E.Emp_Left,E.Emp_Left_Date   --Added By Jaina 03-09-2016					
					from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,isnull(Basic_Salary,0) as Basic_Salary , Wages_Type from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID= Qry.Increment_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID INNER JOIN
						( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
							WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
						) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
					dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
					V0100_EMP_EARN_DEDUCTION EED on I_Q.Emp_ID = EED.EMP_ID and EED.AD_DEF_ID = 11 and
					 EED.For_Date = (Select MAX(In_VEED.for_Date) from V0100_EMP_EARN_DEDUCTION In_VEED 
					 where  In_VEED.AD_DEF_ID = 11 and In_VEED.EMP_ID = I_Q.Emp_ID  Group by In_VEED.EMP_ID ) Inner Join   ---Added By Gadriwala Muslim 16072014
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

		WHERE E.Cmp_ID = @Cmp_Id	and CONVERT(float,dbo.F_GET_AGE(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),GETDATE(),'Y','N')) >=  Convert(float,isnull(gs.Gr_Min_Year,0))
				and E.Emp_Left = @Emp_Left   --Added By Jaina 03-09-2016
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
	 end
	 else
	 begin
	 
		select I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,(I_Q.Basic_Salary + isnull(EED.E_AD_AMOUNT,0)) as Basic_Salary,E.Emp_Full_Name ,E.Alpha_Emp_Code,Cmp_Name,
				CASE @Branch_Count WHEN 1 THEN  --Added By Jaina 05-09-2016
					BM.Branch_Address
					ELSE
					Cmp_Address END as Cmp_Address
				,Grd_Name,type_Name,Dept_Name,Desig_Name,
					Case isnull(gs.Gr_Days,0) 
						    when 0 then 
					--(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0)) / 12) * 
					(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0))) * 
							case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
							when 0 then 1 
							else 
								--DATEDIFF(MONTH,isnull(e.Date_Of_Join,getdate()),getdate()) 
								Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
									Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
								else
									CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))	--Upper Round --Ankit 27082015
									--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
								End						
								
							end  
					else
					 --((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days) / 12) * 
					 --((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days)) *  --Commented By Ramiz on 16102015
					 ((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / Case when I_Q.Wages_Type = 'Daily' then 1 else isNull(Gs.Gr_PRORATA_Cal,30) End) * Gs.Gr_Days)) *	--Added By Ramiz on 15102015 for Daily Wages Calculation
					 case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
					 when 0 then 1 
					 else
						--DATEDIFF(MONTH,isnull(e.Date_Of_Join,getdate()),getdate()) 
						Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
							Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
						else
							CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
							--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
						End						
					 end  
					end as Gratuity,dbo.F_GET_AGE(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),GETDATE(),'Y','N') as Works_Year_Month,ISNULL(E.GroupJoiningDate,E.Date_Of_Join) as Group_Joining_Date
					,E.Date_Of_Join , E.Date_Of_Birth,  -- added by mitesh on 02012014
					Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
							Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
						else
							CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))		--Upper Round --Ankit 27082015
							--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
						End	As Calculation_Years
						,E.Emp_Left,E.Emp_Left_Date   --Added By Jaina 03-09-2016
					from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,isnull(Basic_Salary,0) as Basic_Salary  , Wages_Type from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id, Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q   --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID INNER JOIN
						( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
							WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
						) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE  LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
					dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Left outer join 
					V0100_EMP_EARN_DEDUCTION EED on I_Q.Emp_ID = EED.EMP_ID and EED.AD_DEF_ID = 11 and EED.For_Date = 
					(Select MAX(In_VEED.for_Date) from V0100_EMP_EARN_DEDUCTION In_VEED where  In_VEED.AD_DEF_ID = 11 and
					 In_VEED.EMP_ID = I_Q.Emp_ID  Group by In_VEED.EMP_ID ) Inner Join   ---Added By Gadriwala Muslim 16072014
					#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
					WHERE E.Cmp_ID = @Cmp_Id	
					and E.Emp_Left = @Emp_Left   --Added By Jaina 03-09-2016
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		end
	End
	Else
	Begin
		 
		 if @Format = 'Eligibilty'
		 begin
			
				select I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,(I_Q.Basic_Salary + isnull(EED.E_AD_AMOUNT,0)) as Basic_Salary,E.Emp_Full_Name ,E.Alpha_Emp_Code,Cmp_Name,
					   CASE @Branch_Count WHEN 1 THEN  --Added By Jaina 05-09-2016
							BM.Branch_Address
						ELSE
						Cmp_Address END as Cmp_Address
						,Grd_Name,type_Name,Dept_Name,Desig_Name,
						Case isnull(gs.Gr_Days,0) 
								when 0 then 
									(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0))) * 
									case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
									when 0 then 1 
									else 
										Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
											Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
										else
											CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
										End
									end  
						else
						--((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days))  *	--Commented By Ramiz on 16102015
						 ((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / Case when I_Q.Wages_Type = 'Daily' then 1 else isNull(Gs.Gr_PRORATA_Cal,30) End) * Gs.Gr_Days))  *	--Added By Ramiz on 16102015 for Daily Wages 
						 case DATEDIFF(MONTH,isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),getdate()) 
						 when 0 then 1 
						 else
							Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
								Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
							else
								CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
							End
				 
						 end  
						end as Gratuity,dbo.F_GET_AGE(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),GETDATE(),'Y','N') as Works_Year_Month,ISNULL(E.GroupJoiningDate,E.Date_Of_Join) as Group_Joining_Date,
						gs.Gr_Min_Year,gs.Gr_Days
						,E.Date_Of_Join , E.Date_Of_Birth, -- added by mitesh on 02012014
						Case When Substring(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))+1,2) = 5 
								Then floor(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))
							else
								CEILING(dbo.F_GET_AGE(isnull(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
								--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
							End	As Calculation_Years	
							,E.Emp_Left,E.Emp_Left_Date   --Added By Jaina 03-09-2016				
						from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,isnull(Basic_Salary,0) as Basic_Salary , Wages_Type from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID= Qry.Increment_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID INNER JOIN
							( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
								WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
							) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
						V0100_EMP_EARN_DEDUCTION EED on I_Q.Emp_ID = EED.EMP_ID and EED.AD_DEF_ID = 11 and
						 EED.For_Date = (Select MAX(In_VEED.for_Date) from V0100_EMP_EARN_DEDUCTION In_VEED 
						 where  In_VEED.AD_DEF_ID = 11 and In_VEED.EMP_ID = I_Q.Emp_ID  Group by In_VEED.EMP_ID ) Inner Join   ---Added By Gadriwala Muslim 16072014
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

			WHERE E.Cmp_ID = @Cmp_Id	and CONVERT(float,dbo.F_GET_AGE(ISNULL(E.GroupJoiningDate,E.Date_Of_Join),GETDATE(),'Y','N')) >=  Convert(float,isnull(gs.Gr_Min_Year,0))
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				End
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		 end
		 else
		 begin
		 
			select I_Q.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,(I_Q.Basic_Salary + isnull(EED.E_AD_AMOUNT,0)) as Basic_Salary,E.Emp_Full_Name ,E.Alpha_Emp_Code,Cmp_Name,
				   CASE @Branch_Count WHEN 1 THEN  --Added By Jaina 05-09-2016
					BM.Branch_Address
					ELSE
					Cmp_Address END as Cmp_Address
				   ,Grd_Name,type_Name,Dept_Name,Desig_Name,
						Case isnull(gs.Gr_Days,0) 
								when 0 then 
						--(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0)) / 12) * 
						(((isnull(I_Q.Basic_Salary,0) / 2) + isnull(EED.E_AD_AMOUNT,0))) * 
								case DATEDIFF(MONTH,isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),getdate()) 
								when 0 then 1 
								else 
									--DATEDIFF(MONTH,isnull(e.Date_Of_Join,getdate()),getdate()) 
									Case When Substring(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
										Then floor(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))
									else
										CEILING(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))	--Upper Round --Ankit 27082015
										--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
									End						
									
								end  
						else
						 --((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days) / 12) * 
						 --((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / isNull(Gs.Gr_PRORATA_Cal,30)) * Gs.Gr_Days)) *  --Commented By Ramiz on 16102015
						 ((((isnull(I_Q.Basic_Salary,0) + isnull(EED.E_AD_AMOUNT,0)) / Case when I_Q.Wages_Type = 'Daily' then 1 else isNull(Gs.Gr_PRORATA_Cal,30) End) * Gs.Gr_Days)) *	--Added By Ramiz on 15102015 for Daily Wages Calculation
						 case DATEDIFF(MONTH,isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),getdate()) 
						 when 0 then 1 
						 else
							--DATEDIFF(MONTH,isnull(e.Date_Of_Join,getdate()),getdate()) 
							Case When Substring(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
								Then floor(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))
							else
								CEILING(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))  --Upper Round --Ankit 27082015
								--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
							End						
						 end  
						end as Gratuity,dbo.F_GET_AGE(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,GETDATE(),'Y','N') as Works_Year_Month,Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end as Group_Joining_Date
						,E.Date_Of_Join , E.Date_Of_Birth,  -- added by mitesh on 02012014
						Case When Substring(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))+1,2) <= 5 
								Then floor(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))
							else
								CEILING(dbo.F_GET_AGE(isnull(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end,getdate()),GETDATE(),'Y','N'))		--Upper Round --Ankit 27082015
								--Round(dbo.F_GET_AGE(isnull(e.Date_Of_Join,getdate()),GETDATE(),'Y','N'),0)  
							End	As Calculation_Years
							,E.Emp_Left,E.Emp_Left_Date   --Added By Jaina 03-09-2016
						from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,isnull(Basic_Salary,0) as Basic_Salary  , Wages_Type from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id, Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q   --Changed by Hardik 09/09/2014 for Same Date Increment
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID INNER JOIN
							( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
								WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID
							) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE  LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Left outer join 
						V0100_EMP_EARN_DEDUCTION EED on I_Q.Emp_ID = EED.EMP_ID and EED.AD_DEF_ID = 11 and EED.For_Date = 
						(Select MAX(In_VEED.for_Date) from V0100_EMP_EARN_DEDUCTION In_VEED where  In_VEED.AD_DEF_ID = 11 and
						 In_VEED.EMP_ID = I_Q.Emp_ID  Group by In_VEED.EMP_ID ) Inner Join   ---Added By Gadriwala Muslim 16072014
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID
						WHERE E.Cmp_ID = @Cmp_Id	
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				End
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
			end
		END
	RETURN



