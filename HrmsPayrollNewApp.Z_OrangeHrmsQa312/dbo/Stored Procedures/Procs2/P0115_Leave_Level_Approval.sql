---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_Leave_Level_Approval]
	 @Tran_ID				Numeric(18,0)		Output
	,@Cmp_ID				Numeric(18,0)
	,@Leave_Application_ID	Numeric(18,0)
	,@Emp_ID				Numeric(18,0)
	,@Leave_ID				Numeric(18,0)
	,@From_Date				Datetime
	,@To_Date				Datetime
	,@Leave_Period			Numeric(18,2)
	,@Leave_Assign_As		Varchar(15)
	,@Leave_Reason			Varchar(100)
	,@M_Cancel_WO_HO		TinyInt
	,@Half_Leave_Date		Datetime
	,@S_Emp_ID				Numeric(18,0)
	,@Approval_Date			Datetime
	,@Approval_Status		Char(1)
	,@Approval_Comments		Varchar(250)
	,@Rpt_Level				TinyInt
	,@Tran_Type				Char(1)
	,@is_arrear				tinyint = 0 
	,@arrear_month			numeric(18,0) = 0
	,@arrear_year			numeric(18,0) = 0
	,@is_Responsibility_pass tinyint = 0
	,@Responsible_Emp_id	numeric(18,0) = 0
	,@Leave_Out_Time  Datetime = ''  --Ankit 21022014
    ,@Leave_In_Time   Datetime = ''  --Ankit 21022014
    ,@Leave_CompOff_Dates varchar(max) = '' --Added By Gadriwala Muslim 01102014
    ,@Half_Payment tinyint =0 --Hardik 19/12/2014
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	Declare @Apply_Hourly as numeric
	Set @Apply_Hourly = 0
	
	Declare @Is_Backdated as tinyint
	Set @Is_Backdated = 0
		
	Select @Is_Backdated = ISNULL(is_backdated_application,0),@Cmp_ID = Cmp_ID ----Set @Cmp_ID IF Cross Company Reporting Manager  ---- Ankit 27012015
	From T0100_LEAVE_APPLICATION WITH (NOLOCK) Where Leave_Application_Id = @Leave_Application_ID		
	
	Select @Apply_Hourly = ISNULL(Apply_Hourly,0) 
	from T0040_Leave_Master WITH (NOLOCK) Where  Leave_ID = @Leave_ID And Cmp_ID = @Cmp_ID
	


	If Upper(@Tran_Type) = 'I'
		Begin
		
			declare @message varchar(200)
			--Added By Jimit 06112019	
			If EXISTS(SELECT 1 from T0040_SETTING WITH (NOLOCK) where Cmp_ID =@CMP_ID and Group_By = 'Leave Settings' 
								and Setting_Name = 'Hide Previous Month Option in Leave Application and Approval' and (Setting_Value = 2 or Setting_Value = 1))
				BEGIN
				

						If EXISTS(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @EMP_ID and isnull(cutoff_date,Month_End_Date) >= @From_Date) --Mukti(19122020)
						--isnull(month(cutoff_date),month(Month_End_Date)) = month(@From_Date) and isnull(year(cutoff_date),year(Month_End_Date)) = year(@From_Date))
							BEGIN			
									set @message = '@@BackDated Leave Approval is not Allowed.@@'						
									RAISERROR(@message ,16,2)
									return
							END
				END
			--Ended

	

			--Added by Jaina 08-05-2018 Start				
			if exists (select 1 from T0040_LEAVE_MASTER  where Leave_ID = @Leave_id and Leave_Type = 'Paternity Leave')
			BEGIN
				DECLARE @F_date datetime
				declare @T_date datetime
				
				Create table #Paternity_Leave
				(
					Leave_Tran_Id numeric(18,0),
					Emp_id numeric(18,0),
					For_Date datetime,
					Leave_Opening numeric(18,2),
					Leave_Closing numeric(18,2),
					Laps_Days numeric(18,2),
					From_Date datetime,
					To_Date datetime
				)
				
				insert INTO #Paternity_Leave
				EXEC P_RESET_PATERNITY_LEAVE @CMP_ID = @CMP_ID,@EMP_ID=@EMP_ID
				
				if exists (select 1 from #PATERNITY_LEAVE where Emp_id = @Emp_id)
				BEGIN				
					IF NOT EXISTS(SELECT 1 FROM #PATERNITY_LEAVE WHERE @FROM_DATE BETWEEN FROM_DATE AND TO_DATE AND
					@TO_DATE BETWEEN FROM_DATE AND TO_DATE AND Emp_id=@emp_ID)
					BEGIN
						SELECT @F_date = From_Date, @T_date = To_Date 
						FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID
												
						set @message = 'You can apply leave between '+ convert(varchar(11),@F_date,103) + ' To ' + convert(varchar(11),@T_date,103)
						
						RAISERROR(@message ,16,2)
						return
					END
				END
			EnD
			
			--Added by Jaina 08-05-2018 End
		--Select * From T0115_Leave_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Leave_Application_ID = @Leave_Application_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level
			IF Exists(Select 1 From T0115_Leave_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Leave_Application_ID = @Leave_Application_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
				--select 123
				
					Set @Tran_ID = 0
				--Select @Tran_ID --commented by yogesh on 27062023
					Return 
				End
				
			DECLARE @Branch_ID AS NUMERIC(18,0)
			SET @Branch_ID = 0
			SELECT  @Branch_ID = Branch_ID 
			FROM T0095_Increment I WITH (NOLOCK)
				INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   --Changed by Hardik 10/09/2014 for Same Date Increment
								FROM T0095_Increment WITH (NOLOCK)
								WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID 
								GROUP BY emp_ID) Qry 
				ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id 
			WHERE I.Emp_ID = @Emp_ID  
			  
			--commented by Mukti(15112017)start	
			--IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WHERE MONTH =  MONTH(@To_Date) AND YEAR =  YEAR(@To_Date) AND Cmp_ID = @CMP_ID AND (Branch_ID = ISNULL(@Branch_ID,0) OR Branch_ID = 0) And @Is_Backdated = 0)
			--	BEGIN
			--		--RAISERROR('Month Lock',16,2)
			--		--RETURN -1
			--				Declare @cut_off_date As Datetime
			--				select  @cut_off_date= isnull(MAX(Cutoff_Date),@To_Date) from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID  

			--				if @cut_off_date >= @To_Date 
			--				begin
			--					RAISERROR('Month Lock',16,2)
			--					RETURN -1
			--				end
			--	END
			--commented by Mukti(15112017)end
			
				--Added by Mukti(15112017)start
					DECLARE @MONTH_ST_DATE DATETIME   
					DECLARE @MONTH_END_DATE DATETIME  
					DECLARE @MONTH_LOCK INTEGER 
					DECLARE @YEAR_LOCK INTEGER   
					DECLARE @Cutoffdate_Salary DATETIME   
				    DECLARE @CUTOFFDATE AS VARCHAR(15)  
				 
					SELECT @Cutoffdate_Salary=isnull(Cutoffdate_Salary,'1900-01-01') FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID =@Cmp_id	AND BRANCH_ID = @Branch_id
					AND FOR_DATE = (SELECT MAX(FOR_DATE) FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE
					FOR_DATE <=@FROM_DATE AND BRANCH_ID = @Branch_id AND CMP_ID =@Cmp_id)
					
					 SET @CUTOFFDATE = Convert(Varchar(4),DatePart(YYYY,@FROM_DATE)) + '-' + Convert(Varchar(2),MONTH(@FROM_DATE)) + '-' + Convert(Varchar(2),DatePart(D,@Cutoffdate_Salary)) 
					 
					if @Cutoffdate_Salary <> '1900-01-01'
						BEGIN
							if @FROM_DATE > @CUTOFFDATE   
								BEGIN
									 SET @MONTH_LOCK =  Month(DateAdd(MONTH,1,@FROM_DATE))  
									 SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))  
								END
							ELSE  
								BEGIN
									SET @MONTH_LOCK = Month(@FROM_DATE)  
									SET @YEAR_LOCK=YEAR(@FROM_DATE)  
								END
						END
					ELSE
						BEGIN
							SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH(@FROM_DATE),YEAR(@FROM_DATE))
								If @FROM_DATE >= @MONTH_ST_DATE And @FROM_DATE <= @MONTH_END_DATE  
									BEGIN
									  SET @MONTH_LOCK = Month(@FROM_DATE)  
									  SET @YEAR_LOCK=YEAR(@FROM_DATE)  
									END
								Else  
									BEGIN
									  SET @MONTH_LOCK = Month(DateAdd(MONTH,1,@FROM_DATE))  
									  SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))  
									 END  
						END	
							
							

					IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE (MONTH =  @MONTH_LOCK and YEAR =  @YEAR_LOCK) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0) And @Is_Backdated = 0)
						Begin
						   IF EXISTS(select 1 from T0040_SETTING WITH (NOLOCK) where cmp_id=@CMP_ID and setting_name='Restrict User to Apply Leave if Month is Locked' and setting_value = 1)  
								BEGIN
									Raiserror('Month Lock',16,2)
									return -1								
								END							
						End
				--Added by Mukti(15112017)end
				
			--Added by Jaina 11-09-2017
			
			IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date) and Cmp_ID= @Cmp_ID)
				BEGIN
						RAISERROR('Left Employee Leave Can''t Approved',16,2)
						RETURN -1
				END	
		
			--COMMENTED BY MEHUL 18-11-2021 DUE TO CONVERSION OF LEAVE PERIOD
			--If @Apply_Hourly = 0 and @Leave_Assign_As = 'Part Day'	--Ankit 22022014
			--	Begin
			--		set @Leave_Period = @Leave_Period * 0.125
			--	End
				
			--Added by Jaina 18-04-2017
			if NOT EXISTS (SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
					WHERE CMP_ID=@CMP_ID AND FOR_DATE BETWEEN @From_Date AND @To_Date 
						  AND EMP_ID = @EMP_ID AND (LEAVE_USED > 0 OR CompOff_Used > 0)  and Leave_ID = @LEave_ID)
			BEGIN
			
				exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
				--Check Consecutive Leave with Present Days
				--exec P_Check_Present_Days_On_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
			END
		
			Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0115_Leave_Level_Approval WITH (NOLOCK)
			Insert Into T0115_Leave_Level_Approval(Tran_ID, Cmp_ID, Leave_Application_ID, Emp_ID, Leave_ID, From_Date, To_Date, Leave_Period, 
					   Leave_Assign_As, Leave_Reason, M_Cancel_WO_HO, Half_Leave_Date, S_Emp_ID, Approval_Date, Approval_Status, Approval_Comments,
					   Rpt_Level, System_Date,is_arrear	,arrear_month, arrear_year,is_Responsibility_pass,Responsible_Emp_id,leave_Out_time,leave_In_time,Leave_CompOff_dates,Half_Payment)
				Values(@Tran_ID, @Cmp_ID, @Leave_Application_ID, @Emp_ID, @Leave_ID, @From_Date, @To_Date, @Leave_Period, @Leave_Assign_As,
					   @Leave_Reason, @M_Cancel_WO_HO, @Half_Leave_Date, @S_Emp_ID, @Approval_Date, @Approval_Status, @Approval_Comments,
					   @Rpt_Level, GetDate(),@is_arrear	,@arrear_month, @arrear_year,@is_Responsibility_pass,@Responsible_Emp_id,@Leave_Out_Time,@Leave_In_Time,@Leave_CompOff_Dates,@Half_Payment) --Changed By Gadriwala Muslim 01102014 
		End
		--select @Tran_ID
		--select * from T0115_Leave_Level_Approval order by 1 desc
END

     