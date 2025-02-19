
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Missing_Inout_SMS] 
	--@Cmp_ID  numeric,     
	--@From_Date  datetime			--\\** Commented By Ramiz on 17062015 as was Not able to Keep Job with this Paramater
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

BEGIN


 Declare @From_Date  as datetime	--\\** Added By Ramioz on 17062015
 set @From_Date  =  CONVERT(VARCHAR(11),GETDATE(),106)
 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	Declare @From_Date_1 datetime
	Declare @To_Date datetime
	Declare @Cmp_ID Numeric
	Declare @Cur_Emp_ID Numeric
	Declare @Cur_Cmp_ID Numeric
	Declare @Cur_Shift_St_time Varchar(50)
	Declare @Cur_Shift_End_time Varchar(50)
	
	Declare @Cur_In_Time Datetime
	Declare @Cur_out_Time Datetime
	Declare @Cur_Is_Night_Shift tinyint
	
	Declare @F_Shift_In_Time Varchar(50)     
	Declare @F_Shift_End_Time Varchar(50) 
	Declare @SMS_Text Varchar(1000)
	
	
	Set @From_Date_1 = DATEADD(dd,-1,@From_Date)
	Set @To_Date = DATEADD(dd,-1,@From_Date)
	Set @SMS_Text = ''
	
	IF OBJECT_ID('tempdb..#Emp_Cons') IS NOT NULL
		Begin
			DROP TABLE #Emp_Cons
		End
	
	IF OBJECT_ID('tempdb..#Emp_Shift') IS NOT NULL
		Begin
			DROP TABLE #Emp_Shift
		End 
	
	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	(      
	  Emp_ID numeric ,     
	  Branch_ID numeric,
	  Increment_ID numeric    
	) 
	
	Create table #Emp_Shift
	 (
		Cmp_Id numeric(18,0),
		Emp_Id numeric(18,0),
		For_date datetime,
		IN_Time Datetime,
		Out_Time Datetime,
		Is_Night_Shift tinyint,
	 )
	
	Declare Cur_Comp Cursor
	For SELECT Cmp_ID FROM T0040_SETTING WITH (NOLOCK) where Setting_Name='Enable Miss punch SMS' AND Setting_Value = 1
	open Cur_Comp
	Fetch next From Cur_Comp into @Cmp_ID
		While @@fetch_status = 0
			Begin
				EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date_1,@To_Date,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'' --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
				Fetch next From Cur_Comp into @Cmp_ID
			End
	
	Close Cur_Comp
	Deallocate Cur_Comp
	
	Alter Table  #Emp_Cons add Cmp_id Numeric(18,0) 
	Update EC SET Cmp_ID = EM.Cmp_ID
	From #Emp_Cons  EC inner join T0080_EMP_MASTER EM on EM.Emp_ID = EC.Emp_ID 
	
	
	Declare Curr_Emp_Shift Cursor
	For Select EC.Emp_ID,EC.Cmp_ID From #Emp_Cons EC inner JOIN t0150_emp_inout_record EI WITH (NOLOCK) on EC.Emp_ID = EI.Emp_ID where EI.For_Date = @From_Date_1
	open Curr_Emp_Shift
	Fetch next From Curr_Emp_Shift into @Cur_Emp_ID,@Cur_Cmp_ID
		While @@Fetch_Status = 0	
			Begin
				
				exec SP_CURR_T0100_EMP_SHIFT_GET @Cur_Emp_ID,@Cur_Cmp_ID,@From_Date_1,@Cur_Shift_St_time output ,@Cur_Shift_End_time output
				
				Set @Cur_In_Time = null
				Set @Cur_out_Time = null
				
				if @Cur_Shift_St_time > @Cur_Shift_End_time
					Begin
						set @Cur_Is_Night_Shift = 1
						set @Cur_In_Time  = 0
						set @Cur_out_Time = 0
						
						Set @F_Shift_In_Time  =  CONVERT(varchar(10),@From_Date_1,126)+ ' ' + @Cur_Shift_St_time
						Set @F_Shift_End_Time = CONVERT(varchar(10),DATEADD(dd,1,@From_Date_1),126)+ ' ' + @Cur_Shift_End_time

						--Select DATEADD(hh,-2,@F_Shift_In_Time),DATEADD(hh,4,@F_Shift_End_Time)
												
						Select @Cur_In_Time = Min(EIR.In_Time)
						from dbo.T0150_emp_inout_Record EIR WITH (NOLOCK)
						Where EIR.cmp_Id= @Cur_Cmp_ID        
						and EIR.In_Time >= Dateadd(hh,-2,@F_Shift_In_Time) and isnull(EIR.Out_Time,Dateadd(hh,4,@F_Shift_End_Time)) <= Dateadd(hh,4,@F_Shift_End_Time) and EIR.Emp_ID = @Cur_Emp_ID 
						group by EIR.Emp_ID
						
						Select @Cur_out_Time = EIR.Out_Time
						from dbo.T0150_emp_inout_Record EIR WITH (NOLOCK) inner JOIN
						(select Max(In_time) Max_In,Emp_Id from dbo.T0150_emp_inout_record WITH (NOLOCK)
						 Where  In_Time >= Dateadd(hh,-2,@F_Shift_In_Time) and isnull(Out_Time,Dateadd(hh,4,@F_Shift_End_Time)) <= Dateadd(hh,4,@F_Shift_End_Time) 
						Group by Emp_ID) m
						ON EIR.Emp_ID = m.Emp_ID AND m.Max_In = EIR.In_Time
						Where EIR.cmp_Id= @Cur_Cmp_ID        
						and EIR.In_Time >= Dateadd(hh,-2,@F_Shift_In_Time) and isnull(EIR.Out_Time,Dateadd(hh,4,@F_Shift_End_Time)) <= Dateadd(hh,4,@F_Shift_End_Time) and EIR.Emp_ID = @Cur_Emp_ID   
						
						insert into #Emp_Shift values(@Cur_Cmp_ID,@Cur_Emp_ID,@From_Date_1,@Cur_In_Time,@Cur_out_Time,@Cur_Is_Night_Shift)
						
					End 										
				else
					Begin
						set @Cur_Is_Night_Shift = 0
						set @Cur_In_Time  = NULL
						set @Cur_out_Time = NULL
						
						select @Cur_In_Time = Min(In_time),
						@Cur_out_Time = (Case When Max_In > Max(Out_Time) Then Max_In Else Max(Out_time) End)
						from dbo.T0150_emp_inout_record e WITH (NOLOCK) Inner Join
					    (select Max(In_time) Max_In,Emp_Id,For_Date from dbo.T0150_emp_inout_record WITH (NOLOCK) Where  For_Date = @From_Date_1 Group by Emp_ID,For_Date) m
						on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
						Where  E.For_Date = @From_Date_1 and e.Emp_ID = @Cur_Emp_ID
						group by Max_In,e.For_Date,e.Emp_ID

						insert into #Emp_Shift values(@Cur_Cmp_ID,@Cur_Emp_ID,@From_Date_1,@Cur_In_Time,@Cur_out_Time,@Cur_Is_Night_Shift)
					End
				Fetch next From Curr_Emp_Shift into @Cur_Emp_ID,@Cur_Cmp_ID
			End  
	Close Curr_Emp_Shift
	Deallocate Curr_Emp_Shift
	
	--Select DISTINCT * From #Emp_Shift 
	Declare @Cur_SMS_Send_Mobile_No Varchar(50)
	Declare @Cur_SMS_Send_For_Date datetime
	Declare @Cur_SMS_Send_Emp_Name Varchar(100)
	Declare @sResponse varchar(1000)
	Declare @Cur_cmp_id_1 numeric(18,0)
	
	
	--Select (Case When E.Mobile_No = '' THEN '0' ELSE E.Mobile_No END) as Mobile_No ,ES.For_date From  T0080_EMP_MASTER E inner join #Emp_Shift ES on ES.Emp_ID = E.Emp_ID WHERE ES.Out_Time is null order by E.Emp_Code

	--Select (Case When E.Mobile_No = '' THEN '0' ELSE E.Mobile_No END) as Mobile_No ,ES.For_date,E.Emp_First_Name,ES.Cmp_Id From  T0080_EMP_MASTER E inner join #Emp_Shift ES on ES.Emp_ID = E.Emp_ID WHERE ES.Out_Time is null order by E.Emp_Code
	
	Declare Cur_SMS_Send Cursor
	For Select (Case When E.Mobile_No = '' THEN '0' ELSE E.Mobile_No END) as Mobile_No ,ES.For_date,E.Emp_First_Name,ES.Cmp_Id From  T0080_EMP_MASTER E WITH (NOLOCK) inner join #Emp_Shift ES on ES.Emp_ID = E.Emp_ID WHERE ES.Out_Time is null order by E.Emp_Code
	open Cur_SMS_Send
	Fetch next From Cur_SMS_Send into @Cur_SMS_Send_Mobile_No,@Cur_SMS_Send_For_Date,@Cur_SMS_Send_Emp_Name,@Cur_cmp_id_1
	While @@Fetch_Status = 0
		Begin
		    --select @Cur_SMS_Send_Mobile_No,@Cur_SMS_Send_For_Date,@Cur_SMS_Send_Emp_Name
		
			Set @SMS_Text = 'Dear ' + @Cur_SMS_Send_Emp_Name + ', Your Out Time is missing on ' + CONVERT(VARCHAR(11),@Cur_SMS_Send_For_Date,103) + ', Please Contact to HR/Admin.'
			
			Exec pr_SendSmsSQL @Cur_SMS_Send_Mobile_No,@SMS_Text,@Cur_cmp_id,@sResponse Out
			--Exec pr_SendSmsSQL '9824302520',@SMS_Text,@sResponse Out
		Fetch next From Cur_SMS_Send into @Cur_SMS_Send_Mobile_No,@Cur_SMS_Send_For_Date,@Cur_SMS_Send_Emp_Name,@Cur_cmp_id_1
	End 
	
END

