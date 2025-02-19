--exec P_Retaining_Payment @Cmp_ID =120, @From_Date='2021-01-01 00:00:00.000',@To_Date='2022-10-19 00:00:00.000', @Ad_Id =1188
--exec SP_TEST_RETAIN_SALARY @Cmp_ID=120, @Ret_Start_Date='2021-07-01',@Ret_End_Date='2021-10-13',@emp_Id= 14560,@Grd_Id =379, @AD_ID =1129, @Tran_ID=55
CREATE PROCEDURE [dbo].[SP_TEST_RETAIN_SALARY]
	@Cmp_ID 	numeric ,
	@Ret_Start_Date	Datetime,
	@Ret_End_Date	Datetime ,
	@emp_Id		Numeric,
	@Grd_Id Numeric,
	@AD_ID Numeric,
	@Tran_ID integer
	
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	Begin
		Declare @for_Date Datetime 
		Declare @Month_day numeric		
		Declare @Month_St_Date datetime 
		Declare @Month_end_Date datetime 
		Declare @Sal_Tran_ID	numeric 
		Declare @Retain_Days numeric (5,1)
		Declare @Count integer =0
		Declare @MnLock_St_Date datetime 
		Declare @MnLock_end_Date datetime 
			
		select @MnLock_St_Date = From_Date,@MnLock_end_Date = To_Date  from T0090_Retaining_Lock_Setting where Cmp_Id = @Cmp_ID and  datediff(d,From_Date,@Ret_Start_Date) >0  
		delete from T0210_Retaining_MonthLock_Details
	
		declare @MnLock_Slab_date datetime
		declare @MNLock_slab_id integer
		declare @MNLock_slab_per numeric(18,2)
		declare @MNLock_days integer
		declare @MNLock_mode varchar(10)

		--Declare @curCal_Month as DateTime
		Declare @curMon_Start_Date as DateTime
		Declare @curMon_end_Date as DateTime
		Declare @MnLock_Slab_STdate as DateTime
		Declare @MnLock_Slab_Enddate as DateTime
		 
		Declare @curTot_Retain_Days as Numeric
		Declare @curRetain_Date as DateTime
		declare @curCMP_ID as Numeric
		Declare @curSlab_id as Numeric
		Declare @curSlab_Per as Numeric
		Declare @curFrom_Limit as Numeric(18,2)
		Declare @curTo_Limit as Numeric(18,2)
		Declare @curMode as Nvarchar(10)
		Declare @curAmount as numeric(18,2)  
		Declare @curAD_Id as Numeric
			set @MnLock_Slab_STdate = @MnLock_St_Date
		
		Declare Curs_MNLOCKSlab cursor for	                  
			select CMP_ID,RRateDetail_ID,Amount,From_Limit,To_Limit,Mode,Amount from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID  order by From_Limit
				Open Curs_MNLOCKSlab
				Fetch next from Curs_MNLOCKSlab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount
				While @@fetch_status = 0                    
				Begin    
					set @MnLock_Slab_Enddate = dateadd(d,@curTo_Limit,@MnLock_St_Date)
					insert into T0210_Retaining_MonthLock_Details ( tran_id,cmp_id,Retain_start_date,Retain_end_date, Retain_Slab_start_Date,Retain_Slab_end_Date , days,Slab_id, Slab_per, mode)
							values (@COUNT,@Cmp_ID,@Ret_Start_Date,@Ret_End_Date,@MnLock_Slab_STdate,@MnLock_Slab_Enddate,@Retain_Days, @curSlab_id,@curSlab_Per,@curMode)
					set @MnLock_Slab_STdate = @MnLock_Slab_Enddate +1

				fetch next from Curs_MNLOCKSlab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount	
				end
				close Curs_MNLOCKSlab                    
				deallocate Curs_MNLOCKSlab
			--------------------------------------
	
		set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1
		set @for_Date =@Ret_Start_Date
	    Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))
	    select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))			
		set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
	
	if @Retain_Days >0 
		begin
			while @for_Date< @Ret_end_Date
			begin
				select @MNLock_slab_id= Slab_Id, @MNLock_slab_per = Slab_per , @MNLock_mode = mode from T0210_Retaining_MonthLock_Details where @for_Date between Retain_Slab_start_Date and Retain_Slab_end_Date
				Exec P0210_Retaining_Datewise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@For_date,@Mon_Start_date=@Ret_Start_Date,@Mon_end_Date=@Ret_End_Date,@Days =@Count, @Month_day = @Month_day,@Tot_Retain_Days = @Retain_Days,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP',@AD_ID=@Ad_ID,@Retain_date=@For_date,
				@Slab_Id = @MNLock_slab_id, @Slab_Per = @MNLock_slab_per, @mode = @MNLock_mode
				set @for_Date =dateadd(dd,1,@for_Date)
				set @Count =@Count+1
				set @Retain_Days = @Retain_Days-1
				print @Retain_Days			
			end 
		end
	if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Emp' and type='U')
    begin
		delete  from #Temp_Emp
    end		
    
   insert into #Temp_Emp
	select E.Emp_ID,I.Branch_ID,I.Grd_ID,E.Date_Of_Join,Re.Start_Date,Re.End_Date, isnull(DateDiff(DAY,Re.Start_Date,Re.End_Date)+1,0),isnull(I.Basic_Salary,0),'',0,0,@Ad_Id,0 ,Re.Tran_Id
			from  T0100_EMP_RETAINTION_STATUS Re inner join
     T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = Re.Emp_ID and E.Cmp_Id=Re.Cmp_Id and Re.Is_Retain_ON = 0 AND e.Emp_ID = @emp_Id and Re.Tran_Id =@Tran_ID
	inner join  T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID = E.Increment_ID
	
  if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_other' and type='U')
    begin
		drop table #Temp_other
    end
    
    Create Table #Temp_other
     (
		Emp_ID NUMERIC ,     
		Ad_Id NUMERIC,
		For_Date Datetime,
		E_Ad_percentage Numeric(18,2),
		E_Ad_Amount numeric(18,2),
	)
	
	insert into #Temp_other
    exec P_Emp_Revised_Allowance_Get_Retaining @cmp_id,@Ret_End_Date
  
  if exists (select 1 from  T0060_EFFECT_AD_MASTER WITH (NOLOCK) where effect_AD_ID=@Ad_Id)
    begin
    
	   update #Temp_Emp
		set Other_Amount= TOA.Ad_Amount
		from #Temp_Emp TEJ inner join 
		( select SUM(E_Ad_Amount) as Ad_Amount,Emp_id from 
		#Temp_other inner join T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) on #Temp_other.Ad_Id = Ead.AD_ID  and EFFECT_AD_ID =@Ad_Id 
		--where Ead.AD_ID in (select Ad_id from  T0060_EFFECT_AD_MASTER where EFFECT_AD_ID=@Ad_Id) 
		group by Emp_id   )
		TOA on TEJ.Emp_ID = Toa.Emp_ID 
    end
				
	declare @curemp_id as Numeric
	Declare @curCal_Month as DateTime
	Declare @curdays as Numeric
	Declare @curMonth_day as Numeric
	Declare @curTran_id as integer

	Declare Curs_Retain cursor for	                  
	select emp_id,tran_id from #Temp_Emp   
	Open Curs_Retain
	Fetch next from Curs_Retain into @curemp_id,@curTran_id
	While @@fetch_status = 0                    
			Begin   
			update T0210_Retaining_Datewise_Payment 
						  set  Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID),
						  Per_Day_Salary =(select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day,
						  Retain_Amount = (((select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day) * 1) *Slab_Per/100
							where  Emp_Id= @curemp_id  and tran_id = @curTran_id
		
			 --update T0210_Retaining_Datewise_Payment 
				--		 set mode='AMT', 
				--		 slab_Id =@curSlab_id , 
				--		 Slab_Per = @curSlab_Per , 
				--		 Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID),
				--		 Per_Day_Salary = @curSlab_Per/@curMonth_day ,
				--		 Retain_Amount = @curSlab_Per						 
				--		 where  Emp_Id= @curemp_id 
				--		 and cast(Retain_date  as Date )=cast(Retain_date as Date) 
				--		--else 
						--begin
						-- update T0210_Retaining_Datewise_Payment 
						--  set  Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID),
						--  Per_Day_Salary =(select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day,
						--  Retain_Amount = (((select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day) * 1) *Slab_Per/100
						--	where  Emp_Id= @curemp_id 						 
   			--			end   
					
	fetch next from Curs_Retain into  @curemp_id,@curTran_id
	end
	close Curs_Retain                    
	deallocate Curs_Retain
	end
	
	
	if exists (select 1 from  T0210_Retaining_Datewise_Payment WITH (NOLOCK) where Emp_id=@emp_Id and cast(Mon_Start_date as date) >= @Ret_Start_Date and cast(Mon_End_date as date) <= @Ret_End_Date and tran_id= @Tran_ID)
    begin
 	update #Temp_Emp
    set Amount= (select sum(Retain_Amount) from T0210_Retaining_Datewise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	, Mode= (select top 1 mode from T0210_Retaining_Datewise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	where Emp_id = @emp_Id and  tran_id= @Tran_ID	
    end  
    Return

