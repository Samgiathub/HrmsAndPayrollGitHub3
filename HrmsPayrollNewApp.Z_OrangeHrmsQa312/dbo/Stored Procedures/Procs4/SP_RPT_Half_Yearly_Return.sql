


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Half_Yearly_Return]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		Varchar(Max)  
	,@Cat_ID		Varchar(Max)
	,@Grd_ID		Varchar(Max)
	,@Type_ID		Varchar(Max)
	,@Dept_ID		Varchar(Max)
	,@Desig_ID		Varchar(Max)
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@PBranch_ID	varchar(MAX) = '0'
	,@Segment_Id		varchar(MAX)=''
    ,@Vertical_Id		varchar(MAX)=''
    ,@SubVertical_Id	varchar(MAX)=''
    ,@SubBranch_Id		varchar(MAX)=''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	if @Cat_ID = '0' or @Cat_ID = ''
		set @Cat_ID = null
		 
	if @Type_ID = '0' or @Type_ID =''
		set @Type_ID = null
		
	if @Dept_ID = '0' or @Dept_ID=''
		set @Dept_ID = null
		
	if @Grd_ID = '0' or @Grd_ID=''
		set @Grd_ID = null
		
	if @Segment_Id = '0' or @Segment_Id=''
		set @Segment_Id = null
	
	if @Vertical_Id = '0' or @Vertical_Id=''
		set @Vertical_Id = null
		
	if @SubVertical_Id = '0' or @SubVertical_Id=''
		set @SubVertical_Id = null
	
	if @SubBranch_Id = '0' or @SubBranch_Id=''
		set @SubBranch_Id = null
			
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = '0' or @Desig_ID=''
		set @Desig_ID = null
	
	Declare @cnt_M as numeric(18,0)
	Declare @cnt_F as numeric(18,0)
	Declare @cnt_T as numeric(18,0)
	declare @no_of_joining as int	  	
	DECLARE @CMP_WEEKOFF AS VARCHAR(20)
	DECLARE @tot_working_day NUMERIC(18,0)
	DECLARE @Gender AS CHAR(1)
	DECLARE @Sal_Cal_Days AS NUMERIC(18,0)
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
		exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,'',@New_Join_emp,@Left_Emp,0,'0',0,0  
	
		--select @cnt_M = COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) ,
		--	@cnt_F = COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) ,
		--	@cnt_T = @cnt_M + @cnt_F
		--from T0080_Emp_Master As E
		--	INNER JOIN T0010_Company_Master As c ON C.Cmp_Id = E.Cmp_Id
		--WHERE E.Cmp_ID = @Cmp_Id And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		
		select  @cnt_M = sum(Sal_Cal_Days)
		from T0200_MONTHLY_SALARY SM WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SM.Emp_ID=E.Emp_ID AND SM.Cmp_ID=E.Cmp_ID
			INNER JOIN #Emp_Cons ECM on ECM.emp_id = E.emp_id
			WHERE E.Cmp_ID = @Cmp_Id and e.Gender = 'M' and SM.Month_End_Date >= @From_Date AND SM.Month_End_Date <= @To_Date
		
		select  @cnt_F = sum(Sal_Cal_Days)
		from T0200_MONTHLY_SALARY SM WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SM.Emp_ID=E.Emp_ID AND SM.Cmp_ID=E.Cmp_ID
			INNER JOIN #Emp_Cons ECM on ECM.emp_id = E.emp_id
			WHERE E.Cmp_ID = @Cmp_Id and e.Gender = 'F' and SM.Month_End_Date >= @From_Date AND SM.Month_End_Date <= @To_Date
		
		set @cnt_T= isnull(@cnt_M,0) + ISNULL(@cnt_F,0)		
		
		select @no_of_joining=COUNT(E.Emp_ID) from T0080_EMP_MASTER  E WITH (NOLOCK)
		INNER JOIN #Emp_Cons ECM on ECM.emp_id = E.emp_id
		where Cmp_ID=@Cmp_Id and Date_Of_Join >= @From_Date and Date_Of_Join <= @To_Date

		select @Cmp_Weekoff = Default_Holiday  from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID 
		(SELECT @tot_working_day=Count(Date) 
		FROM ( Select dateadd(dd,number,@From_Date )  as Date
			from master.dbo.spt_values 
			where master.dbo.spt_values.type='p' AND dateadd(dd,number,@From_Date)<=(@To_Date )
		   ) AS T  WHERE Datename(weekday, T.Date) NOT IN (isnull(@Cmp_Weekoff,'Sunday')) ) 
		
		   			
		select distinct C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_Pincode,@tot_working_day as Total_Days,
		isnull(@cnt_M,0) AS Male_Cur,isnull(@cnt_F,0) AS Female_Cur,isnull(@cnt_T,0) As Total,c.Nature_of_Business,@no_of_joining as no_of_joining,
		c.License_No,
		ISNULL(CD.Director_Name,'')as Director_Name,ISNULL(CD.Director_Address,'')as Director_Address,ISNULL(CD.Director_Designation,'')as Director_Designation,ISNULL(CD.Director_Branch,'')as Director_Branch,
		@From_Date AS From_Date,@To_Date as To_Date
		from T0080_Emp_Master As E WITH (NOLOCK)
			INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			LEFT JOIN T0010_COMPANY_DIRECTOR_DETAIL CD WITH (NOLOCK) ON CD.Cmp_Id=C.Cmp_Id
			INNER JOIN #Emp_Cons ECM on ECM.emp_id = E.emp_id
		WHERE E.Cmp_ID = @Cmp_Id 
		--And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		--Group By C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_Pincode,c.Nature_of_Business		
	RETURN




