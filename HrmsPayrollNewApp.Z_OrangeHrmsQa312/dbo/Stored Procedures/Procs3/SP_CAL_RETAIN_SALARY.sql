CREATE PROCEDURE [dbo].[SP_CAL_RETAIN_SALARY]

	@Cmp_ID 	numeric ,
	@Ret_Start_Date	Datetime,
	@Ret_End_Date	Datetime ,
	@emp_Id		Numeric,
	@Grd_Id Numeric,
	@AD_ID Numeric,
	@Tran_ID integer, 
	@Ret_Count integer 
	
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
		Declare @MnLock_Tran_id integer
		Declare @Emp_Ret_Count integer
		declare @New_Ret_cnt_MNLOCK integer 
		declare @old_MNLOCK_Tran_id  integer
		declare @New_MNLOCK_Tran_id  integer 

		--print @Ret_Start_Date
			
		select @MnLock_St_Date = MN.From_Date,@MnLock_end_Date = MN.To_Date  , @MnLock_Tran_id= MN.Tran_Id
		from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  @Ret_Start_Date between MN.From_Date and MN.To_Date
	
		---------------------------------------------------------------
		if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Emp' and type='U')
		begin
			delete  from #Temp_Emp
		end		


   insert into #Temp_Emp
	select E.Emp_ID,Q_I.Branch_ID,Q_I.Grd_ID,E.Date_Of_Join,Re.Start_Date,Re.End_Date, isnull(DateDiff(DAY,Re.Start_Date,Re.End_Date)+1,0),
	isnull(Q_I.Basic_Salary,0),'',0,0,@Ad_Id,0 ,Re.Tran_Id,(select count (*) from T0100_EMP_RETAINTION_STATUS where  emp_id= Re.Emp_ID and Cmp_Id = @Cmp_ID) as ret_count ,0
		from  T0100_EMP_RETAINTION_STATUS Re inner join
     T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = Re.Emp_ID and E.Cmp_Id=Re.Cmp_Id and Re.Is_Retain_ON = 0 AND e.Emp_ID = @emp_Id and Re.Tran_Id =@Tran_ID
	--inner join  T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID = E.Increment_ID
	   INNER JOIN (SELECT I.Increment_ID, I.Branch_ID,I.Grd_ID,I.Basic_Salary
					   FROM   t0095_increment I 
							  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= @Ret_End_Date AND cmp_id = @Cmp_ID and Emp_ID =@emp_Id
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
										  )Q_I 
					ON E.emp_id =  Re.Emp_ID
	
 -- if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_other' and type='U')
 --   begin
	--	drop table #Temp_other
 --   end
    
 --   Create Table #Temp_other
 --    (
	--	Emp_ID NUMERIC ,     
	--	Ad_Id NUMERIC,
	--	For_Date Datetime,
	--	E_Ad_percentage Numeric(18,2),
	--	E_Ad_Amount numeric(18,2),
	--	Basic_salary numeric(18,0)
	--)
	
	--insert into #Temp_other
    exec P_Emp_Revised_Allowance_Get_Retaining @cmp_id,@Ret_End_Date,@emp_id
 
  if exists (select 1 from  T0060_EFFECT_AD_MASTER WITH (NOLOCK) where effect_AD_ID=@Ad_Id)
    begin
	
		update #Temp_Emp
					set Other_Amount= TOA.Ad_Amount,
						Basic_Salary = TOA.Basic_Salary
						from #Temp_Emp TEJ inner join 
						(	select SUM(E_Ad_Amount) as Ad_Amount,Emp_id,Basic_Salary from 
							Temp_other_Allowance T inner join T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) 
							on T.Ad_Id = Ead.AD_ID  and EFFECT_AD_ID =@Ad_Id 
							group by Emp_id   ,Basic_Salary
						)
					TOA on TEJ.Emp_ID = Toa.Emp_ID  and End_Date = @Ret_End_Date and tran_Id =@Tran_ID	
					
	end
	
		-----------------------------------------------------------------
		update #Temp_Emp 
		set Emp_Ret_Count = R_Cnt.Ret_Cnt		
		from #Temp_Emp TEMP inner join 
						(	select ROW_NUMBER () Over(order by Ret.Start_Date) as Ret_Cnt , Ret.Emp_id , Ret.Tran_Id from T0100_EMP_RETAINTION_STATUS Ret ,Temp_Emp_Retain t where Ret.Emp_id =  t.Emp_ID and 
							Ret.Start_Date >= (select From_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.Start_Date between MN.From_Date and MN.To_Date) 	
							and Ret.End_Date <= (select To_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.End_Date between  MN.From_Date and MN.To_Date ) 
							Group by Ret.Emp_id , Ret.Start_Date ,Ret.Tran_Id							
						)
					R_Cnt on TEMP.Emp_ID = R_Cnt.Emp_ID	 and TEMP.Tran_Id = R_Cnt.Tran_ID	

		-------------------------------------------------------------------------

				
		delete from T0210_Retaining_MonthLock_Details
		delete from T0210_Retaining_Datewise_Payment where remarks='TEMP'

	
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
		set @MnLock_Slab_STdate = @Ret_Start_Date
	--	declare @MonLock_Trans_Id as integer
	
			--------Increment New logic-------
						 if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Emp_INC_RET_Dates' and type='U')
							begin
									drop table #Temp_Emp_INC_RET_Dates
							end
							
							declare @New_BasicAmt as numeric(18,2)												

							select I.Increment_ID, I.Branch_ID,I.Grd_ID,I.Basic_Salary ,I.Emp_Id , I.increment_effective_date  as 'Inc_From_Date'  ,Re.End_Date as 'Inc_To_Date',  
							Re.Start_Date as 'Ret_Start_Date', Re.End_Date  as 'Ret_End_Date'  , 0 as 'Other_Amount' into #Temp_Emp_INC_RET_Dates 
							from  T0100_EMP_RETAINTION_STATUS Re inner join  t0095_increment I on  I.Emp_ID  =Re.Emp_ID  where Re.Emp_ID =@emp_Id and Re.Cmp_ID =@Cmp_ID
						
						 --   update #Temp_Emp_INC_RET_Dates 
							--set Inc_To_Date =(Select top 1 increment_effective_date -1 
							--from #Temp_Emp_INC_RET_Dates as it , t0095_increment I where   I.Emp_ID  =@emp_Id  and I.Cmp_ID =@Cmp_ID
							--and  increment_effective_date >= it.Inc_From_Date   and I.Increment_Id >it.Increment_Id)
-------------------------------------------------------------------------------------------------------------------------------------------------
							--	select * from #Temp_Emp where 	Emp_ID  =@emp_Id

							update #Temp_Emp_INC_RET_Dates 
							set Other_Amount =(Select top 1 Other_Amount  from #Temp_Emp where Emp_ID  =@emp_Id)
						
					--select * from #Temp_Emp_INC_RET_Dates						
		-----------------------------------------------------------------------------------------------------------------------------------------
	

	if(@Ret_Count= 1)
		begin
			print 'for RetCount = 1'
			print @Emp_Id
			delete from T0210_Retaining_MonthLock_Details
			set @MnLock_Slab_STdate = @Ret_Start_Date

			Declare Curs_MNLOCKSlab cursor for	  
			select M.CMP_ID,D.RRateDetail_ID  ,amount,From_Limit,To_Limit, D.Mode, amount
						from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
						where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID  and M.Effective_date <=@Ret_Start_Date
						 order by  Effective_date desc, From_Limit

			--select CMP_ID,RRateDetail_ID,Amount,From_Limit,To_Limit,Mode,Amount 
			--from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
			--where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID 
			--order by From_Limit

				Open Curs_MNLOCKSlab
				Fetch next from Curs_MNLOCKSlab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount
				While @@fetch_status = 0                    
				Begin
			
					set @MnLock_Slab_Enddate = dateadd(d,@curTo_Limit-1,@MnLock_Slab_STdate)					
				
					insert into T0210_Retaining_MonthLock_Details ( tran_id,cmp_id,Retain_start_date,Retain_end_date, Retain_Slab_start_Date,Retain_Slab_end_Date 
					, days,Slab_id, Slab_per, mode,Mnlock_StDate,Mnlock_EndDate, MnLock_id )
							values (@COUNT,@Cmp_ID,@Ret_Start_Date,@Ret_End_Date,@MnLock_Slab_STdate,@MnLock_Slab_Enddate,@Retain_Days
							, @curSlab_id,@curSlab_Per,@curMode ,@MnLock_St_Date ,@MnLock_end_Date, @MnLock_Tran_id )

					set @MnLock_Slab_STdate = @MnLock_Slab_Enddate +1
					--print @MnLock_Slab_STdate
					
				
				fetch next from Curs_MNLOCKSlab into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount	
				end
				close Curs_MNLOCKSlab                    
				deallocate Curs_MNLOCKSlab
			---------------------------------------
			--Retaining calculation start

				set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1
				set @for_Date =@Ret_Start_Date
				Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))
				select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))			
				set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
					set @Count = 1
					--print @Retain_Days
					set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1


					if @Retain_Days >0 
						begin
							while @for_Date<= @Ret_end_Date
							begin			
									--print @for_Date
									

								select @MNLock_slab_id= Slab_Id, @MNLock_slab_per = Slab_per , @MNLock_mode = mode , @MnLock_Tran_id = Mnlock_Id 
								from T0210_Retaining_MonthLock_Details 
								where  @for_date between Retain_Slab_start_Date and Retain_Slab_end_Date 
				
								Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@for_Date),Year(@for_Date))
								select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@for_Date),Year(@for_Date))			
								set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1

							--	print 'retain per' print @MNLock_slab_per print @MNLock_slab_id
								--@for_Date between Retain_Slab_start_Date and Retain_Slab_end_Date
								Exec P0210_Retaining_Datewise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@For_date,@Mon_Start_date=@Ret_Start_Date,@Mon_end_Date=@Ret_End_Date,@Days =@Count, @Month_day = @Month_day,@Tot_Retain_Days = @Retain_Days,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP',@AD_ID=@Ad_ID,@Retain_date=@For_date,
								@Slab_Id = @MNLock_slab_id, @Slab_Per = @MNLock_slab_per, @mode = @MNLock_mode,@MonLock_Trans_Id=@MnLock_Tran_id,@Emp_Ret_Count= @Ret_Count
								
								--
						----------Increment New logic-------
						
								 select top 1 @New_BasicAmt  = isnull(Basic_Salary,0)+isnull(Other_Amount,0)  from #Temp_Emp_INC_RET_Dates I where  Emp_ID =@emp_Id  and  I.Inc_From_Date <=@For_Date  order by Inc_From_Date desc
			
								--print @New_BasicAmt
								--print @For_Date
								update T0210_Retaining_Datewise_Payment set Basic_Amount =@New_BasicAmt where Retain_date = @for_Date and Emp_id = @emp_Id
								
								----------------------------------------
								-----Calculation for new RateSlab per effective date 
								--if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Rate_Slabs_New' and type='U')
								--	begin
								--			drop table #Temp_Rate_Slabs_New
								--	end

								--	Truncate  Table Temp_Rate_Slabs_New
									
								--	insert into Temp_Rate_Slabs_New 
								--	select  M.CMP_ID,D.RRateDetail_ID  ,amount,From_Limit,To_Limit, D.Mode, M.Effective_date, dateadd(d,From_Limit-1,M.Effective_date) as  Effective_FromDate, dateadd(d,To_Limit-1,M.Effective_date) as Effective_EndDate 

								--	from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
								--	where M.RRate_Id = D.RRate_ID and M.ad_id= @AD_ID and M.Grd_ID=@Grd_Id  and M.Effective_date <=@for_Date
								--	order by  Effective_date desc, From_Limit

								--	if( @for_Date >=(select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  ))
								--	begin
								--	select Top 1  @MNLock_slab_id= RRate_ID, @MNLock_slab_per = amount , @MNLock_mode = mode 
								--	from Temp_Rate_Slabs_New 
								--	where  @for_date between Effective_FromDate and Effective_EndDate  
								--	and Effective_Date = (select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  )
								--	and Effective_Date <= @Ret_Start_Date

								--	update T0210_Retaining_Datewise_Payment set Slab_Id = @MNLock_slab_id, Slab_Per = @MNLock_slab_per, mode = @MNLock_mode
								--	where Retain_date = @for_Date and Emp_id = @emp_Id

								--	end
							--------------------------------------

								set @for_Date =dateadd(dd,1,@for_Date)
								set @Count =@Count+1
								set @Retain_Days = @Retain_Days-1
								--print @Retain_Days			
							end 
						end
			
			end
			--------------------------------------
	
else 	
if	(@Ret_Count> 1)
			begin
				print 'for RetCount  >1'
				print @Ret_Count
				print @emp_id

				delete from T0210_Retaining_MonthLock_Details
				--delete from T0210_Retaining_Datewise_Payment where Emp_Id =@emp_Id

				-----------------
				Declare  @New_Emp_Ret_Count as integer
				Declare  @Temp_Emp_Ret_Count as integer
				set @New_Emp_Ret_Count =1 

				--select  @Temp_Emp_Ret_Count = ROW_NUMBER () Over(order by t.Start_Date)			
				--	from 		Temp_Emp_Retain t , T0090_Retaining_Lock_Setting MON where t.Emp_id = @emp_Id					
				--			and  MON.Cmp_Id = @Cmp_ID and  MON.From_Date between  @Ret_Start_Date and @Ret_End_Date
				--			and MON.To_Date between @Ret_Start_Date  and @Ret_End_Date 
				--			and  t.Start_Date between  MON.From_Date and MON.To_Date  and t.End_Date between  MON.From_Date and MON.To_Date 
				--			Group by t.Emp_id , t.Start_Date ,t.Tran_Id, MON.Tran_Id
							
							print  @Temp_Emp_Ret_Count

					if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_ret_count' and type='U')
									begin
											drop table #Temp_ret_count
									end
				--drop table #Temp_ret_count
				select ROW_NUMBER () Over(order by Ret.Start_Date) as Ret_Cnt , Ret.Emp_id , count (Ret.Emp_id) as cnt , Ret.Tran_Id  into #Temp_ret_count  
							from T0100_EMP_RETAINTION_STATUS Ret ,Temp_Emp_Retain t ,T0090_Retaining_Lock_Setting MON  where Ret.Emp_id =  t.Emp_ID and 
							Ret.Start_Date >= (select From_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.Start_Date between MN.From_Date and MN.To_Date) 	
							and Ret.End_Date <= (select To_Date from T0090_Retaining_Lock_Setting MN where MN.Cmp_Id = @Cmp_ID and  Ret.End_Date between  MN.From_Date and MN.To_Date ) 
							and  Ret.Start_Date between  MON.From_Date and MON.To_Date  and t.End_Date between  MON.From_Date and MON.To_Date 
							--and Ret.Tran_Id = @Tran_ID
							Group by Ret.Emp_id , Ret.Start_Date ,Ret.Tran_Id,MON.Tran_Id
						
						--select * from #Temp_ret_count

						select  @Temp_Emp_Ret_Count = Ret_Cnt from #Temp_ret_count  where Tran_Id = @Tran_ID
						if(isnull(@Temp_Emp_Ret_Count,0)>1)	
						begin 
						set @New_Emp_Ret_Count = @Temp_Emp_Ret_Count
						end
					--	print @New_Emp_Ret_Count
					print 'New Ret Count as per Fin Year'
				print @New_Emp_Ret_Count

				if(@New_Emp_Ret_Count = 1)
				begin
						delete from T0210_Retaining_MonthLock_Details
						set @MnLock_Slab_STdate = @Ret_Start_Date

						Declare Curs_MNLOCKSlab_Same cursor for	 
						select  M.CMP_ID,D.RRateDetail_ID  ,amount,From_Limit,To_Limit, D.Mode, amount
						from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
						where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID  and M.Effective_date <=@Ret_Start_Date
						order by  Effective_date desc, From_Limit

						
						--select CMP_ID,RRateDetail_ID,Amount,From_Limit,To_Limit,Mode,Amount 
						--from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
						--where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID  
						--order by From_Limit

						Open Curs_MNLOCKSlab_Same
						Fetch next from Curs_MNLOCKSlab_Same into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount
						While @@fetch_status = 0                    
						Begin
			
								set @MnLock_Slab_Enddate = dateadd(d,@curTo_Limit-1,@MnLock_Slab_STdate)					
				
								insert into T0210_Retaining_MonthLock_Details ( tran_id,cmp_id,Retain_start_date,Retain_end_date, Retain_Slab_start_Date,Retain_Slab_end_Date 
								, days,Slab_id, Slab_per, mode,Mnlock_StDate,Mnlock_EndDate, MnLock_id )
									values (@COUNT,@Cmp_ID,@Ret_Start_Date,@Ret_End_Date,@MnLock_Slab_STdate,@MnLock_Slab_Enddate,@Retain_Days
									, @curSlab_id,@curSlab_Per,@curMode ,@MnLock_St_Date ,@MnLock_end_Date, @MnLock_Tran_id )

								set @MnLock_Slab_STdate = @MnLock_Slab_Enddate +1
							--print @MnLock_Slab_STdate
					
					--select * from T0210_Retaining_MonthLock_Details

				fetch next from Curs_MNLOCKSlab_Same into @curCMP_ID,@curSlab_id,@curSlab_Per,@curFrom_Limit,@curTo_Limit,@curMode,@curAmount	
				end
				close Curs_MNLOCKSlab_Same                    
				deallocate Curs_MNLOCKSlab_Same
			---------------------------------------
			--Retaining calculation start
				set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1
				set @for_Date =@Ret_Start_Date
				Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))
				select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))			
				set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
					set @Count = 1
					--print @Retain_Days
					set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1

					if @Retain_Days >0 
						begin
							while @for_Date<= @Ret_end_Date
							begin			
								
								select @MNLock_slab_id= Slab_Id, @MNLock_slab_per = Slab_per , @MNLock_mode = mode , @MnLock_Tran_id = Mnlock_Id 
								from T0210_Retaining_MonthLock_Details 
								where  @for_date between Retain_Slab_start_Date and Retain_Slab_end_Date 

										
								Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@for_Date),Year(@for_Date))
								select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@for_Date),Year(@for_Date))			
								set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1

							--	print 'retain per' print @MNLock_slab_per print @MNLock_slab_id
								--@for_Date between Retain_Slab_start_Date and Retain_Slab_end_Date
								Exec P0210_Retaining_Datewise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@For_date,@Mon_Start_date=@Ret_Start_Date,@Mon_end_Date=@Ret_End_Date,@Days =@Count, @Month_day = @Month_day,@Tot_Retain_Days = @Retain_Days,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP',@AD_ID=@Ad_ID,@Retain_date=@For_date,
								@Slab_Id = @MNLock_slab_id, @Slab_Per = @MNLock_slab_per, @mode = @MNLock_mode,@MonLock_Trans_Id=@MnLock_Tran_id,@Emp_Ret_Count= @New_Emp_Ret_Count
								
								----------Increment New logic-------
						
								 select top 1 @New_BasicAmt  = isnull(Basic_Salary,0)+isnull(Other_Amount,0)  from #Temp_Emp_INC_RET_Dates I where  Emp_ID =@emp_Id  and  I.Inc_From_Date <= @For_Date  order by Inc_From_Date desc
			
								--print @New_BasicAmt
								--print @For_Date
								update T0210_Retaining_Datewise_Payment set Basic_Amount =@New_BasicAmt where Retain_date = @for_Date and Emp_id = @emp_Id

								-------------------------------------------------

								-------Calculation for new RateSlab per effective date 
									--Truncate  Table Temp_Rate_Slabs_New
									
									--insert into Temp_Rate_Slabs_New 
									--select  M.CMP_ID,D.RRateDetail_ID  ,amount,From_Limit,To_Limit, D.Mode, M.Effective_date, dateadd(d,From_Limit-1,M.Effective_date) as  Effective_FromDate, dateadd(d,To_Limit-1,M.Effective_date) as Effective_EndDate 

									--from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
									--where M.RRate_Id = D.RRate_ID and M.ad_id= @AD_ID and M.Grd_ID=@Grd_Id  and M.Effective_date <=@for_Date
									--order by  Effective_date desc, From_Limit									
										
									
									--if( @for_Date >=(select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  ))
									--print @for_Date
									--begin
									--select Top 1  @MNLock_slab_id= RRate_ID, @MNLock_slab_per = amount , @MNLock_mode = mode 
									--from Temp_Rate_Slabs_New 
									--where  @for_date between Effective_FromDate and Effective_EndDate  and Effective_Date = (select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  )

									--update T0210_Retaining_Datewise_Payment set Slab_Id = @MNLock_slab_id, Slab_Per = @MNLock_slab_per, mode = @MNLock_mode
									--where Retain_date = @for_Date and Emp_id = @emp_Id
									--End


							----------------------------------------
							set @for_Date =dateadd(dd,1,@for_Date)
							set @Count =@Count+1
							set @Retain_Days = @Retain_Days-1
							--print @Retain_Days			
							end 
						end
			
			end
			--------------------------------------
				
				else 
				Begin
				print 'for RetCount >1 and NewRetCount >1'
				print @Ret_Count
				print @emp_id

				Declare Curs_MNLOCKSlab_RetCnt cursor for	 			
			--	select  M.CMP_ID,D.RRateDetail_ID  ,max (amount) as amount, D.Mode,max (amount) as amount
			--	from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
			--	where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID  and M.Effective_date <=@Ret_Start_Date
			----	group by M.CMP_ID, M.ad_id,M.Grd_ID ,D.RRateDetail_ID ,D.Mode order by From_Limit

					select M.CMP_ID,D.RRate_ID  ,max (amount) as amount, D.Mode,max (amount) as amount
				from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
				where M.RRate_Id = D.RRate_ID and M.ad_id= @ad_id and M.Grd_ID=@Grd_ID and M.Effective_date <=@Ret_Start_Date
				group by M.CMP_ID, M.ad_id,M.Grd_ID ,D.RRate_ID ,D.Mode 

					Open Curs_MNLOCKSlab_RetCnt
					Fetch next from Curs_MNLOCKSlab_RetCnt into @curCMP_ID,@curSlab_id,@curSlab_Per,@curMode,@curAmount
					While @@fetch_status = 0                    
					Begin  				
				 
						set @MnLock_Slab_Enddate = @Ret_End_Date
						--print 'start insert 2 Month lock '				
						insert into T0210_Retaining_MonthLock_Details ( tran_id,cmp_id,Retain_start_date,Retain_end_date, Retain_Slab_start_Date,Retain_Slab_end_Date 
																	, days,Slab_id, Slab_per, mode,Mnlock_StDate,Mnlock_EndDate, MnLock_id )
								values (@COUNT,@Cmp_ID,@Ret_Start_Date,@Ret_End_Date,@MnLock_Slab_STdate,@MnLock_Slab_Enddate,@Retain_Days
															, @curSlab_id,@curSlab_Per,@curMode ,@MnLock_St_Date ,@MnLock_end_Date, @MnLock_Tran_id )
						set @MnLock_Slab_STdate = @MnLock_Slab_Enddate +1
						--print @MnLock_Slab_STdate
						
					fetch next from Curs_MNLOCKSlab_RetCnt into @curCMP_ID,@curSlab_id,@curSlab_Per,@curMode,@curAmount	
					end
					close Curs_MNLOCKSlab_RetCnt                    
					deallocate Curs_MNLOCKSlab_RetCnt
		
				--------------------------------------	
	
				set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1
				set @for_Date =@Ret_Start_Date
				Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))
				select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@Ret_Start_Date),Year(@Ret_Start_Date))			
				set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1
				set @Count = 1

				print @Retain_Days
				set @Retain_Days = datediff(d,@Ret_Start_Date,@Ret_End_Date) +1

				if @Retain_Days >0 
				begin
							while @for_Date<= @Ret_end_Date
							begin			
				
								select @MNLock_slab_id= Slab_Id, @MNLock_slab_per = Slab_per , @MNLock_mode = mode , @MnLock_Tran_id = Mnlock_Id 
								from T0210_Retaining_MonthLock_Details 
								where  @for_date between Retain_Slab_start_Date and Retain_Slab_end_Date 
				
								Select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@for_Date),Year(@for_Date))
								select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@for_Date),Year(@for_Date))			
								set @Month_day = datediff(d,@Month_St_Date,@Month_End_Date) +1

								Exec P0210_Retaining_Datewise_Payment @Cmp_ID= @Cmp_ID,@Emp_Id =@Emp_Id,@Cal_Month =@For_date,@Mon_Start_date=@Ret_Start_Date,@Mon_end_Date=@Ret_End_Date,@Days =@Count, @Month_day = @Month_day,@Tot_Retain_Days = @Retain_Days,@tran_type='I', @Tran_ID=@Tran_ID,@remarks='TEMP',@AD_ID=@Ad_ID,@Retain_date=@For_date,
								@Slab_Id = @MNLock_slab_id, @Slab_Per = @MNLock_slab_per, @mode = @MNLock_mode,@MonLock_Trans_Id=@MnLock_Tran_id ,@Emp_Ret_Count= @Ret_Count
								-------------------
									----------Increment New logic-------
						
								 select top 1 @New_BasicAmt  = isnull(Basic_Salary,0)+isnull(Other_Amount,0)  from #Temp_Emp_INC_RET_Dates I where  Emp_ID =@emp_Id  and  I.Inc_From_Date <= @For_Date  order by Inc_From_Date desc
			
								--print @New_BasicAmt
								--print @For_Date
								update T0210_Retaining_Datewise_Payment set Basic_Amount =@New_BasicAmt where Retain_date = @for_Date and Emp_id = @emp_Id
								
								----------------------------------------

								-------Calculation for new RateSlab per effective date 
								--if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_Rate_Slabs_New' and type='U')
								--	begin
								--			drop table #Temp_Rate_Slabs_New
								--	end
									--Truncate  Table Temp_Rate_Slabs_New
									
									--insert into Temp_Rate_Slabs_New 
									--select  M.CMP_ID,D.RRateDetail_ID  ,amount,From_Limit,To_Limit, D.Mode, M.Effective_date, dateadd(d,From_Limit-1,M.Effective_date) as  Effective_FromDate, dateadd(d,To_Limit-1,M.Effective_date) as Effective_EndDate 
									--from T0051_Retaintion_Rate_Details D, T0050_Retaintion_Rate_Master M 
									--where M.RRate_Id = D.RRate_ID and M.ad_id= @AD_ID and M.Grd_ID=@Grd_Id  and M.Effective_date <=@for_Date
									--order by  Effective_date desc, From_Limit

									--if( @for_Date >=(select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  ))
									--begin

									--select Top 1  @MNLock_slab_id= RRate_ID, @MNLock_slab_per = amount , @MNLock_mode = mode 
									--from Temp_Rate_Slabs_New 
									--where  @for_date between Effective_FromDate and Effective_EndDate  and Effective_Date = (select  max(Effective_Date) from Temp_Rate_Slabs_New where  @for_Date between Effective_FromDate and Effective_EndDate  )

									--update T0210_Retaining_Datewise_Payment set Slab_Id = @MNLock_slab_id, Slab_Per = @MNLock_slab_per, mode = @MNLock_mode
									--where Retain_date = @for_Date and Emp_id = @emp_Id
									--end

							----------------------------------------
								-------------------
								
								set @for_Date =dateadd(dd,1,@for_Date)
								set @Count =@Count+1
								set @Retain_Days = @Retain_Days-1
								--print @Retain_Days			
							end 
						end
		End
		ENd
-------------------------------

	declare @curemp_id as Numeric
	Declare @curCal_Month as DateTime
	Declare @curdays as Numeric
	Declare @curMonth_day as Numeric
	Declare @curTran_id as integer
	Declare @curStart_Date as DateTime
	Declare @curEnd_Date as DateTime
	Declare @curPeriod as Numeric

	Declare Curs_Retain cursor for	                  
	select emp_id,tran_id from #Temp_Emp   
	Open Curs_Retain
	Fetch next from Curs_Retain into @curemp_id,@curTran_id
	While @@fetch_status = 0                    
	Begin   	
		
		  --Basic_Amount= (select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID),
						  --Per_Day_Salary =(select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day,
						  --Retain_Amount = (((select (Basic_Salary + Other_Amount) as Ad_Amount from #Temp_Emp where Emp_ID= @emp_Id and tran_id = @Tran_ID)/Month_Day) * 1) *Slab_Per/100				

					update T0210_Retaining_Datewise_Payment 
				    set  
					  		 Per_Day_Salary = Basic_Amount /Month_Day,
							 Retain_Amount = ((Basic_Amount/Month_Day) * 1) *Slab_Per/100				
							,Remarks='FINAL'
					where  Emp_Id= @curemp_id  and tran_id = @curTran_id 
		
			fetch next from Curs_Retain into  @curemp_id,@curTran_id
	end
	close Curs_Retain                    
	deallocate Curs_Retain
	end
	
	if exists (select 1 from  T0210_Retaining_Datewise_Payment WITH (NOLOCK) where Emp_id=@emp_Id and cast(Mon_Start_date as date) >= @Ret_Start_Date and cast(Mon_End_date as date) <= @Ret_End_Date and tran_id= @Tran_ID)
    begin
 	update #Temp_Emp
    set Amount= (select round(sum(Retain_Amount),0) from T0210_Retaining_Datewise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	, Mode= (select top 1 mode from T0210_Retaining_Datewise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)
	,MonLock_Trans_Id = (select top 1 MonLock_Trans_Id from T0210_Retaining_Datewise_Payment where Emp_id = @emp_Id and  tran_id= @Tran_ID)

	where Emp_id = @emp_Id and  tran_id= @Tran_ID	

	--select * from #Temp_Emp
    end  
    Return

