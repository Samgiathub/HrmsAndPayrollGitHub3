--exec P_Retaining_Payment @Cmp_ID =120, @From_Date='2021-01-01 00:00:00.000',@To_Date='2022-10-19 00:00:00.000', @Ad_Id =1188
CREATE PROCEDURE [dbo].[P_Retaining_Payment]
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
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@PDept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@PVertical_ID,@PSubVertical_ID,'',@New_Join_emp,@Left_Emp,0,@PBranch_ID,0,0  
if exists(select 1 from tempdb.dbo.sysobjects where name ='Temp_Emp_Retain' and type='U')
    begin
		drop table Temp_Emp_Retain
    end    
   drop table Temp_Emp_Retain

	Create Table Temp_Emp_Retain
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
		Tran_Id Integer,
		Emp_Ret_Count integer,
		MonLock_Trans_Id integer null 

	 )

    delete from Temp_Emp_Retain

	
    insert into Temp_Emp_Retain 
	select E.Cmp_ID,E.Emp_ID,I.Branch_ID,I.Grd_ID,E.Date_Of_Join,Re.Start_Date,Re.End_Date,
	isnull(DateDiff(DAY,Re.Start_Date,Re.End_Date)+1,0),isnull(I.Basic_Salary,0),'',0,0,@Ad_Id,0, Re.Tran_Id ,		
	(select count (*) from T0100_EMP_RETAINTION_STATUS where  emp_id= Re.Emp_ID and Cmp_Id = @Cmp_ID) as ret_count,0
	from  T0100_EMP_RETAINTION_STATUS Re inner join
     T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = Re.Emp_ID and E.Cmp_Id=Re.Cmp_Id and Re.Is_Retain_ON = 0 and Re.Cmp_Id = @Cmp_ID
	inner join  T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID = E.Increment_ID
	inner Join #Emp_Cons ES on I.Increment_ID = ES.Increment_ID
	and  Re.tran_id not in(select distinct Ret_Tran_Id from T0210_Retaining_Payment_Detail where cmp_id=@Cmp_ID)

	-----------------------------------------------------------------
		update Temp_Emp_Retain 
		set Emp_Ret_Count = R_Cnt.Ret_Cnt		
		from Temp_Emp_Retain TEMP inner join 
						(	select count (Ret.Emp_id) as Ret_Cnt  ,ROW_NUMBER () Over(order by Ret.Start_Date) as Cnt , Ret.Emp_id , Ret.Tran_Id from T0100_EMP_RETAINTION_STATUS Ret ,Temp_Emp_Retain t where Ret.Emp_id =  t.Emp_ID and 
							Ret.Start_Date >= (select From_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.Start_Date between MN.From_Date and MN.To_Date) 	
							and Ret.End_Date <= (select To_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.End_Date between  MN.From_Date and MN.To_Date ) 
							Group by Ret.Emp_id , Ret.Start_Date ,Ret.Tran_Id							
						)
					R_Cnt on TEMP.Emp_ID = R_Cnt.Emp_ID	 and TEMP.Tran_Id = R_Cnt.Tran_ID		

		-------------------------------------------------------------------------
	
	
--  if exists(select 1 from tempdb.dbo.sysobjects where name ='Temp_other_Allowance' and type='U')
--    begin
--		drop table Temp_other_Allowance
--    end    
-- -- drop table Temp_other_Allowance
--    Create Table Temp_other_Allowance
--     (
--		Emp_ID NUMERIC ,     
--		Ad_Id NUMERIC,
--		For_Date Datetime,
--		E_Ad_percentage Numeric(18,2),
--		E_Ad_Amount numeric(18,2),
--		Basic_salary numeric(18,0)
--)	
	
 
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
		Other_Amount Numeric(18,2),
		Tran_Id integer,
		Emp_Ret_Count integer,
		MonLock_Trans_Id integer null 
	 )

	declare @curCmp_ID  as numeric
	declare @curemp_id as Numeric
	Declare @curRet_Start_Date as DateTime
	Declare @curRet_end_Date as DateTime
	Declare @curGRD_ID as Numeric
	Declare @curAD_ID as Numeric
	Declare @curTranID as integer
	Declare @curEmp_Ret_Count as integer
	
	Declare Curs_Retain1 cursor for	                  
	select  cmp_Id, emp_id,Grd_ID,Ad_id, Start_Date,End_Date,Tran_Id, Emp_Ret_Count from Temp_Emp_Retain order by Emp_Ret_Count
	Open Curs_Retain1
	Fetch next from Curs_Retain1 into @curCmp_ID, @curemp_id,@curGRD_ID,@curAD_ID ,@curRet_Start_Date, @curRet_end_Date,@curTranID,@curEmp_Ret_Count
	While @@fetch_status = 0                    
			Begin   

				--insert into #Temp_other_Allowance
				exec P_Emp_Revised_Allowance_Get_Retaining @cmp_id,@curRet_end_Date,@curemp_id			

				if exists (select 1 from  T0060_EFFECT_AD_MASTER WITH (NOLOCK) where EFFECT_AD_ID=@Ad_Id)
				 begin
					update Temp_Emp_Retain
					set Other_Amount= TOA.Ad_Amount,
						Basic_Salary = TOA.Basic_Salary
						from Temp_Emp_Retain TEJ inner join 
						(	select SUM(E_Ad_Amount) as Ad_Amount,Emp_id,Basic_Salary from 
							Temp_other_Allowance T inner join T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) 
							on T.Ad_Id = Ead.AD_ID  and EFFECT_AD_ID =@Ad_Id 
							group by Emp_id   ,Basic_Salary
						)
					TOA on TEJ.Emp_ID = Toa.Emp_ID     and End_Date = @curRet_end_Date
				 end
				
  				exec SP_CAL_RETAIN_SALARY @Cmp_ID=@Cmp_ID, @Ret_Start_Date=@curRet_Start_Date,@Ret_End_Date=@curRet_end_Date,@emp_Id= @curemp_id,@Grd_Id =@curGRD_ID, @AD_ID =@curAD_ID, @Tran_ID=@curTranID, @Ret_Count=@curEmp_Ret_Count
				
			Fetch next from Curs_Retain1 into @curCmp_ID, @curemp_id,@curGRD_ID,@curAD_ID ,@curRet_Start_Date, @curRet_end_Date,@curTranID,@curEmp_Ret_Count
			end
	close Curs_Retain1                    
	deallocate Curs_Retain1
	
	select 	 TEJ.Emp_ID ,     
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
	and  TEJ.tran_id not in(select distinct Ret_Tran_Id from T0210_Retaining_Payment_Detail where cmp_id=@Cmp_ID)
	and  [Start_Date] >= @From_Date and [END_date] <= @To_Date

			order by TEJ.Emp_ID, TEJ.Start_Date
	RETURN

