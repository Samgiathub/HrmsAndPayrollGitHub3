
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[CALCULATE_AD_AMOUNT_SLAB_WISE_FOR_EMP_APP]
	@Cmp_ID					Int ,
	@Emp_Tran_ID            bigint, 
	@Emp_Application_ID     Int ,
	@AD_ID					Int,
	@For_date				Datetime,
	@CALCULATED_AMOUNT		NUMERIC(18,2)OUTPUT,
	@AMOUNT					NUMERIC(18,2) = 0 OUTPUT,
	@Working_Days			Numeric(18,2) = 0, --Added by Gadriwala Muslim 16022015
	@Salary_Cal_Day			Numeric(18,2) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	---Commented by Hardik 13/02/2016 for Speed Issue
	--if exists(select 1 from sys.triggers where is_disabled=1) --for sql 2005 added by hasmukh 
	----	if not exists(select 1 from sysobjects a join sysobjects b on a.parent_obj=b.id where a.type = 'tr' AND A.STATUS & 2048 = 0) -- for sql 2000
	--begin		
	--	exec sp_msforeachtable 'Create TABLE ? ENABLE TRIGGER all'
	--	--set @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
	--	--return 
	--end
	
	Declare @From_Slab	Numeric(27,2)
	Declare @To_Slab	Numeric(27,2)
	Declare @AD_Amt		Numeric(27,2)
	Declare @Calc_Type	Varchar(100)
	Declare @Basic_Sal	Numeric(18,2)
	Declare @Gross_Sal	Numeric(18,2)
	Declare @CTC_Sal	Numeric(18,2)	
	Declare @Sal_Calc_Type numeric(18,0) --Added by Gadriwala Muslim 16022015
	
	/* Set @AMOUNT = 0 */ --commented binal 10-April-2019
	 
	Set @From_Slab = 0
	Set @To_Slab = 0
	Set @AD_Amt = 0 
	Set @Calc_Type = ''
	Set @Basic_Sal = 0
	Set @Gross_Sal = 0
	Set @CTC_Sal = 0
	set @Sal_Calc_Type = 0 --Added by Gadriwala Muslim 16022015
	
	select @Basic_Sal = Basic_Salary,@Gross_Sal= Gross_Salary,@CTC_Sal = CTC
		From T0070_EMP_INCREMENT_APP I WITH (NOLOCK) inner join     
			 ( select max(Increment_Id) as Increment_Id , Emp_Tran_ID from T0070_EMP_INCREMENT_APP  WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment
			 where Increment_Effective_date <= @For_Date    
			 and Cmp_ID = @Cmp_ID    
			 group by Emp_Tran_ID) Qry on    
			 I.Emp_Tran_ID = Qry.Emp_Tran_ID 
			 and I.Increment_Id = Qry.Increment_Id    
		Where I.Emp_Tran_ID=@Emp_Tran_ID and I.Emp_Application_ID=@Emp_Application_ID
		--I.Emp_ID = @Emp_ID	
	 
		Declare @Calc_Type1 as varchar(100)
		Declare @OT_Sec as Numeric
		Declare @OT_Hours as varchar(20)
		Declare @OT_Date as datetime

		
		--Declare @Working_Days as numeric(18,2) --Added by Gadriwala Muslim 16022015
		
		--if @Day_Salary > 0 
		--	set @Working_Days = ISNULL(@Basic_Sal / @Day_Salary,0) 	 --Added by Gadriwala Muslim 16022015
		--else
		--	set @Working_Days = @Salary_Cal_Day
		--select @Working_Days as Working_Days ,@Salary_Cal_Day as Salary_Cal_Day
		DECLARE @Slab_Critaria NUMERIC(18,2)
	
		Select Top 1 @Calc_Type1 = Calc_Type from T0040_AD_Slab_Setting WITH (NOLOCK) where Cmp_id = @Cmp_ID and AD_Id = @AD_ID
		order by Tran_id	
				
			
			
		If @Calc_Type1 <> 'OT Hours(Working Days)' And @Calc_Type1 <> 'OT Hours(Weekoff/Holiday)' And @Calc_Type1 <> 'Early In(Minutes)'
			Begin
			
				declare curADM cursor for
					select From_Slab,To_Slab,Amount,Calc_Type,Sal_Calc_Type 
					from	T0040_AD_Slab_Setting WITH (NOLOCK)
					where Cmp_id = @Cmp_ID and AD_Id = @AD_ID
					order by Tran_id	
				open curADM
				fetch next from curADM into @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type
					while @@fetch_status = 0
						begin 
						
							If @Calc_Type = 'Basic'
								Set @CALCULATED_AMOUNT = @Basic_Sal
							Else If @Calc_Type = 'Gross'
								Set @CALCULATED_AMOUNT = @Gross_Sal
							Else If @Calc_Type = 'CTC'
								Set @CALCULATED_AMOUNT = @CTC_Sal
							
							Set @CALCULATED_AMOUNT = ISNULL(@CALCULATED_AMOUNT,0) 
	
							--Added by Nimesh on 11-Jan-2017(To calculate on Payable Days)
							--SET @Slab_Critaria = CASE WHEN @Sal_Calc_Type = 0 THEN @CALCULATED_AMOUNT ELSE @Salary_Cal_Day END
							Set @Slab_Critaria = @CALCULATED_AMOUNT --Added by Hardik 01/02/2018 For GTPL as Slab is working on Amount only not on Days, discussed with Nimesh also
							
							IF @Sal_Calc_Type = 1  -- Payable Days added by  Gadriwala Muslim 16022015 PRORate
								begin
									
										IF @Working_Days > 0 
											set @AD_Amt =   (@AD_Amt / @Working_Days) * @Salary_Cal_Day
								end							
							
							set @AD_Amt = ISNULL(@AD_Amt,0)
							if @To_Slab = 0 
								begin
									--if @CALCULATED_AMOUNT >= @From_Slab 
									if @Slab_Critaria >= @From_Slab 
										BEGIN								
											Set @AMOUNT = Isnull(@AD_Amt,0)								
										END
								end 
							else	
								begin								
									--if @CALCULATED_AMOUNT >= @From_Slab  and @CALCULATED_AMOUNT < (@To_Slab + 1)
									if @Slab_Critaria >= @From_Slab  and @Slab_Critaria < (@To_Slab + 1)
										BEGIN	
											SET @AMOUNT = Isnull(@AD_Amt,0)	
										END 
								end
							
							FETCH NEXT FROM curADM INTO @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type					
						end
				close curADM
				deallocate curADM	
			End
		Else
			Begin
	
				--If OBJECT_ID('tempdb..#Data') IS NULL 
				--	Return
			
				If @Calc_Type1 = 'OT Hours(Working Days)'
					Begin
					
						Set @CALCULATED_AMOUNT = 0
						Set @CALCULATED_AMOUNT = @AMOUNT /*Added Binal 10-April-2019 */
						
						/*
						declare curOT cursor for
							Select For_Date, OT_Sec from #Data 
							where Emp_id = @Emp_ID 
							 And OT_Sec >0 
						open curOT
						fetch next from curOT into @OT_Date,@OT_Sec
						while @@fetch_status = 0
							begin 
								Set @OT_Hours = Replace(dbo.F_Return_Hours(@OT_Sec),':','.')
								
								declare curADM1 cursor for
									select From_Slab,To_Slab,Amount,Calc_Type,Sal_Calc_Type from T0040_AD_Slab_Setting where Cmp_id = @Cmp_ID and AD_Id = @AD_ID
									order by Tran_id	
								open curADM1
								fetch next from curADM1 into @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type
									while @@fetch_status = 0
										begin 
												IF @Sal_Calc_Type = 1  -- Payable Days added by  Gadriwala Muslim 16022015 PRORate
													begin
															IF @Working_Days > 0 
																set @AD_Amt =   (@AD_Amt / @Working_Days) * @Salary_Cal_Day
													end		
													set @AD_Amt = ISNULL(@AD_Amt,0)
											
											if @To_Slab = 0 
												begin
													if @OT_Hours >= @From_Slab 
														BEGIN							
															Set @AMOUNT = @AMOUNT + Isnull(@AD_Amt,0)
															Set @CALCULATED_AMOUNT = @CALCULATED_AMOUNT + @OT_Hours								
														END
												end 
											else	
												begin
												--if @OT_Hours >= @From_Slab  and @OT_Hours < (@To_Slab + 1) --this Condition Commented By Ramiz as it was taking more slabs then enterd from form
													if @OT_Hours >= @From_Slab  and @OT_Hours <= (@To_Slab) --Changed By Ramiz on 08/03/2015 with discussion with Hardik Bhai
														BEGIN							
															Set @AMOUNT = @AMOUNT + Isnull(@AD_Amt,0)
															Set @CALCULATED_AMOUNT = @CALCULATED_AMOUNT + @OT_Hours
														END 
												end
	
											fetch next from curADM1 into @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type					
										end
									close curADM1
									deallocate curADM1	
								fetch next from curOT into @OT_Date,@OT_Sec
							End
							close curOT
							deallocate curOT
						*/
					End
				Else if @Calc_Type1 = 'OT Hours(Weekoff/Holiday)'
					Begin
						Set @CALCULATED_AMOUNT = 0
						Set @CALCULATED_AMOUNT = @AMOUNT /*Added Binal 10-April-2019 */
						/*
						
						declare curOT cursor for
							Select For_Date, Case When Weekoff_OT_Sec  = 0 then Holiday_OT_Sec Else Weekoff_OT_Sec End
							from #Data where Emp_id = @Emp_ID And (Weekoff_OT_Sec > 0 or Holiday_OT_Sec >0)
						open curOT
						fetch next from curOT into @OT_Date,@OT_Sec
						while @@fetch_status = 0
							begin 
								Set @OT_Hours = Replace(dbo.F_Return_Hours(@OT_Sec),':','.')
								
								declare curADM1 cursor for
									select From_Slab,To_Slab,Amount,Calc_Type,Sal_Calc_Type from T0040_AD_Slab_Setting where Cmp_id = @Cmp_ID and AD_Id = @AD_ID
									order by Tran_id	
								open curADM1
								fetch next from curADM1 into @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type
									while @@fetch_status = 0
										begin 
												IF @Sal_Calc_Type = 1  -- Payable Days added by  Gadriwala Muslim 16022015 PRORate
														begin
																IF @Working_Days > 0 
																	set @AD_Amt =   (@AD_Amt / @Working_Days) * @Salary_Cal_Day
														end
												set @AD_Amt = ISNULL(@AD_Amt,0)
											
											if @To_Slab = 0 
												begin
													if @OT_Hours >= @From_Slab 
														BEGIN							
															Set @AMOUNT = @AMOUNT + Isnull(@AD_Amt,0)
															Set @CALCULATED_AMOUNT = @CALCULATED_AMOUNT + @OT_Hours								
														END
												end 
											else	
												begin
													if @OT_Hours >= @From_Slab  and @OT_Hours < (@To_Slab + 1)
														BEGIN							
															Set @AMOUNT = @AMOUNT + Isnull(@AD_Amt,0)	
															Set @CALCULATED_AMOUNT = @CALCULATED_AMOUNT + @OT_Hours
														END 
												end
	
											fetch next from curADM1 into @From_Slab,@To_Slab,@AD_Amt,@Calc_Type,@Sal_Calc_Type					
										end
									close curADM1
									deallocate curADM1	
								fetch next from curOT into @OT_Date,@OT_Sec
							End
							close curOT
							deallocate curOT
						*/
					End
				Else if @Calc_Type1 = 'Early In(Minutes)'
					Begin
						 
						SET @AMOUNT = @AMOUNT
						
						/* SET @AMOUNT = 0
						If Object_ID('Tempdb..#OnTimeArrival') is not null
							Begin
								Drop Table #OnTimeArrival
							End
							
						Create Table #OnTimeArrival
						(
							Emp_ID Numeric(8,0),
							From_Slab Numeric(5,0),
							To_Slab Numeric(5,0),
							Amount Numeric(8,2),
							Early_Count Numeric(5,0),
							Total_Amount Numeric(10,2)
						)
						
						Insert into #OnTimeArrival(Emp_ID,From_Slab,To_Slab,Amount,Early_Count,Total_Amount)
						select @Emp_ID,From_Slab,To_Slab,Amount,0,0
							from T0040_AD_Slab_Setting 
						where Cmp_id = @Cmp_ID and AD_Id = @AD_ID
						order by Tran_id	
						
						Update OTA
							SET Early_Count = Qry.Cnt,
								Total_Amount = (Qry.Cnt * OTA.Amount)
						FROM #OnTimeArrival OTA
						INNER JOIN(
									Select Count(1) as Cnt,From_Slab,To_Slab,D.Emp_ID
									From #Data D 
										Inner Join #OnTimeArrival OTA ON D.Emp_ID = OTA.Emp_ID
										LEFT OUTER JOIN T0140_LEAVE_TRANSACTION LT ON LT.EMP_ID = D.EMP_ID AND LT.FOR_DATE = D.FOR_DATE AND LT.Leave_Used = 0.50
									Where In_Time < Shift_Start_Time and DateDiff(MINUTE,In_Time,Shift_Start_Time) BETWEEN From_Slab AND To_Slab
										AND (Out_Time >= Shift_End_Time OR LT.Leave_Used = 0.50 OR D.Chk_By_Superior = 1)
									Group by From_Slab,To_Slab,D.Emp_ID
								  ) as Qry
						ON OTA.Emp_ID = Qry.Emp_ID AND OTA.From_Slab = Qry.From_Slab AND OTA.To_Slab = Qry.To_Slab
						
						Select @AMOUNT = Isnull(SUM(Total_Amount),0) From #OnTimeArrival
						*/
						
					End
			End
			
		RETURN


