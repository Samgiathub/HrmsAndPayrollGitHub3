

CREATE PROCEDURE [dbo].[SP_Mobile_AttendanceInsert]    
	@Emp_ID NUMERIC(18,0),
	@ForDate DATETIME,    
	@In_Time DATETIME,
	@User_Id NUMERIC(18,0),     
	@Reason VARCHAR(MAX),  
	@Out_Time DATETIME = null,
	@Latitude VARCHAR(50)= null,
	@Longitude VARCHAR(50)= null,
	@Address VARCHAR(MAX)= null,
	@IMEINo VARCHAR(50)= null,
	@Type VARCHAR(50)= '',
	@Result VARCHAR(100) OUTPUT,
	@TranID NUMERIC(18,0) = 0,
	@Emp_Image varchar(50)='',
	@Month int = 0,
	@Year int = 0
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @Company_ID NUMERIC(18,0)
DECLARE @IO_Tran_Id NUMERIC(18,0) 
DECLARE @IO_Tran_DetailsID NUMERIC(18,0)
Declare @IPAdd  varchar(50)
SET @IO_Tran_Id= NULL

IF @IMEINo <> ''
	BEGIN
		SET @IPAdd = 'Mobile(' + @IMEINo + ')'
	END
ELSE
	BEGIN
		SET @IPAdd = ''
	END

SELECT @Company_ID= ISNULL(Cmp_ID,0) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID= @Emp_ID

 

IF @Type = 'Check_in_out'
	BEGIN
		SELECT @IO_Tran_ID = IO_Tran_Id,@In_Time = In_Time,@Out_Time = Out_Time 
		FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		WHERE In_Time = 
		(
			SELECT MAX(In_Time) FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
			WHERE Emp_ID= @Emp_ID AND Cmp_id= @Company_ID AND CONVERT(VARCHAR(10),For_Date,120) = CONVERT(VARCHAR(10),GETDATE(),120)
		)
		AND Emp_ID= @Emp_ID AND Cmp_id= @Company_ID AND CONVERT(VARCHAR(10),For_Date,120) = CONVERT(VARCHAR(10),GETDATE(),120)
		IF @IO_Tran_ID IS NULL
			BEGIN
				--SET @Result = '0#In#1#0'
				SET @Result = 'In'
				RETURN
			END
		ELSE IF @In_Time IS NOT NULL AND @Out_Time IS NULL
			BEGIN
				--SET @Result = '0#Out#1#' + CONVERT(varchar(20), @In_Time ,113) --CAST(@In_Time as varchar(20))
				SET @Result = 'Out'
				RETURN
			END 
		ELSE IF @Out_Time IS NOT NULL
			BEGIN
				--SET @Result = '0#In#1#' + CONVERT(varchar(20), @Out_Time ,113) --CAST(@Out_Time as varchar(20))
				SET @Result = 'In' 
				RETURN
			END
	END
ELSE IF @Type = 'Image'
	BEGIN
		IF EXISTS(SELECT IO_Tran_DetailsID FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK) WHERE IO_Tran_DetailsID= @TranID)
			BEGIN
				UPDATE T9999_MOBILE_INOUT_DETAIL SET Emp_Image = @Emp_Image WHERE IO_Tran_DetailsID = @TranID
				SET @Result = '1#Image Upload Successfully#1#'
			END
		ELSE
			BEGIN
				SET @Result = '0#Image Not Upload Successfully#0#'
			END
	END
ELSE IF @Type = 'Report'
	BEGIN
		SELECT CONVERT(varchar(11),IO_Datetime,103) AS 'IODate',CONVERT(varchar(11),IO_Datetime,108) AS 'IOTIME', (CASE WHEN In_Out_Flag = 'I' THEN 'IN' ELSE 'OUT' END) AS 'In_Out_Flag',
		ISNULL(Reason,'') AS 'Reason',ISNULL(Emp_Image,'') AS 'Emp_Image',REPLACE(CONVERT(varchar(11), IO_Datetime,103),'/','') AS 'FolderName' 
		FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK)
		WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Company_ID AND 
		CAST(DATEPART(mm,IO_Datetime) AS NUMERIC(18))= @Month AND YEAR(IO_Datetime)= @Year 
		
		ORDER BY IO_Datetime DESC
	END
ELSE
	BEGIN
		IF @Address = '' AND @Latitude = '' AND @Longitude = ''
			BEGIN
				--SET @Result = '0#Internet OR GPS Not Working#0#'
				SET @Result = 'Internet OR GPS Not Working'
				RETURN				
			END
		
		
		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date<= @ForDate And Month_End_Date>= @ForDate and Emp_ID = @Emp_ID and Cmp_ID=@Company_ID)
			BEGIN
				--SET @Result = '0#Salary Already Exist#0#'
				SET @Result = 'Salary Already Exist'
				RETURN
			END

		--SELECT @IO_Tran_Id = IO_Tran_Id FROM T0150_EMP_INOUT_RECORD WHERE Emp_ID=@Emp_ID AND Cmp_ID = @Company_ID AND For_Date = @ForDate
		SELECT @IO_Tran_Id = IO_Tran_Id   FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE Emp_ID= @Emp_ID AND In_Time = ( SELECT MAX(In_Time) FROM T0150_emp_inout_Record WITH (NOLOCK) WHERE Emp_ID= @Emp_ID AND Cmp_id= @Company_ID AND Convert(varchar(10),For_Date,103) = Convert(varchar(10),@ForDate,103))
		
	--	SELECt @In_Time = '1900-01-01 00:00:00.000'
		--IF @IO_Tran_Id IS NULL
		IF @In_Time <> '1900-01-01 00:00:00.000'
			BEGIN
				SET @Address = ( CASE WHEN @Address <> '' THEN  'In   : ' + @Address ELSE '' END)
				INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason)
				VALUES(@IO_Tran_ID,@Company_ID,@Emp_Id,@In_Time,@IPAdd,'I',@Latitude,@Longitude,@Address,@Emp_Image,@Reason)
				
				
				SELECT @IO_Tran_DetailsID = MAX(IO_Tran_DetailsID) FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK)
				--SET @Result = CAST(@IO_Tran_DetailsID as varchar(11)) +'#Intime Inserted#1#'+ CONVERT(varchar(20), @In_Time ,113) -- CAST(@In_Time as varchar(20))
				SET @Result = 'Intime Inserted'
				
				--EXEC P0150_EMP_INOUT_RECORDS_Admin 0,@Emp_ID,@Company_ID,@ForDate,@In_Time,@Out_Time,'0',@Reason,'Mobile','I',2,0,@User_Id,'Mobile',0    
				
			END
		ELSE
			BEGIN
				SET @Address = ( CASE WHEN @Address <> '' THEN 'Out : ' + @Address ELSE '' END)
				SELECT @In_Time = In_Time FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) where IO_Tran_Id = @IO_Tran_Id
				--Update T0150_EMP_INOUT_RECORD Set  Out_Time = @Out_Time,In_Time=@In_Time,Duration = @Duration,Reason = @Reason where IO_Tran_Id= @IO_Tran_Id       
				INSERT INTO T9999_MOBILE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Emp_ID,IO_Datetime,IMEI_No,In_Out_Flag,Latitude,Longitude,Location,Emp_Image,Reason)
				VALUES(@IO_Tran_ID,@Company_ID,@Emp_Id,@Out_Time,@IPAdd,'O',@Latitude,@Longitude,@Address,@Emp_Image,@Reason)
				
				SELECT @IO_Tran_DetailsID = MAX(IO_Tran_DetailsID) FROM T9999_MOBILE_INOUT_DETAIL WITH (NOLOCK)
				--SET @Result = CAST(@IO_Tran_DetailsID as varchar(11)) +'#Outtime Inserted#1#'+ CONVERT(varchar(20), @Out_Time ,113) -- CAST(@Out_Time as varchar(20))
				SET @Result = 'Outtime Inserted'
				--EXEC P0150_EMP_INOUT_RECORDS_Admin @IO_Tran_Id,@Emp_ID,@Company_ID,@ForDate,@In_Time,@Out_Time,'0',@Reason,'Mobile','U',2,0,@User_Id,'Mobile',0   
			END
	END

