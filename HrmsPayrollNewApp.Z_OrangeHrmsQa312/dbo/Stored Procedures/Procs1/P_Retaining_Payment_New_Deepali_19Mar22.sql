--exec P_Retaining_Payment_New_Deepali_19Mar22 @Cmp_ID =120, @From_Date='2021-01-19 00:00:00.000',@To_Date='2022-10-19 00:00:00.000', @Ad_Id =1129
CREATE PROCEDURE [dbo].[P_Retaining_Payment_New_Deepali_19Mar22]
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
	    Cmp_id Numeric,
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Grd_ID numeric,
		Join_Date Datetime,
		Start_Date Datetime,
		End_Date Datetime,
		Period Numeric(18,2),
		Basic_Salary numeric(18,2),
		mode varchar(50),
		Amount numeric(18,2),
		Net_Amount Numeric(18,2),
		Ad_id numeric,
		Other_Amount Numeric(18,2),
		Tran_Id Integer
	 )
    
    insert into #Temp_Emp_Join
	select E.Cmp_ID,E.Emp_ID,I.Branch_ID,I.Grd_ID,E.Date_Of_Join,Re.Start_Date,Re.End_Date, isnull(DateDiff(DAY,Re.Start_Date,Re.End_Date),0),isnull(I.Basic_Salary,0),'',0,0,@Ad_Id,0, Re.Tran_Id 
			from  T0100_EMP_RETAINTION_STATUS Re inner join
     T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = Re.Emp_ID and E.Cmp_Id=Re.Cmp_Id and Re.Is_Retain_ON = 0
	inner join  T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID = E.Increment_ID
	inner Join #Emp_Cons ES on I.Increment_ID = ES.Increment_ID

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
    exec P_Emp_Revised_Allowance_Get_Retaining @cmp_id,@To_Date
     --------------
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

	--select * from #Temp_Emp_Join
   
 --exec SP_TEST_RETAIN_SALARY @Cmp_ID=@Cmp_ID, @Ret_Start_Date='2021-11-15',@Ret_End_Date='2022-04-20',@emp_Id= 14560,@Grd_Id =379, @AD_ID =1129
 
 if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Emp' and type='U')
    begin
		drop table #Temp_Emp
    end
		Create Table #Temp_Emp
     (
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Grd_ID numeric,
		Join_Date Datetime,
		Start_Date Datetime,
		End_Date Datetime,
		Period Numeric(18,2),
		Basic_Salary numeric(18,2),
		mode varchar(50),
		Amount numeric(18,2),
		Net_Amount Numeric(18,2),
		Ad_id numeric,
		Other_Amount Numeric(18,2)
		,Tran_Id integer
	 )
    -------------------
	if exists(select 1 from tempdb.dbo.sysobjects where name ='#temp_Retaining_Monthwise_Payment' and type='U')
    begin
		drop table #temp_Retaining_Monthwise_Payment
    end

	CREATE TABLE #temp_Retaining_Monthwise_Payment(
	[tran_D_id] [numeric](18, 0) IDENTITY(1,1) ,
	[tran_id] [numeric](18, 0) ,
	[cmp_id] [numeric](18, 0) ,
	[Emp_id] [numeric](18, 0),
	[Ad_id] [numeric](18, 0) ,
	[Cal_Month] [datetime] ,
	[Mon_Start_date] [datetime] ,
	[Mon_End_date] [datetime] ,
	[Days] [numeric](18, 2) ,
	[Slab_Id] [numeric](18, 2) ,
	[Slab_Per] [numeric](18, 2) ,
	[Mode] [varchar](50) ,
	[Per_Day_Salary] [numeric](18, 2) ,
	[Retain_Amount] [numeric](18, 2) ,
	[Tot_Amount] [numeric](18, 2) ,
	[remarks] [varchar](500) ,
	[Modify_Date] [datetime] ,
	[Tot_Retain_Days] [int] ,
	[Basic_Amount] [numeric](18, 2) ,
	[Month_Day] [int] 
) 

	---------------------delete from T0210_Retaining_Monthwise_Payment set remarks ='FINAL' where tran_id = @tran_id and Emp_ID =@Emp_ID
if exists(select 1 from #temp_Retaining_Monthwise_Payment )
    begin
		delete from #temp_Retaining_Monthwise_Payment 
    end			
	     declare @curCmp_ID  as numeric
		 declare @curemp_id as Numeric
		 Declare @curRet_Start_Date as DateTime
		 Declare @curRet_end_Date as DateTime
		 Declare @curGRD_ID as Numeric
		 Declare @curAD_ID as Numeric
		 Declare @curTranID as integer
		 Declare Curs_Retain1 cursor for	                  
	select  cmp_Id, emp_id,Grd_ID,Ad_id, Start_Date,End_Date,Tran_Id from #Temp_Emp_Join 
	Open Curs_Retain1
	Fetch next from Curs_Retain1 into @curCmp_ID, @curemp_id,@curGRD_ID,@curAD_ID ,@curRet_Start_Date, @curRet_end_Date,@curTranID
	While @@fetch_status = 0                    
			Begin     
  				exec SP_TEST_RETAIN_SALARY_New_Deepali @Cmp_ID=@Cmp_ID, @Ret_Start_Date=@curRet_Start_Date,@Ret_End_Date=@curRet_end_Date,@emp_Id= @curemp_id,@Grd_Id =@curGRD_ID, @AD_ID =@curAD_ID, @Tran_ID=@curTranID
				
			Fetch next from Curs_Retain1 into @curCmp_ID, @curemp_id,@curGRD_ID,@curAD_ID ,@curRet_Start_Date, @curRet_end_Date,@curTranID
			end
	close Curs_Retain1                    
	deallocate Curs_Retain1
	--print 'temparary Table #temp_Retaining_Monthwise_Payment '
	--select * from #temp_Retaining_Monthwise_Payment
				
		----if exists (select 1 from  T0210_Retaining_Monthwise_Payment WITH (NOLOCK) where Emp_id=@emp_Id and cast(Mon_Start_date as date) >= @curRet_Start_Date and cast(Mon_End_date as date) <= @curRet_end_Date)
		----		begin
		----		update #Temp_Emp_Join
		----		set Amount= (select sum(Retain_Amount) from T0210_Retaining_Monthwise_Payment where Emp_id = @emp_Id)
		----		where Emp_id = @emp_Id and Start_Date = @curRet_Start_Date and End_Date = @curRet_end_Date
		----		end
   --select * from #Temp_Emp
	--select * from #Temp_Emp_Join

	select --TEJ.*
	distinct TEJ.Emp_ID ,     
	tej.Branch_ID,
	TEJ.Join_Date,
	format (TEJ.Start_Date,'dd/MM/yyyy') as Start_Date,
	format (TEJ.End_Date,'dd/MM/yyyy') as End_Date,
	TEJ.Period,
	isnull(TEJ.Basic_Salary,0)  + isnull(tej.Other_Amount,0) as Basic_Salary ,
	tej.mode ,
	TEJ.Amount,
	TEJ.Net_Amount,
	TEJ.Ad_id ,
	TEJ.Other_Amount 
	,EM.Emp_Full_Name,Em.Alpha_Emp_Code,Am.AD_NAME,TEJ.Tran_Id  from  #Temp_Emp TEJ inner join T0050_AD_MASTER AM WITH (NOLOCK) on 
	TEJ.ad_id = AM.AD_ID inner join T0080_EMP_MASTER Em WITH (NOLOCK) on TEJ.Emp_ID = EM.Emp_ID
	--left outer Join T0210_Retaining_Payment_Detail Re on Re.Emp_id=Em.Emp_ID  where RE.tran_id <>0  
	
	
	select * from #temp_Retaining_Monthwise_Payment
	select * from T0210_Retaining_Monthwise_Payment
	RETURN




