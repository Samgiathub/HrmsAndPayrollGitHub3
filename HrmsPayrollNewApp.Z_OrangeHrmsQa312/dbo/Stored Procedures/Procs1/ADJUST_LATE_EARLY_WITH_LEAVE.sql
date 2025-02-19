
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[ADJUST_LATE_EARLY_WITH_LEAVE]
	 @Emp_Id			NUMERIC
	,@Cmp_ID	     	NUMERIC
	,@Month_St_Date		DateTime
	,@Month_End_Date	DateTime
	,@Sal_Dedu_Days		NUMERIC(18,2) OUTPUT --Change by Sumit Rounding case in veralogic client on 05052016
	,@Increment_ID		NUMERIC 
	,@Adjust_Type		NVARCHAR(5)
	,@Adjust_leave_days	NUMERIC(18,2) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @temp_Total_leave_adj NUMERIC(18,2)
		set @temp_Total_leave_adj = 0
		
		declare @Adj_Day		int
		
		declare @LMark_BF			NUMERIC(18,1)
		
		declare @Curr_Month_LMark	NUMERIC (18,1)
		Declare @Late_With_leave    NUMERIC(18,0)
		Declare @Branch_ID		    NUMERIC 

		Declare @Tobe_Adj NUMERIC 
		Declare @Dedu_From_Sal NUMERIC(18,1)
		Declare @Adj_fm_sal NUMERIC 
		Declare @Balance_CF NUMERIC 
		
		Declare @Leave_Bal			NUMERIC(18,2)
		Declare @Leave_ID			NUMERIC 
		Declare @Adj_Again_Leave	NUMERIC
		Declare @Dedu_Leave_Bal		NUMERIC(18,2)
		Declare @Leave_Tran_ID      NUMERIC(18,1)
		Declare @For_Date  DateTime
		Declare @Leave_negative_Allow  NUMERIC(5,1)
		
		set @Curr_Month_LMark	= 0 
		
		set @LMark_BF = 0
		set @Curr_Month_LMark = 0
		set @Adjust_leave_days = 0

				
		select @Branch_ID =Branch_ID		   
		from T0095_Increment I WITH (NOLOCK) Where I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID	
		
		if @Adjust_Type = 'L'
			begin
					
				Select @Adj_Day =  isnull(Late_Adj_Day,0) 
				,@Late_With_leave =Late_with_Leave
				from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) 
				where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  
				
			end
		else if @Adjust_Type = 'E'
			begin
					
				Select @Adj_Day =  isnull(Early_Adj_Day,0) 
				,@Late_With_leave =Early_With_Leave
				from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK)
				where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  
				
			end	
		else if @Adjust_Type = 'LE'
			begin
					
				Select @Adj_Day =  isnull(Early_Adj_Day,0) 
				,@Late_With_leave =Early_With_Leave
				from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK)
				where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  
				
			end	
		


		set @Adj_Again_Leave = 0
		set @Dedu_Leave_Bal	 = 0
		
		
		
		--set @Total_LMark = @LMark_BF + @Curr_Month_LMark - @Late_Exempted_Days 
		
		--select top 1 @Leave_ID =l.LeavE_ID,@For_Date= l.For_Date,@Leave_Tran_ID =l.Leave_Tran_ID  ,@Leave_Bal =isnull(Leave_Closing,0),@Leave_negative_Allow = q.Leave_Negative_Allow  from dbo.T0140_Leave_Transaction l inner join  
		-- (select Emp_ID,max(For_Date) For_Date ,lt.Leave_Id,lm.Leave_Negative_Allow From dbo.T0140_Leave_Transaction lt Inner join
		--	dbo.T0040_LeavE_MAster lm on lt.leave_ID = lm.leave_ID and isnull(lm.Leave_paid_Unpaid,'') ='P'
		--		and lm.Leave_Type  <>'Company Purpose' and isnull(Is_Late_Adj,0) =1 
		--where Emp_ID =@Emp_ID and 
		--for_Date <=@Month_End_Date group by Emp_ID ,lt.Leave_ID,lm.Leave_Negative_Allow ) q on l.leavE_ID =q.leavE_ID 
		--and l.for_Date =q.for_Date 
		--where l.emp_ID =@Emp_ID order by Leave_Closing desc
		
		
		
		--set @Tobe_Adj = 0
		--set @Dedu_From_Sal = 0
		
		--if @Adj_Day > 0
		--	set @Tobe_Adj = @Total_LMark - (@Total_LMark % @Adj_Day)
			
		--if @LAte_Dedu_Days > 0
		--	set @Adj_fm_sal =  @Tobe_Adj
				
				
					
		--if @Adj_Day > 0	
		--	select @Dedu_From_Sal = @Adj_fm_sal * @Late_Dedu_Days / @Adj_Day 
			
		--set @Total_Adj = @Adj_fm_sal
		--set @Balance_CF = @Total_LMark - @Total_Adj
		
	
		
		--set @Sal_Dedu_Days = @Dedu_From_Sal
		
		
	------------------------------------------------------------------------
		declare @total_deduction as NUMERIC(18,2)
		set @total_deduction = @Sal_Dedu_Days


		Declare @Can_Apply_in_Frcation tinyint
		Set @Can_Apply_in_Frcation = 0
		
		Declare @Leave_Applicable Numeric(5,0)
		Set @Leave_Applicable = 0
		
		-- Added by Nilesh Patel on 12-11-2018 -- Start -- EL Leave is Applicable after 365 same scenario for in Late Mark Deduction also -- For Genchi
		Declare @Joining_Days Numeric(5,0)
		Set @Joining_Days = 0
		
		Declare @Date_of_Joining Datetime
		Select @Date_of_Joining = Date_Of_join From T0080_Emp_Master WITH (NOLOCK) Where EMP_ID =@EMP_ID and Cmp_ID = @Cmp_ID
		
		Set @Joining_Days = DateDiff(d,@Date_of_Joining,@Month_End_Date)
		-- Added by Nilesh Patel on 12-11-2018 -- End
		
		DECLARE CUR_LEAVE_ADJUST 
		CURSOR FOR
			SELECT L.LEAVE_ID , L.FOR_DATE, L.LEAVE_TRAN_ID,ISNULL(LEAVE_CLOSING,0),Q.LEAVE_NEGATIVE_ALLOW,Q.CAN_APPLY_FRACTION,ISNULL(Q.LEAVE_APPLICABLE,0)  
		FROM DBO.T0140_LEAVE_TRANSACTION L WITH (NOLOCK)
		INNER JOIN  
			 (
				SELECT EMP_ID,MAX(FOR_DATE) FOR_DATE ,LT.LEAVE_ID,LM.LEAVE_NEGATIVE_ALLOW,LM.LEAVE_SORTING_NO,LM.CAN_APPLY_FRACTION,LM.LEAVE_APPLICABLE 
					FROM DBO.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
					INNER JOIN DBO.T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID AND ISNULL(LM.LEAVE_PAID_UNPAID,'') ='P'
					AND LM.LEAVE_TYPE  <>'COMPANY PURPOSE' AND ISNULL(IS_LATE_ADJ,0) =1 
				WHERE EMP_ID =@EMP_ID AND FOR_DATE <=@MONTH_END_DATE 
				GROUP BY EMP_ID ,LT.LEAVE_ID,LM.LEAVE_NEGATIVE_ALLOW,LM.LEAVE_SORTING_NO,LM.CAN_APPLY_FRACTION,LM.LEAVE_APPLICABLE
			 ) Q ON L.LEAVE_ID =Q.LEAVE_ID AND L.FOR_DATE =Q.FOR_DATE 
		WHERE L.EMP_ID =@EMP_ID ORDER BY Q.LEAVE_SORTING_NO 
			
		open cur_leave_adjust
		Fetch next from cur_leave_adjust into @Leave_ID ,@For_Date,@Leave_Tran_ID,@Leave_Bal,@Leave_negative_Allow,@Can_Apply_in_Frcation,@Leave_Applicable
		while @@Fetch_Status=0
			begin		
				
				if @Sal_Dedu_Days <= 0 
					goto Exit_cursor
			
				
				if @Leave_Bal > 0 and @Joining_Days >= @Leave_Applicable
				  Begin 
				   if  isnull(@Late_with_leave,0) = 1 
						 Begin
							
							if @Sal_Dedu_Days > 0
								Begin
																	
									declare @dedu_actual_days NUMERIC(5,2)
									if @Leave_Bal < @Sal_Dedu_Days
										begin 
											
											set	@dedu_actual_days = @Leave_Bal
											set @Sal_Dedu_Days =  @Sal_Dedu_Days - @Leave_Bal
											set @Adjust_leave_days = @Leave_Bal
											--set @temp_Total_leave_adj = @temp_Total_leave_adj + @dedu_actual_days
											set @temp_Total_leave_adj = @temp_Total_leave_adj + (Case When @Can_Apply_in_Frcation = 1 Then  @dedu_actual_days Else ceiling(@dedu_actual_days) END)
										end
									else
										begin
										
											set	@dedu_actual_days = @Sal_Dedu_Days
											--set @Sal_Dedu_Days = 0
											--set @temp_Total_leave_adj = @temp_Total_leave_adj + @dedu_actual_days
											set @temp_Total_leave_adj = @temp_Total_leave_adj + (Case When @Can_Apply_in_Frcation = 1 Then  @dedu_actual_days Else ceiling(@dedu_actual_days) END)
											set @Sal_Dedu_Days =  @Sal_Dedu_Days - @Leave_Bal 
											
											if @Sal_Dedu_Days < 0
												set @Sal_Dedu_Days = 0
																						
											set @Adjust_leave_days = @Sal_Dedu_Days
												
										end
																
									Declare @Late_Tran_ID NUMERIC
									select @Late_Tran_ID = Isnull(max(Late_Tran_ID),0) + 1 From T0160_Late_Approval WITH (NOLOCK) 
																	
									if Exists(SELECT 1 From T0160_Late_Approval	WITH (NOLOCK) Where Emp_ID = @Emp_ID AND For_Date = @Month_End_Date and Leave_ID = @Leave_ID)
										BEGIN
											UPDATE T0160_Late_Approval
											Set Late_Cal_day = Late_Cal_day + (Case When @Can_Apply_in_Frcation = 1 Then  @dedu_actual_days Else ceiling(@dedu_actual_days) END),
												Leave_Balance = @Leave_Bal,
												Total_Penalty_Days = Total_Penalty_Days + @total_deduction,
												Penalty_days_to_Adjust = Penalty_days_to_Adjust + @Sal_Dedu_Days
											Where Emp_ID = @Emp_ID AND For_Date = @Month_End_Date and Leave_ID = @Leave_ID
										END
									Else
										Begin
											
											insert into T0160_Late_Approval (Late_Tran_ID,Cmp_ID,Emp_ID,For_Date,Total_late,Late_Cal_day,Leave_ID,Month_Date,Approval_Type,Leave_Balance,Total_Penalty_Days,Penalty_days_to_Adjust)
											values (@Late_Tran_ID,@Cmp_ID,@Emp_ID,@Month_End_Date,0,(Case When @Can_Apply_in_Frcation = 1 Then  @dedu_actual_days Else ceiling(@dedu_actual_days) END),@Leave_ID,@Month_St_Date,@Adjust_Type,@Leave_Bal,@total_deduction,@Sal_Dedu_Days)
										END 
									--set  @Sal_Dedu_Days= 0
								End
						 End
				 
				 End	
	  
			Fetch next from cur_leave_adjust into @Leave_ID , @For_Date , @Leave_Tran_ID ,@Leave_Bal , @Leave_negative_Allow ,@Can_Apply_in_Frcation,@Leave_Applicable
			end
		
		
		Exit_cursor:	
		
		close cur_leave_adjust
		deallocate cur_leave_adjust   
		
		
		set @Adjust_leave_days = @temp_Total_leave_adj 
		
		
RETURN




