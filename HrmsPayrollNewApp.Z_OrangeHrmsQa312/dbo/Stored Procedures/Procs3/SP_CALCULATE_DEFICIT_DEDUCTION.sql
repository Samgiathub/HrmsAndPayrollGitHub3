
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_DEFICIT_DEDUCTION]
 @emp_Id			numeric
,@Company_Id		numeric
,@Month_St_Date		datetime
,@Month_End_Date	datetime
,@Deficit_Sal_Dedu_Days numeric(18,1) output
,@Total_DeficitMark		int  output
,@Total_Deficit_Sec	numeric output
,@Increment_ID		numeric 
,@Return_Record_Set	numeric =0
,@var_Return_Deficit_Date	varchar(1000) ='' output
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @Out_Date			datetime
	declare @Shift_hours		varchar(10)
	declare @Shift_End_DateTime	datetime
	declare @Curr_Month_LMark	numeric (18,1)
	declare @EarlyMark_BF			numeric(18,1)
	declare @var_Shift_End_Date	varchar(20)
	declare @numWorkingHoliday	numeric(18,1)
	declare @varWeekOff_Date	varchar(500)
	declare @dtAdjDate			datetime
	declare @TempFor_Date		smalldatetime
	declare @WeekOff			varchar(20)
	declare @dtHoliday_Date		datetime
	declare @varHoliday_Date	varchar(100)
	declare @Emp_Deficit_Limit		varchar(10)
	declare @Deficit_Limit_Sec		numeric
	declare @Deficit_Adj_Day		int
	Declare @Division_ID		numeric 
	declare @Is_Deficit_Mark		Numeric	
	Declare @Deficit_Dedu_Days		numeric(5,1)
	Declare @Deficit_Dedu_Type		varchar(10)
	declare @numPresentDays		numeric(12,1)
	Declare @month				numeric
	declare @Shift_hours_Act		varchar(10)
	
	Declare @Year				numeric
	Declare @Is_Early_CF			numeric
	Declare @Early_CF_Reset_On	varchar(50)
	declare @Shift_hour_used	numeric
	
	set @Shift_hour_used = 0			
 	set @Curr_Month_LMark	= 0
	set @numWorkingHoliday	= 0
	set @varWeekOff_Date	= '' 
	set @varHoliday_Date	= ''
	set @EarlyMark_BF = 0
	set @Deficit_Dedu_Days =0
	set @Total_Deficit_Sec =0
	set @Month	= Month(@Month_st_Date)
	set @Year	= Year(@Month_st_Date)
	set @var_Return_Deficit_Date = ''
	
	select @Is_Deficit_Mark = Emp_Deficit_mark ,@Emp_Deficit_Limit = Emp_Deficit_Limit,@Division_ID =Branch_ID,
		   @Deficit_Dedu_Type = Deficit_Dedu_Type
	from T0095_Increment I WITH (NOLOCK) Where I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID	
	
	
	select @Deficit_Adj_Day =  isnull(Deficit_Adj_Day,0),@Deficit_Dedu_Days = isnull(Deficit_Deduction_Days,0)
	from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @company_Id and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK)
				where Cmp_ID = @Company_ID and For_Date <=@Month_end_Date)
	
	select @Deficit_Limit_Sec	= dbo.F_Return_Sec(@Emp_Deficit_Limit)				
	
	
	
	Declare @Early_Data Table
	 (
		Emp_ID		numeric ,
		Company_ID	numeric,
		Month		numeric,
		Year		numeric,
		Balance_BF	numeric,
		Curr_M_Early	numeric,
		Total_Early	numeric,
		To_Be_Adj	numeric,
		Leave_ID	numeric,
		Leave_Bal		numeric(5,1),
		Adj_Again_Leave	numeric,
		Dedu_Leave_Bal	numeric(5,1),
		Adj_Fm_Sal	numeric,
		Deduct_From_Sal	numeric(5,1),
		Total_Adj		numeric(5,1),
		Balance_CF		numeric 		
	 )

	
	if  @Is_Deficit_Mark = 1 
		begin		
			if @Is_Early_CF =1 and   charindex(cast('#'+ @Month + '#' as varchar(10)),@Early_CF_Reset_On)>0
				begin
						--SELECT  @EarlyMark_BF =  isnull(Closing,0) FROM  LMark_Transaction  
						--where emp_id = @emp_Id and company_Id = @company_Id
						--				and for_date = (select max(for_date) from LMark_Transaction
						--				where emp_id = @emp_Id and  company_Id = @Company_Id
						--				and for_Date <=  @Month_St_Date )
						set @EarlyMark_BF = 0
				end

			--Add by Nimesh 21 April, 2015
			--This sp retrieves the Shift Rotation as per given employee id and effective date.
			--it will fetch all employee's shift rotation detail if employee id is not specified.
			IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
				Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
			--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
			Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Company_Id, @emp_Id, @Month_end_Date, ''


			Declare curEarlyOut cursor for
				select for_date,Replace(sum(convert(numeric(18,2),replace(duration,':','.'))),'.',':') as duration  From dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
				where Emp_ID =@Emp_ID and For_Date >=@Month_st_Date and For_Date <=@Month_end_Date 
					and isnull(Late_Calc_Not_App,0) =0
				group by For_Date 
				
			open curEarlyOut
			fetch next from curEarlyOut into @Out_Date,@Shift_hours_Act
			while @@fetch_status = 0
				begin
						
						--if exists(select Emp_ID from l_Mark_Detail where Emp_ID =@Emp_ID and Month=@month and Year =@Year) and @Return_Record_Set =1 
						--	begin
						--		insert into @Early_Data(Emp_ID,Company_ID,Month,Year,Balance_BF,Curr_M_Early,Total_Early,To_Be_adj,Leave_ID,Leave_Bal,Adj_Again_Leave,Deduct_From_Sal,Total_Adj,Adj_Fm_Sal,Balance_CF)
						--		select @Emp_ID,@Company_ID,@Month,@Year,Balance_BF,L_Day,Total_l_Day,Tobe_Adj,LeavE_Id,0,Dedu_Leave,Dedu_Leave,Total_Adj,Adj_Fm_Sal,Balance_CF From L_MArk_Detail where Emp_ID =@Emp_ID and Month=@month and Year =@Year
						--	end
						--else
							begin
								--Modified by Nimesh 22 April, 2015
								SET @Shift_hours = '';
								--Fetching @Shift_hours from Employee Shift Detail
								IF NOT EXISTS(Select 1 From #Rotation 
											  Where	R_DayName = 'Day' + CAST(DATEPART(d, @Out_Date) As Varchar) 
													AND R_Effective_Date<=@Out_Date)
													
									SELECT	@Shift_hours = SM.Shift_Dur
									FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID
									WHERE	ESD.Cmp_ID = @Company_Id AND ESD.Emp_ID=@emp_Id AND ESD.Cmp_ID=@company_id AND 
											ESD.For_Date=@Out_Date AND IsNULL(ESD.Shift_Type,0)=1
								ELSE
									SELECT	@Shift_hours = SM.Shift_Dur
									FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID
									WHERE	ESD.Cmp_ID = @Company_Id AND ESD.Emp_ID=@emp_Id AND 
											ESD.For_Date=@Out_Date AND ESD.Cmp_ID=@company_id
								
								--If @Shift_hours not found in Employee shift detail then it should check in rotation
								IF (ISNULL(@Shift_hours, '') = '') BEGIN
									SELECT	@Shift_hours = SM.Shift_Dur
									FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON R.R_ShiftID=SM.Shift_ID					
									WHERE	SM.Cmp_ID=@Company_Id AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Out_Date) As Varchar) AND
											R.R_EmpID=@emp_Id AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
												FROM #Rotation R1 WHERE R1.R_EmpID=@emp_Id AND 
													 R_Effective_Date<=@Out_Date) 
									
									--Take default latest shift detail from the Employee Shift Detail table if the rotation is not assigned
									IF (ISNULL(@Shift_hours, '') = '') BEGIN
										SELECT	@Shift_hours = SM.Shift_Dur
 										FROM	dbo.T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK)
 												ON ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID 												
 										WHERE	ESD.Cmp_ID=@Company_Id AND ESD.Emp_ID=@emp_Id
												AND For_Date = (
																	SELECT	MAX(For_Date) 
																	FROM	dbo.T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK)
																	WHERE	ESD1.Cmp_ID=ESD.Cmp_ID 
																			AND ESD1.For_Date <= @Out_Date
																			AND ESD1.Emp_ID = ESD.Emp_ID
																) 
									END
								END

								/*Commented by Nimesh 21 May, 2015
								select @Shift_hours = dbo.T0040_shift_MAster.Shift_Dur
	 									from dbo.T0100_emp_shift_Detail,dbo.T0040_shift_MAster where dbo.T0100_emp_shift_Detail.Cmp_ID = @company_id  and emp_id = @emp_id
												and for_date in (select max(for_date) from dbo.T0100_emp_shift_Detail 
												where Cmp_ID = @company_id 	and for_date <= @Out_Date
													and emp_id = @emp_id) 
											and dbo.T0100_emp_shift_Detail.shift_id = dbo.T0040_shift_MAster.shift_id
											and dbo.T0100_emp_shift_Detail.Cmp_ID = dbo.T0040_shift_MAster.Cmp_ID 
								*/
								--set @var_Shift_End_Date = cast(@Out_Date as varchar(11)) + ' '  + @Shift_hours
								
								--set @Shift_End_DateTime = cast(@var_Shift_End_Date as datetime)
								--set @Shift_End_DateTime = dateadd(s,@Deficit_Limit_Sec*-1,@Shift_End_DateTime)
								
								Set @Shift_hour_used = (Select dbo.F_Return_Sec(@Shift_hours_Act)) - @Deficit_Limit_Sec
								
								
								
								if @Shift_hour_used < (Select dbo.F_Return_Sec(@Shift_hours))
									begin										
										set @Curr_Month_LMark = @Curr_Month_LMark + 1 		
										set @Total_Deficit_Sec = @Total_Deficit_Sec + abs((Select dbo.F_Return_Sec(@Shift_hours)) - @Shift_hour_used )
										set @var_Return_Deficit_Date = @var_Return_Deficit_Date + ';' + cast(@Out_Date as varchar(11))
									end
							end
					fetch next from curEarlyOut into @Out_Date,@Shift_hours_Act
				end
			close curEarlyOut
			deallocate curEarlyOut
		end
		
		
		If @Deficit_Dedu_Type = 'Hour'
			begin
				set @Total_DeficitMark =0
				set @Deficit_Sal_Dedu_Days =0
			end
		else
			begin
				
				
				Declare @Tobe_Adj numeric 
				Declare @Dedu_From_Sal numeric(5,1)
				Declare @Adj_fm_sal numeric 
				Declare @Balance_CF numeric 
				Declare @Total_Adj	numeric
				
				Declare @Leave_Bal			numeric(5,1)
				Declare @Leave_ID			numeric 
				Declare @Adj_Again_Leave	numeric
				Declare @Dedu_Leave_Bal		numeric(5,1)
				
				set @Adj_Again_Leave = 0
				set @Dedu_Leave_Bal	 = 0
				
				
				set @Total_DeficitMark = @EarlyMark_BF + @Curr_Month_LMark
				
				select top 1 @Leave_ID =l.LeavE_ID ,@Leave_Bal =isnull(Leave_Closing,0)  from T0140_Leave_Transaction l WITH (NOLOCK) inner join  
				( select Emp_ID,max(For_Date) For_Date ,lt.Leave_Id From T0140_Leave_Transaction lt WITH (NOLOCK) Inner join
					dbo.T0040_LeavE_MAster lm WITH (NOLOCK) on lt.leave_ID = lm.leave_ID and isnull(lm.Leave_paid_Unpaid,'') ='P'
						and lm.Leave_Type  <>'Company Purpose' --and isnull(Is_Late_Adj,0) =1 
				where Emp_ID =@Emp_ID and 
				for_Date <=@Month_End_Date group by Emp_ID ,lt.Leave_ID ) q on l.leavE_ID =q.leavE_ID 
				and l.for_Date =q.for_Date 
				where l.emp_ID =@Emp_ID order by Leave_Closing desc
					
				
				set @Tobe_Adj = 0
				set @Dedu_From_Sal = 0
				if @Deficit_Adj_Day > 0
					set @Tobe_Adj = @Total_DeficitMark - (@Total_DeficitMark % @Deficit_Adj_Day)
				if @Deficit_Dedu_Days > 0
					set @Adj_fm_sal =  @Tobe_Adj
					
				if @Deficit_Adj_Day > 0
					select @Dedu_From_Sal = @Adj_fm_sal * @Deficit_Dedu_Days / @Deficit_Adj_Day 
			
				set @Total_Adj = @Adj_fm_sal
				set @Balance_CF = @Total_DeficitMark - @Total_Adj
			

				set @Total_Deficit_Sec  = 0 
				set @Deficit_Sal_Dedu_Days = @Dedu_From_Sal
				
				if @Return_Record_Set =1 	
					begin
						select *,@numPresentDays as Present_Day from @Early_Data
						
						Insert Into @Early_Data(Emp_ID,Company_ID,Month,Year,Balance_BF,Curr_M_Early,Total_Early,To_Be_adj,Leave_ID,Leave_Bal,Adj_Again_Leave,Dedu_Leave_Bal,Adj_Fm_Sal,Total_Adj,Deduct_From_Sal,Balance_CF)
						select @Emp_ID,@Company_ID,@Month,@Year,@EarlyMark_BF,@Curr_Month_LMark,@Total_DeficitMark,@Tobe_Adj,@Leave_ID,@Leave_Bal,@Adj_Again_Leave,@Dedu_Leave_Bal,@Adj_fm_sal,@Total_Adj,@Dedu_From_Sal,@Balance_CF
					end 
			end
		

	RETURN




