

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_PostRequest]
	@Cmp_ID NUMERIC(18,0),
	@Emp_Login_ID numeric(18,0),
	@Request_ID	NUMERIC(18,0),
	@Request_Type varchar(100),
	@Request_Date datetime,
	@Request_Detail	varchar(500),
	@Feedback_Detail varchar(500),
	@Request_Status tinyint,
	@Login_ID varchar(500),
	@Type Char(1),
	@Result varchar(255) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


DECLARE @ToLogin_ID numeric(18,0)
DECLARE @DeviceID NVARCHAR(MAX)
DECLARE @EmpName VARCHAR(MAX)
SET @DeviceID = ''

--SELECT @ToLogin_ID = Login_ID FROM T0011_LOGIN WHERE Emp_ID = @Emp_ID

IF @Type = 'I'
	BEGIN
		BEGIN TRY
			IF @Login_ID <> ''
				BEGIN
					
					DECLARE REQUEST_CURSOR CURSOR FOR 
					SELECT CONVERT(numeric(18,0), Data) AS Data FROM dbo.Split(@Login_ID,'#')
					
					OPEN REQUEST_CURSOR
					
					FETCH NEXT FROM REQUEST_CURSOR INTO @ToLogin_ID
					
					WHILE @@FETCH_STATUS = 0
						BEGIN
						
							EXEC P0090_Common_Request_Detail @Request_ID OUTPUT,@Cmp_id = @Cmp_ID,@emp_login_id = @Emp_Login_ID,
							@request_type = @Request_Type,@request_date = @Request_Date,@request_detail = @Request_Detail,
							@status = @Request_Status,@Login_id = @ToLogin_ID,@feedback_detail = '',@tran_type='Insert'	
						
							FETCH NEXT FROM REQUEST_CURSOR INTO @ToLogin_ID
								
						END
					CLOSE REQUEST_CURSOR
					DEALLOCATE REQUEST_CURSOR
				END
			
			
			SET @EmpName = (SELECT EM.Emp_Full_Name
			FROM T0011_LOGIN LM WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LM.Emp_ID = EM.Emp_ID
			WHERE LM.Login_ID = @Emp_Login_ID)
			
			--SET @DeviceID = (SELECT  DISTINCT(EI.DeviceID) + ',' 
			--FROM T0011_LOGIN LM
			--INNER JOIN T0095_Emp_IMEI_Details EI ON LM.Emp_ID = EI.Emp_ID
			--WHERE LM.Login_ID IN (REPLACE(@Login_ID,'#',','))
			--FOR XML PATH(''))
			
			SET @DeviceID = (SELECT DISTINCT(EI.DeviceID) + ',' 
			FROM T0011_LOGIN LM WITH (NOLOCK)
			INNER JOIN T0095_Emp_IMEI_Details EI WITH (NOLOCK) ON LM.Emp_ID = EI.Emp_ID
			INNER JOIN
			(
				SELECT CONVERT(numeric(18,0), Data) AS Login_ID FROM dbo.Split(@Login_ID,'#')
			) D ON LM.Login_ID = D.Login_ID
			FOR XML PATH(''))
			
			
			SET @Result = 'Request Post Successfully#True#'
			
			IF @DeviceID <> ''
				BEGIN
					SELECT @Result AS 'Result',@EmpName AS 'EmpName',LEFT(@DeviceID, LEN(@DeviceID) - 1) AS 'DeviceID'
				END
			ELSE
				BEGIN
				    --SET @Result = 'Request Post Successfully#True#'
					SELECT @Result AS 'Result',@EmpName AS 'EmpName',LEFT(@DeviceID, LEN(@DeviceID) - 1) AS 'DeviceID' --AS 'Result' --added when @DeviceID=null
				END
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
ELSE IF @Type = 'U'
	BEGIN
		BEGIN TRY
			--EXEC P0090_Common_Request_Detail @request_id = @Request_ID,@Cmp_id = @Cmp_ID,@emp_login_id = @Emp_Login_ID,@request_type = @Request_Type,@request_date = @Request_Date,@request_detail = @Request_Detail,@status = @Request_Status,@Login_id = @Login_ID,@feedback_detail = @Feedback_Detail,@tran_type='Update'	
			
			UPDATE T0090_Common_Request_Detail SET STATUS = 1,Feedback_detail = @Feedback_Detail
			WHERE request_id = Request_ID
			
			SET @EmpName = (SELECT EM.Emp_Full_Name
			FROM T0011_LOGIN LM WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LM.Emp_ID = EM.Emp_ID
			WHERE LM.Login_ID = @Emp_Login_ID)
			
			SET @DeviceID = (SELECT  DISTINCT(EI.DeviceID) + ',' 
			FROM T0011_LOGIN LM WITH (NOLOCK)
			INNER JOIN T0095_Emp_IMEI_Details EI WITH (NOLOCK) ON LM.Emp_ID = EI.Emp_ID
			WHERE LM.Login_ID IN (@Login_ID)
			FOR XML PATH(''))
			
			SET @Result = 'Request Post Successfully#True#'
			
			IF @DeviceID <> ''
				BEGIN
					SELECT @Result AS 'Result',@EmpName AS 'EmpName',LEFT(@DeviceID, LEN(@DeviceID) - 1) AS 'DeviceID'
				END
				
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
		END CATCH
	END
ELSE IF @Type = 'S'  -- Get Employee List
	BEGIN
		 
		 
		EXEC Get_Common_Request_Detail_Employee @cmp_id = @Cmp_ID,@Request_type = @Request_Type
		
		 
	END
ELSE IF @Type = 'R'  -- Get Reason List
	BEGIN	
		SELECT Res_Id,Reason_Name FROM T0040_Reason_Master WITH (NOLOCK) WHERE Type = @Request_Type AND Isactive = 1
	END



