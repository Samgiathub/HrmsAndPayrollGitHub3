CREATE PROCEDURE [dbo].[SP_Mobile_WebService_Attendance]
	@Attendance XML
AS

SET NOCOUNT ON;

BEGIN
	DECLARE @Emp_ID Numeric(18,0)
	DECLARE @Cmp_ID Numeric(18,0)
	DECLARE @Emp_Code varchar(50)
	DECLARE @In_Time varchar(50)
	DECLARE @Out_Time varchar(50)
	
	SELECT Attendance.value('(Code/text())[1]','varchar(50)') AS Code,
	Attendance.value('(In_Time/text())[1]','varchar(50)') AS In_Time,
	Attendance.value('(Out_Time/text())[1]','varchar(50)') AS Out_Time
	INTO #Attendance FROM @Attendance.nodes('/NewDataSet/Attendance') as Temp(Attendance)
	
	--SELECT * FROM #Attendance --WHERE Code = 'EP-0045'
	
	
	DECLARE ATTENDANCE_CURSOR CURSOR  FAST_FORWARD FOR
				
	SELECT Code,ISNULL(In_Time,'') AS 'In_Time',ISNULL(Out_Time,'') AS 'Out_Time' 
	FROM #Attendance --WHERE Code = 'EP-0045'
	OPEN ATTENDANCE_CURSOR
	FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_Code,@In_Time,@Out_Time
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Emp_ID = 0
			SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID FROM T0080_EMP_MASTER WHERE Old_Ref_No = @Emp_Code
			
			IF ISNULL(@Emp_ID,0) <> 0
				BEGIN
					IF @In_Time <> ''
						BEGIN
							IF NOT EXISTS (SELECT * FROM T9999_MOBILE_INOUT_DETAIL WHERE Emp_ID = @Emp_ID AND IO_Datetime = CONVERT(DATETIME,@In_Time) AND In_Out_Flag = 'I')
								BEGIN
									INSERT INTO T9999_MOBILE_INOUT_DETAIL(Cmp_ID,Emp_ID,IO_Datetime,In_Out_Flag,Reason)
									VALUES(@Cmp_ID,@Emp_ID,CONVERT(DATETIME,@In_Time),'I','CFM')
								END
						END
					IF @Out_Time <> ''
						BEGIN
							IF NOT EXISTS (SELECT * FROM T9999_MOBILE_INOUT_DETAIL WHERE Emp_ID = @Emp_ID AND IO_Datetime = CONVERT(DATETIME,@Out_Time) AND In_Out_Flag = 'O')
								BEGIN
									INSERT INTO T9999_MOBILE_INOUT_DETAIL(Cmp_ID,Emp_ID,IO_Datetime,In_Out_Flag,Reason)
									VALUES(@Cmp_ID,@Emp_ID,CONVERT(DATETIME,@Out_Time),'O','CFM')
								END
						END
				END 
			FETCH NEXT FROM ATTENDANCE_CURSOR INTO @Emp_Code,@In_Time,@Out_Time
		END
	CLOSE ATTENDANCE_CURSOR
	DEALLOCATE ATTENDANCE_CURSOR
	
	
	

END