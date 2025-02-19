


---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_WEEKOFF_ROSTER]
	  @Cmp_ID numeric(18,0)
	 ,@Emp_ID numeric(18,0)
	 ,@For_Date datetime
	 ,@Is_Cancel	tinyint = 0
	 ,@tran_type varchar(1) = 'I'
	 ,@User_Id numeric(18,0) = 0 --Mukti(23022017)
	 ,@WTRAN_ID NUMERIC(18,0)  = 0 output-- ADDED BY RAJPUT ON 26062019
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		

	
		
		if @tran_type = 'D'
			BEGIN
				IF(ISNULL(@WTRAN_ID,0) <> 0)
					delete FROM T0100_WEEKOFF_ROSTER where TRAN_ID = @WTRAN_ID AND Emp_id = @Emp_ID AND For_date = @For_Date 
				ELSE
					delete FROM T0100_WEEKOFF_ROSTER where Emp_id = @Emp_ID AND For_date = @For_Date 
			END
		else
			BEGIN
					 
					if ((select setting_value from t0040_setting where setting_name ='Restrict Weekoff in Monthly Roster, if more than Limit' and cmp_id = @cmp_id) = 1)
					BEGIN 
							DECLARE @Month INT = month(@For_Date)
							DECLARE @Year INT = year(@For_Date)
							
							DECLARE @FromDate DATE = DATEFROMPARTS(@Year, @Month, 1)
							DECLARE @ToDate DATE = EOMONTH(@FromDate)

							IF OBJECT_ID('tempdb..#temp') IS NOT NULL 
								DROP TABLE #temp
		
							Create table #temp(
								Row_id numeric,
								Emp_id numeric,
								Cmp_id numeric,
								Alpha_emp_cod varchar(50),
								Emp_full_Name varchar(250),
								For_Date date,
								shift_ID numeric,
								shift_Time varchar(50),
								Shift_WO varchar(10),
								Fix_weekOff int
							)

							Insert into #temp
							exec Get_Roster_Shift_Weekoff_Monthly @Cmp_ID=@cmp_id,@From_Date=@FromDate,@To_Date=@ToDate,@Emp_ID =@Emp_ID,@Branch_ID=0	
							
							IF Not EXISTS (select 1 from #temp where Fix_WeekOff = 1 and For_date = @For_Date and Emp_id = @emp_id and cmp_id = @cmp_id)
							BEGIN
								Raiserror('Restrict Weekoff in Monthly Roster, if more than Limit',16,2)
								return -1
							END
							IF @Is_Cancel = 1 
							BEGIN
								Raiserror('Restrict Weekoff in Monthly Roster, if more than Limit',16,2)
								return -1
							END
					END


					DECLARE @tran_id numeric(18,0)
					SELECT @tran_id = isnull(max(Tran_Id),0) + 1 FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK)
				
					--IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WHERE @For_Date >= Month_St_Date and @For_Date <= Month_End_Date and Emp_ID = @Emp_id)
					--	BEGIN
					--		Raiserror('cannot be Deleted Reference Exist In Salary',16,2)
					--		return -1
					--	END

					Declare @Is_Cancel_WO tinyint = 0
					IF exists (SELECT Tran_Id FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) where Emp_id = @Emp_ID AND For_date = @For_Date)
						begin					
								SELECT @Is_Cancel_WO = is_Cancel_WO FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) where Emp_id = @Emp_ID AND For_date = @For_Date  --Added by Jaina 18-01-2018
								
								if @Is_Cancel_WO = 1   --Added by Jaina 18-01-2018
									begin
										delete FROM T0100_WEEKOFF_ROSTER where Emp_id = @Emp_ID AND For_date = @For_Date
									ENd
								Else
									begin
										delete FROM T0100_WEEKOFF_ROSTER where Emp_id = @Emp_ID AND For_date = @For_Date
										
										INSERT INTO T0100_WEEKOFF_ROSTER
										  (Tran_Id, Cmp_id, Emp_id, For_date, is_Cancel_WO,[User_ID],System_Date)
										VALUES     (@tran_id,@Cmp_ID ,@Emp_ID ,@For_Date,@Is_Cancel,@User_Id,GETDATE())
									END
						end
					else
						begin
								INSERT INTO T0100_WEEKOFF_ROSTER
								  (Tran_Id, Cmp_id, Emp_id, For_date, is_Cancel_WO,[User_ID],System_Date)
								VALUES     (@tran_id,@Cmp_ID ,@Emp_ID ,@For_Date,@Is_Cancel,@User_Id,GETDATE())
						end
			END

	RETURN




