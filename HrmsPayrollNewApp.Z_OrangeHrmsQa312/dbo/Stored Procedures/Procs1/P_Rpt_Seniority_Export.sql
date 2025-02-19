

-- Created By rohit On 28052015 for Seniority Awards.
CREATE PROCEDURE [dbo].[P_Rpt_Seniority_Export]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Ad_Id			Numeric = 0
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',@New_Join_emp,@Left_Emp,0,'0',0,0

	
    Create Table #Temp_Emp_Join
     (
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Join_Date Datetime,
		Period Numeric(18,2),
		Basic_Salary numeric(18,2),
		mode varchar(50),
		Amount numeric(18,2),
		Net_Amount Numeric(18,2)
	 )
    
    insert into #Temp_Emp_Join
    select E.Emp_ID,I.Branch_ID,E.Date_Of_Join,DATEDIFF(month,Date_Of_Join,@To_Date),I.Basic_Salary,'',0,0  from
    T0095_INCREMENT I WITH (NOLOCK) inner join 
    #Emp_Cons ES on I.Increment_ID = ES.Increment_ID
    inner join T0080_EMP_MASTER E WITH (NOLOCK) on ES.Emp_ID = E.Emp_ID 
    
    declare @curCMP_ID as Numeric
    Declare @Curad_id as Numeric
    Declare @CurFrom_Age as Numeric(18,2)
    Declare @curTo_Age as Numeric
    Declare @curMode as varchar
    Declare @curAmount as varchar
    
    Declare Curs_Slab cursor for	                  
	select CMP_ID,ad_id,From_Age,To_Age,Mode,Amount from T0190_Seniority_Award_Slab WITH (NOLOCK) where ad_id= @ad_id
	Open Curs_Slab
	Fetch next from Curs_Slab into @curCMP_ID,@Curad_id,@CurFrom_Age,@curTo_Age,@curMode,@curAmount
	While @@fetch_status = 0                    
		Begin     
    
    if @curMode = 'AMT' 
    begin
     update #Temp_Emp_Join 
     set mode='AMT',Amount = @curAmount , Net_Amount = @curAmount
     where Period >=@CurFrom_Age and Period <= @curTo_Age 
    end
    else
    begin
	 update #Temp_Emp_Join 
     set mode='%',Amount = @curAmount , Net_Amount = (Basic_Salary * @curAmount)/100
     where Period >=@CurFrom_Age and Period <= @curTo_Age 
    end
    
	fetch next from Curs_Slab into @curCMP_ID,@Curad_id,@CurFrom_Age,@curTo_Age,@curMode,@curAmount	
	end
	close Curs_Slab                    
	deallocate Curs_Slab

    select * from #Temp_Emp_Join
    
	
	
	RETURN




