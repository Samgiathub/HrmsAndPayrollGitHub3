--exec SP_TEST_RETAIN_SALARY @Cmp_ID=120, @Ret_Start_Date='2021-07-01',@Ret_End_Date='2021-10-13',@emp_Id= 14560,@Grd_Id =379, @AD_ID =1129, @Tran_ID=55
CREATE PROCEDURE [dbo].[SP_TEST_RETAIN_SALARY_New_Deepali]
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
		Declare @StartDiffDay integer
		Declare @EndDiffDay integer
		Declare @DiffDay integer
		Declare @TotDiffDay integer =0
		Declare @Month_day numeric		
		Declare @Month_St_Date datetime 
		Declare @Month_end_Date datetime 
		Declare @Sal_Tran_ID	numeric 
		Declare @Retain_Days numeric (5,1)
		Declare @Count integer =0
		set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1
		print @Retain_Days
		set @for_Date =@Ret_Start_Date
		select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))
		select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))			
		set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
							
		if @Retain_Days >0 
		begin						
					print @Month_St_Date
					set @StartDiffDay = datediff(d,@Month_St_Date,@Ret_Start_Date)
					print 'Start differnce days :'							
					print @StartDiffDay
						
					if @StartDiffDay>0 
						begin
						print'Retaining start date'
							set @Month_St_Date = @Ret_Start_Date
							print @Month_St_Date
						end
					set @EndDiffDay = datediff(d,@Month_end_Date,@Ret_End_Date)
					print 'End differnce days :'
					print	@EndDiffDay
					if @EndDiffDay<0 
						begin
						print 'last differnce Count'
							set @Month_End_Date = @Ret_End_Date
						end
							
					set @DiffDay = datediff(d,@Month_St_Date,@Month_end_Date)+1				
					set @TotDiffDay = @TotDiffDay+@DiffDay 	
					Exec P0210_Retaining_Monthwise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@Month_St_Date,@Mon_Start_date=@Month_St_Date,@Mon_end_Date=@Month_end_Date,@Days =@DiffDay, @Month_day = @Month_day,@Tot_Retain_Days = @TotDiffDay,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP'
					set @Count =@Count+1
					print'count :' print @Count
					set @Retain_Days=@Retain_Days-@DiffDay
					print 'Remaining Retain days1 :'
					print @Retain_Days
					
					if(@Retain_Days>0)					
							begin
							set @Month_St_Date = dateadd(m,1,@Month_St_Date)
							select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Month_St_Date),Year(@Month_St_Date))
	
							select @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Month_St_Date),Year(@Month_St_Date))	
							set @DiffDay = datediff(d,@Month_St_Date,@Month_end_Date)+1
							set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
								
							set @EndDiffDay = datediff(d,@Month_end_Date,@Ret_End_Date) +1
							print 'End different days :'
							print	@EndDiffDay
							print 'month Retain days :'							
							print  @DiffDay
							while @DiffDay< @Retain_Days
							begin
								set @DiffDay = datediff(d,@Month_St_Date,@Month_end_Date)+1	
								set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
								
								set @TotDiffDay = @TotDiffDay+@DiffDay 						
								Exec P0210_Retaining_Monthwise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@Month_St_Date,@Mon_Start_date=@Month_St_Date,@Mon_end_Date=@Month_end_Date,@Days =@DiffDay,@Month_day = @Month_day,@Tot_Retain_Days = @TotDiffDay,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP'
								set @Count =@Count+1
								print'Second count :' print @Count
								set @Month_St_Date = dateadd(m,1,@Month_St_Date)
								set @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Month_St_Date),Year(@Month_St_Date))	
							 print @Month_St_Date
							 print @Month_end_Date
							 set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
								print  @Month_day
							 set @Retain_Days=@Retain_Days-@DiffDay	
							 print'Remain period'
							 print @Retain_Days
							end
							if( @Retain_Days >0 )
							begin
								set @Month_end_Date =@Ret_End_Date									
								set @DiffDay = datediff(d,@Month_St_Date,@Ret_End_Date) +1
								print'last retain Days3 =' print @DiffDay								
								set @TotDiffDay = @TotDiffDay+@DiffDay 	
								Exec P0210_Retaining_Monthwise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@Month_St_Date,@Mon_Start_date=@Month_St_Date,@Mon_end_Date=@Month_end_Date,@Days =@DiffDay,@Month_day = @Month_day,@Tot_Retain_Days = @TotDiffDay,@tran_type='I',@Tran_ID=@Tran_ID,@remarks='TEMP'
								set @Count =@Count+1
								print'last count :' print @Count
								
							end
						end
				--set @Retain_Days=@Retain_Days-@DiffDay
					print 'final retain period' print @Retain_Days
		end
			------------------------------------------------------
	if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Emp' and type='U')
    begin
		delete  from #Temp_Emp
    end
		--Create Table #Temp_Emp
  --   (
		--Emp_ID NUMERIC ,     
		--Branch_ID NUMERIC,
		--Grd_ID numeric,
		--Join_Date Datetime,
		--Start_Date Datetime,
		--End_Date Datetime,
		--Period Numeric(18,2),
		--Basic_Salary numeric(18,2),
		--mode varchar(50),
		--Amount numeric(18,2),
		--Net_Amount Numeric(18,2),
		--Ad_id numeric,
		--Other_Amount Numeric(18,2)
		--,Tran_Id integer
	 --)
    
   insert into #Temp_Emp
	select E.Emp_ID,I.Branch_ID,I.Grd_ID,E.Date_Of_Join,Re.Start_Date,Re.End_Date, isnull(DateDiff(DAY,Re.Start_Date,Re.End_Date),0),isnull(I.Basic_Salary,0),'',0,0,@Ad_Id,0 ,Re.Tran_Id
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
    
	 --------------
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
    
    --select * from #Temp_Emp
	------------------------
		declare @curemp_id as Numeric
		 Declare @curCal_Month as DateTime
		 Declare @curMon_Start_Date as DateTime
		 Declare @curMon_end_Date as DateTime
		 Declare @curdays as Numeric
		 Declare @curMonth_day as Numeric
		 Declare @curTot_Retain_Days as Numeric
		
  Declare Curs_Retain cursor for	                  
	select emp_id,Cal_Month, Mon_Start_Date,Mon_end_Date, days, Month_day, Tot_Retain_Days from T0210_Retaining_Monthwise_Payment where Emp_id = @emp_Id order by Tot_Retain_Days
	Open Curs_Retain
	Fetch next from Curs_Retain into @curemp_id,@curCal_Month, @curMon_Start_Date,@curMon_end_Date, @curdays, @curMonth_day, @curTot_Retain_Days
	While @@fetch_status = 0                    
			Begin     
   
						 declare @curCMP_ID as Numeric
						 Declare @curSlab_id as Numeric
						 Declare @curSlab_Per as Numeric
						 Declare @curFrom_Limit as Numeric(18,2)
						 Declare @curTo_Limit as Numeric(18,2)
						 Declare @curMode as Nvarchar(10)
						 Declare @curAmount as numeric(18,2)   
    
						Declare Curs_Slab cursor for	                  
						select CMP_ID,RRateDetail_ID,Amount,From_Limit,To_Limit,Mode,Amount from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID
						Open Curs_Slab
						Fetch next from Curs_Slab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount
						While @@fetch_status = 0                    
							Begin     
    
						if @curMode = 'AMT' 
						begin
						 update #temp_Retaining_Monthwise_Payment 
						 set mode='AMT', 
						 slab_Id =@curSlab_id , 
						 Slab_Per = @curSlab_Per , 
						 Per_Day_Salary = @curSlab_Per/@curMonth_day ,
						 Retain_Amount = Per_Day_Salary *@curdays,
						 Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)

						 where Tot_Retain_Days >=@curFrom_Limit and Tot_Retain_Days <= @curTo_Limit and Emp_Id= @curemp_id 
						 and cast(Cal_Month  as Date )=cast(@curCal_Month as Date)  
						end
						else 
						begin
						 update #temp_Retaining_Monthwise_Payment 
						  set mode='%',slab_Id =@curSlab_id , Slab_Per = @curSlab_Per,
						  Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID),
						  Per_Day_Salary =(select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/@curMonth_day,
						  Retain_Amount = (((select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/@curMonth_day) * @curdays) *@curSlab_Per/100
							where Tot_Retain_Days >=@curFrom_Limit and Tot_Retain_Days <= @curTo_Limit and Emp_Id= @curemp_id 
						 and cast(Cal_Month  as Date )=cast(@curCal_Month as Date)  
   						end
    
						fetch next from Curs_Slab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount	
						end
						close Curs_Slab                    
						deallocate Curs_Slab
						--------------------------------------

	
   
	fetch next from Curs_Retain into @curemp_id,@curCal_Month, @curMon_Start_Date,@curMon_end_Date, @curdays, @curMonth_day, @curTot_Retain_Days
	end
	close Curs_Retain                    
	deallocate Curs_Retain
	end
	------------------------------------------------------		
	select * from #temp_Retaining_Monthwise_Payment
	if exists (select 1 from #temp_Retaining_Monthwise_Payment WITH (NOLOCK) where Emp_id=@emp_Id and cast(Mon_Start_date as date) >= @Ret_Start_Date and cast(Mon_End_date as date) <= @Ret_End_Date and tran_id= @Tran_ID)
    begin
 	update #Temp_Emp
    set Amount= (select sum(Retain_Amount) from #temp_Retaining_Monthwise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	, Mode= (select Distinct(mode) from #temp_Retaining_Monthwise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	where Emp_id = @emp_Id and  tran_id= @Tran_ID	
    end
   
	end
	-----------
	--select * from T0210_Retaining_Monthwise_Payment where  Emp_id = @emp_Id  and  tran_id= @Tran_ID order by Tot_Retain_Days
	--select * from #Temp_Emp where Emp_id = @emp_Id and Tran_id = @Tran_ID
	Return

	