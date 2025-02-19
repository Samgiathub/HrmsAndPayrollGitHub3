

CREATE PROCEDURE [dbo].[P_Seniority_Calculation]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max) = ''	
	,@Grd_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Vertical_Id	varchar(Max) = ''
	,@SubVertical_Id varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Segment_Id	varchar(Max) = ''
	,@SubBranch_ID  varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Ad_Id			Numeric = 0
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0	
	,@PBranch_ID varchar(max) = '0'  --Added By Jaina 30-09-2015
	,@PVertical_ID	varchar(max)= '0' --Added By Jaina 30-09-2015
	,@PSubVertical_ID	varchar(max)= '0' --Added By Jaina 30-09-2015
	,@PDept_ID varchar(max)='0'  --Added By Jaina 30-09-2015
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	if @Branch_ID ='0'
		set @Branch_ID =''
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',@New_Join_emp,@Left_Emp,0,'0',0,0
	--Added By Jaina 30-09-2015
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@PDept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@PVertical_ID,@PSubVertical_ID,'',@New_Join_emp,@Left_Emp,0,@PBranch_ID,0,0  

	
    Create Table #Temp_Emp_Join
     (
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Join_Date Datetime,
		Period Numeric(18,2),
		Basic_Salary numeric(18,2),
		mode varchar(50),
		Amount numeric(18,2),
		Net_Amount Numeric(18,2),
		Ad_id numeric,
		Other_Amount Numeric(18,2)
	 )
    
    insert into #Temp_Emp_Join
    select E.Emp_ID,I.Branch_ID,E.Date_Of_Join,DATEDIFF(month,Date_Of_Join,@To_Date),isnull(I.Basic_Salary,0),'',0,0,@Ad_Id,0  from
    T0095_INCREMENT I WITH (NOLOCK) inner join 
    #Emp_Cons ES on I.Increment_ID = ES.Increment_ID
    inner join T0080_EMP_MASTER E WITH (NOLOCK) on ES.Emp_ID = E.Emp_ID 
	inner join T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) on ES.Emp_ID = EED.EMP_ID and Es.Increment_ID = EED.INCREMENT_ID and ad_id=@Ad_Id
		
   
    if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_other_Allowance' and type='U')
    begin
		drop table #Temp_other_Allowance
    end
    
    Create Table #Temp_other_Allowance
     (
		Emp_ID NUMERIC ,     
		Ad_Id NUMERIC,
		For_Date Datetime,
		E_Ad_percentage Numeric(18,2),
		E_Ad_Amount numeric(18,2),
	)
	
    insert into #Temp_other_Allowance
    exec P_Emp_Revised_Allowance_Get @cmp_id,@To_Date
    
    
    if exists (select 1 from  T0060_EFFECT_AD_MASTER WITH (NOLOCK) where EFFECT_AD_ID=@Ad_Id)
    begin
    
   update #Temp_Emp_Join
    set Other_Amount= TOA.Ad_Amount
	from #Temp_Emp_Join TEJ inner join 
    ( select SUM(E_Ad_Amount) as Ad_Amount,Emp_id from 
    #Temp_other_Allowance  inner join T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) on #Temp_other_Allowance.Ad_Id = Ead.AD_ID  and EFFECT_AD_ID =@Ad_Id 
	--where Ead.AD_ID in (select Ad_id from  T0060_EFFECT_AD_MASTER where EFFECT_AD_ID=@Ad_Id) 
	group by Emp_id   )
    TOA on TEJ.Emp_ID = Toa.Emp_ID 
    
    end
   
   
    
    declare @curCMP_ID as Numeric
    Declare @Curad_id as Numeric
    Declare @CurFrom_Age as Numeric(18,2)
    Declare @curTo_Age as Numeric(18,2)
    Declare @curMode as Nvarchar(10)
    Declare @curAmount as numeric(18,2)
    
    
    
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
     set mode='%',Amount = @curAmount , Net_Amount = ((Basic_Salary + Other_Amount)  * @curAmount)/100
     where Period >=@CurFrom_Age and Period <= @curTo_Age 
    end
    
	fetch next from Curs_Slab into @curCMP_ID,@Curad_id,@CurFrom_Age,@curTo_Age,@curMode,@curAmount	
	end
	close Curs_Slab                    
	deallocate Curs_Slab

	select --TEJ.*
	TEJ.Emp_ID ,     
	tej.Branch_ID,
	TEJ.Join_Date,
	TEJ.Period,
	isnull(TEJ.Basic_Salary,0)  + isnull(tej.Other_Amount,0) as Basic_Salary ,
	tej.mode ,
	TEJ.Amount,
	TEJ.Net_Amount,
	TEJ.Ad_id ,
	TEJ.Other_Amount 
	,EM.Emp_Full_Name,Em.Alpha_Emp_Code,Am.AD_NAME from #Temp_Emp_Join TEJ inner join T0050_AD_MASTER AM WITH (NOLOCK) on 
	TEJ.ad_id = AM.AD_ID inner join T0080_EMP_MASTER Em WITH (NOLOCK) on TEJ.Emp_ID = EM.Emp_ID
    
	
		
	RETURN




