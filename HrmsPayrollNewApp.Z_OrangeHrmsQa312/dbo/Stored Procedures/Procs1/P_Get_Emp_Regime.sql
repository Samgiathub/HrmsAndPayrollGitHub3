
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P_Get_Emp_Regime]
	 @Cmp_ID		numeric
	,@Fin_Year		varchar(15)
	,@Branch_ID		varchar(Max)
	,@Grd_ID		varchar(Max)
	,@Dept_ID		varchar(Max)
	
	,@Cat_ID		varchar(Max)
	,@Desi_ID		varchar(Max)
	,@Vertical_ID	varchar(Max)
	,@SubVertical_ID varchar(Max)
	,@Seg_ID		varchar(Max)
	,@Subbranch_ID	varchar(Max)

	,@Type_ID		varchar(Max)
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@RegimeVal     numeric = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	declare @From_Date as datetime
	declare @To_Date as datetime
	declare @Regime as varchar(50) = ''
	
	set @From_Date = cast('01-Apr-' + cast(left(@Fin_Year,4)as VARCHAR(4))as datetime)
	set @To_Date = cast('31-Mar-' + cast(right(@Fin_Year,4)as VARCHAR(4)) as datetime)
	
	
	 CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
	 CREATE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
	
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desi_ID,@Emp_ID,@constraint,0,0,@Seg_ID,@Vertical_ID,@SubVertical_ID,@Subbranch_ID,0,0,0,'',0,0

	if @RegimeVal = 1 
	begin
		Set @Regime = 'Tax Regime 2'
	end
	else if @RegimeVal = 2 
	begin 
		Set @Regime = 'Tax Regime 1'
	end
	
	
	if @RegimeVal = 0
	begin
		select	E.Emp_ID,ITE.Financial_Year
			,case when ITE.Regime = 'Tax Regime 2' then 'New Regime' when ITE.Regime = 'Tax Regime 1' then 'Old Regime' else ' -- Select -- ' end as Regime
			,EM.Alpha_Emp_Code as Emp_code,EM.Emp_Full_Name as Employee_Name,G.Grd_Name,B.Branch_Name,D.Dept_Name,T.[Type_Name],DI.Desig_Name
		from	#Emp_Cons E
			inner join T0080_EMP_MASTER EM WITH (NOLOCK) on E.Emp_ID = EM.Emp_ID
			INNER join T0095_INCREMENT I WITH (NOLOCK) ON E.Emp_id = I.Emp_ID and E.Increment_ID = I.Increment_ID
			INNER join T0040_GRADE_MASTER G WITH (NOLOCK) on i.Grd_ID = G.Grd_ID
			Inner join T0030_BRANCH_MASTER B WITH (NOLOCK) on i.Branch_ID = B.Branch_ID
			left join T0040_DESIGNATION_MASTER DI WITH (NOLOCK) on i.Desig_Id = DI.Desig_ID
			LEFT join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on i.Dept_ID = D.Dept_Id
			LEFT join T0040_TYPE_MASTER T WITH (NOLOCK) on i.[Type_ID] = T.[Type_ID]
			LEFT join T0095_IT_Emp_Tax_Regime ITE WITH (NOLOCK) on E.Emp_ID = ITE.Emp_ID and ITE.Financial_Year = @Fin_Year
			
	end
	else
	begin
			select	E.Emp_ID,ITE.Financial_Year
			,case when ITE.Regime = 'Tax Regime 2' then 'New Regime' when ITE.Regime = 'Tax Regime 1' then 'Old Regime' else ' -- Select -- ' end as Regime
			,EM.Alpha_Emp_Code as Emp_code,EM.Emp_Full_Name as Employee_Name,G.Grd_Name,B.Branch_Name,D.Dept_Name,T.[Type_Name],DI.Desig_Name
		from	#Emp_Cons E
			inner join T0080_EMP_MASTER EM WITH (NOLOCK) on E.Emp_ID = EM.Emp_ID
			INNER join T0095_INCREMENT I WITH (NOLOCK) ON E.Emp_id = I.Emp_ID and E.Increment_ID = I.Increment_ID
			INNER join T0040_GRADE_MASTER G WITH (NOLOCK) on i.Grd_ID = G.Grd_ID
			Inner join T0030_BRANCH_MASTER B WITH (NOLOCK) on i.Branch_ID = B.Branch_ID
			left join T0040_DESIGNATION_MASTER DI WITH (NOLOCK) on i.Desig_Id = DI.Desig_ID
			LEFT join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on i.Dept_ID = D.Dept_Id
			LEFT join T0040_TYPE_MASTER T WITH (NOLOCK) on i.[Type_ID] = T.[Type_ID]
			LEFT join T0095_IT_Emp_Tax_Regime ITE WITH (NOLOCK) on E.Emp_ID = ITE.Emp_ID and ITE.Financial_Year = @Fin_Year
			where Regime not in (@Regime) and Financial_Year = @Fin_Year
	end


	
			
END
