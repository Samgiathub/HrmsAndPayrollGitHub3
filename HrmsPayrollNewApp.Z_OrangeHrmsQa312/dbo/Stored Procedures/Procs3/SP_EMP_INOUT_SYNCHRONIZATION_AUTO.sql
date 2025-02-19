
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_AUTO]
	@CMP_ID NUMERIC 
As


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

	--Added by Hardik 15/06/2016
	DECLARE	@In_Out_Flag_SP tinyint
	SET @In_Out_Flag_SP = 0

	SELECT	@In_Out_Flag_SP = ISNULL(Setting_Value,0) 
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Setting_Name='In and Out Punch depends on Device In-Out Flag' and Cmp_ID = @Cmp_ID
	 

	DECLARE @Emp_ID NUMERIC(18,0)
	--DECLARE @Cmp_ID int
	DECLARE @IO_DateTime datetime
	DECLARE @IP_Address nvarchar(50)
	Declare @In_Out_flag numeric 
	Declare @Prev_Cmp_Id int -- Added by Hardik 01/08/2019

	DECLARE Emp_InOut_cursor CURSOR FOR 

	SELECT	MaxDt.Emp_ID,MaxDt.Cmp_ID,InOut.IO_DateTime,InOut.IP_Address,--(CASE WHEN  ISNULL(InOut.In_Out_flag,'') = '' THEN 0 ELSE InOut.In_Out_Flag END) AS In_Out_flag
			(CASE WHEN  ISNULL(InOut.In_Out_flag,'') = '' THEN -1 
			when isnull(I.Flag,'') = '' then  -1
			when I.Flag = 'All' then -1
			when I.Flag = 'In' then 0
			when I.Flag = 'Out' then 1
			 ELSE InOut.In_Out_Flag END) AS 'In_Out_flag'	--added by krushna 27012020
	FROM	T9999_DEVICE_INOUT_DETAIL AS InOut WITH (NOLOCK)
			INNER JOIN (
						SELECT	e.Cmp_Id,e.Emp_ID,E.Enroll_No,
								ISNULL(CASE WHEN ISNULL(In_Time,'01-01-1900') > ISNULL(Out_Time,'01-01-1900') THEN In_Time ELSE Out_Time END,'01-01-1900') AS InOut_Time 
						FROM	T0080_Emp_Master e WITH (NOLOCK)
								LEFT OUTER JOIN (	SELECT	eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time 
													FROM	T0150_Emp_Inout_Record eir WITH (NOLOCK)
													GROUP BY emp_ID ) q ON e.emp_ID = q.emp_ID  
						WHERE (isnull(emp_Left,'N') <> 'Y' OR E.Emp_Left_Date > GETDATE()) 
						) AS MaxDt ON InOut.Enroll_No = MaxDt.Enroll_No
			left join T0040_IP_MASTER I WITH (NOLOCK) on InOut.IP_Address = I.IP_ADDRESS 
	WHERE	CAST(CAST(InOut.IO_DateTime AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(InOut.IO_DateTime) AS DATETIME) > CAST(CAST(MaxDt.InOut_Time AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(MaxDt.InOut_Time) AS DATETIME)
	ORDER BY InOut.Enroll_No,InOut.IO_DateTime
	  
	OPEN Emp_InOut_cursor
	FETCH NEXT FROM Emp_InOut_cursor INTO @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_flag
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @IO_DATETIME = CAST(CAST(@IO_DATETIME AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME) AS DATETIME)

			if Isnull(@Prev_Cmp_Id,0) <> @CMP_ID
				Begin
					Set @In_Out_Flag_SP = 0

					SELECT	@In_Out_Flag_SP = ISNULL(Setting_Value,0) 
					FROM	T0040_SETTING WITH (NOLOCK)
					WHERE	Setting_Name='In and Out Punch depends on Device In-Out Flag' and Cmp_ID = @Cmp_ID
				End
			
			if @In_Out_flag =-1	 --added by krushna 27012020
				begin
					goto NxtLine
				end 

			IF @In_Out_Flag_SP = 1 --Added by Hardik 15/06/2016
			Begin
				EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --------------Sp will Execute for HNG Halol 17022016----------------------------------
			End
			ELSE if @In_Out_Flag_SP = 2
				begin
				EXEC SP_EMP_INOUT_SYNCHRONIZATION_12AM_SHIFT_TIME @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --- Added for Aculife 
				end
			Else
				begin
					NxtLine:	
					----if @Emp_ID= 13964
					----	select @Emp_ID

					EXEC SP_EMP_INOUT_SYNCHRONIZATION  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,0,0
				end
			Set @Prev_Cmp_Id = @CMP_ID

			FETCH NEXT FROM Emp_InOut_cursor INTO  @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address,@In_Out_flag
		END 
	CLOSE Emp_InOut_cursor
	DEALLOCATE Emp_InOut_cursor

