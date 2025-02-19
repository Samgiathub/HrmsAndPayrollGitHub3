---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Ticket]
	@Ticket_App_ID Numeric(18,0),
	@Ticket_Apr_ID Numeric(18,0) = 0,
	@Emp_ID Numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Ticket_Type_ID Numeric(18,0) = 0,
	@Ticket_Dept_ID Numeric(18,0) = 0,
	@Ticket_Priority_ID Numeric(18,0) = 0,
	@Ticket_Description Varchar(500) = '',
	@Ticket_Attachment Varchar(100) = null,
	@Ticket_Solution Varchar(200) = '',
    @S_Emp_ID Numeric(18,0) = 0,
    @Ticket_Status Numeric(5,0) = 0,
    @Login_ID numeric(18,0) = 0,
    @FromDate datetime = null,
    @ToDate datetime = null,
	@Send_To Numeric(18,0) = 0,
	@Type Char(2),
	@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Ticket_Gen_Date datetime

SET @Ticket_Gen_Date = GETDATE() 

--select @Ticket_App_ID,@Type

IF @Type = 'B' --- Bind Rercord Ticket Type Master / Ticket Priority / Ticket Departmet
	BEGIN
		SELECT * FROM T0040_Ticket_Type_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
		SELECT * FROM T0040_Ticket_Priority WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
		
		SELECT * FROM
		(
			SELECT 1 AS 'Ticket_Dept_ID','IT' AS 'Ticket_Dept_Name'
			UNION
			SELECT 2 AS 'Ticket_Dept_ID','HR' AS 'Ticket_Dept_Name'
			UNION
			SELECT 3 AS 'Ticket_Dept_ID','Account' AS 'Ticket_Dept_Name'
			UNION
			SELECT 4 AS 'Ticket_Dept_ID','Travel Help Desk' AS 'Ticket_Dept_Name'
			
		) QRY
	END
ELSE IF @Type = 'I' --- For Ticket Application
	BEGIN
		BEGIN TRY
			EXEC P0090_Ticket_Application @Ticket_App_ID = @Ticket_App_ID Output,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,
			@Ticket_Type_ID = @Ticket_Type_ID,@Ticket_Gen_Date = @Ticket_Gen_Date,@Ticket_Dept_ID = @Ticket_Dept_ID,
			@Ticket_Priority = @Ticket_Priority_ID,@Ticket_Attachment = @Ticket_Attachment,@Ticket_Description = @Ticket_Description,
			@User_ID = @Login_ID,@Trantype = @Type,@Is_Candidate  = 0, @SendTo = @Send_To
	    
			SET @Result = 'Ticket application submitted successfully#True#'+ CAST(@Ticket_App_ID AS varchar(11)) 
			
			SELECT @Result
			
			SELECT  Ticket_App_ID, (Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'EmpFullName',Ticket_Type,Ticket_Dept_Name,
			(CASE WHEN Ticket_Priority = 'High' THEN '<B><span style=color:#e41a1a;>High</spam></B>' ELSE CASE WHEN Ticket_Priority = 'Medium' THEN '<B><span style=color:#efea37;>Medium</spam></B>' ELSE '<B><span style=color:#2fa013;>Low</spam></B>' END END ) AS 'Ticket_Priority',
			Ticket_Gen_Date,Ticket_Status,Ticket_Description,VT.Emp_ID,VT.Cmp_ID
			FROM V0090_Ticket_Application VT
			WHERE Ticket_App_ID = @Ticket_App_ID
			
			EXEC SP_Get_Email_ToCC_Ticket @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Ticket Open',@Flag = @Ticket_Dept_ID,@Is_Mobile = 1,@Send_To = @Send_To
			--EXEC SP_Get_Email_ToCC_Ticket @Emp_ID = @Send_To,@Cmp_ID = @Cmp_ID,@Module_Name = 'Ticket Open',@Flag = @Ticket_Dept_ID,@Is_Mobile = 1
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
Else if @Type = 'U' -- For Update Ticket Application
		Begin
		BEGIN TRY
			if Exists(SELECT 1 FROM T0090_Ticket_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
			AND Ticket_Type_ID = @Ticket_Type_ID AND Ticket_Status = 'O' AND Ticket_App_ID <> @Ticket_App_ID)
			BEGIN
				raiserror('@@Same Ticket Type Application is Exists.@@',16,2)
				return
			End
				
			Update T0090_Ticket_Application
				SET
					Ticket_Type_ID = @Ticket_Type_ID,
					Ticket_Gen_Date = @Ticket_Gen_Date,
					Ticket_Dept_ID = @Ticket_Dept_ID,
					Ticket_Priority = @Ticket_Priority_ID,
					Ticket_Attachment = @Ticket_Attachment,
					Ticket_Description = @Ticket_Description,
					--Ticket_Status = @Ticket_Status,
					Is_Candidate = 0,
					SendTo = @Send_To
			Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID

			SET @Result = 'Ticket Updated Sucessfully#True#'+ CAST(@Ticket_App_ID AS varchar(11)) 
			SELECT @Result

		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
		End
ELSE IF @Type = 'A' --- For Ticket Approval
	BEGIN
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID)
				BEGIN
					EXEC P0100_Ticket_Approval @Ticket_Apr_ID = @Ticket_Apr_ID  OUTPUT,@Ticket_App_ID = @Ticket_App_ID,
					@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Ticket_Type_ID = @Ticket_Type_ID,@Ticket_Gen_Date = @Ticket_Gen_Date,
					@Ticket_Dept_ID = @Ticket_Dept_ID,@Ticket_Priority = @Ticket_Priority_ID,@Ticket_Apr_Attachment = @Ticket_Attachment,
					@Ticket_Solution = @Ticket_Description,@S_Emp_ID = @S_Emp_ID,@Ticket_Status = @Ticket_Status,
					@User_ID = @Login_ID,@Trantype = 'U'
				END
			ELSE
				BEGIN
					EXEC P0100_Ticket_Approval @Ticket_Apr_ID = @Ticket_Apr_ID  OUTPUT,@Ticket_App_ID = @Ticket_App_ID,
					@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Ticket_Type_ID = @Ticket_Type_ID,@Ticket_Gen_Date = @Ticket_Gen_Date,
					@Ticket_Dept_ID = @Ticket_Dept_ID,@Ticket_Priority = @Ticket_Priority_ID,@Ticket_Apr_Attachment = @Ticket_Attachment,
					@Ticket_Solution = @Ticket_Description,@S_Emp_ID = @S_Emp_ID,@Ticket_Status = @Ticket_Status,
					@User_ID = @Login_ID,@Trantype = 'I'
				END
			
			
			SET @Result = 'Ticket Approval Done#True#'+ CAST(@Ticket_Apr_ID AS varchar(11)) 
			SELECT @Result
			
			--SELECT  VT.Ticket_App_ID,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'EmpFullName',Ticket_Type,Ticket_Dept_Name,
			--(CASE WHEN Ticket_Priority = 'High' THEN '<B><span style=color:#e41a1a;>High</spam></B>' ELSE CASE WHEN Ticket_Priority = 'Medium' THEN '<B><span style=color:#efea37;>Medium</spam></B>' ELSE '<B><span style=color:#2fa013;>Low</spam></B>' END END ) AS 'Ticket_Priority',
			--Ticket_Gen_Date,Ticket_Description,VT.Emp_ID,VT.Cmp_ID,
			--(CASE WHEN Ticket_Status = 'On Hold' THEN '<B><span style=color:#efea37;>On Hold</spam></B>' ELSE '<B><span style=color:#2fa013;>Closed</spam></B>' END) AS 'Ticket_Status',
			--VT.appliedByEmail,ISNULL(TE.Email_ID,'') AS 'Email_ID',
			--(CASE WHEN Ticket_Status = 'On Hold' THEN 'Ticket On Hold' ELSE 'Ticket Closed' END) AS 'MailSubject',VT.On_Hold_Reason
			--FROM V0090_Ticket_Application VT
			--LEFT JOIN T0095_Ticket_Escalation TE WITH (NOLOCK) ON VT.Ticket_App_ID = TE.Ticket_App_ID
			--WHERE VT.Ticket_Apr_ID  = @Ticket_App_ID
			

			SELECT  VT.Ticket_App_ID,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'EmpFullName',Ticket_Type,Ticket_Dept_Name,
				(CASE WHEN Ticket_Priority = 'High' THEN '<B><span style=color:#e41a1a;>High</spam></B>' ELSE CASE WHEN Ticket_Priority = 'Medium' THEN '<B><span style=color:#efea37;>Medium</spam></B>' ELSE '<B><span style=color:#2fa013;>Low</spam></B>' END END ) AS 'Ticket_Priority',
				Ticket_Gen_Date,Ticket_Description,VT.Emp_ID,VT.Cmp_ID,
				(CASE WHEN Ticket_Status = 'On Hold' THEN '<B><span style=color:#efea37;>On Hold</spam></B>' ELSE '<B><span style=color:#2fa013;>Closed</spam></B>' END) AS 'Ticket_Status',
				VT.appliedByEmail,ISNULL(TE.Email_ID,'') AS 'Email_ID',
				(CASE WHEN Ticket_Status = 'On Hold' THEN 'Ticket On Hold' ELSE 'Ticket Closed' END) AS 'MailSubject',VT.On_Hold_Reason
				FROM V0090_Ticket_Application VT
				LEFT JOIN T0095_Ticket_Escalation TE WITH (NOLOCK) ON VT.Ticket_App_ID = TE.Ticket_App_ID
				WHERE VT.Ticket_App_ID  = @Ticket_App_ID

		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
ELSE IF @Type = 'L' --- For GET Ticket Application Status
	BEGIN
		BEGIN TRY
			SELECT * FROM V0090_Ticket_Application 
			WHERE Emp_ID = @Emp_ID 
			AND CONVERT(datetime,CONVERT(varchar(11),Ticket_Gen_Date,103),103) >= @FromDate
			AND CONVERT(datetime,CONVERT(varchar(11),Ticket_Gen_Date,103),103) <= @ToDate
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
ELSE IF @Type = 'S' --- For GET Ticket Application Records list for Approval
	BEGIN
		BEGIN TRY
			EXEC SP_Get_Ticket_Application @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Constrains=' AND ISNULL(Is_Candidate,0) = 0',@Flag = @Ticket_Status
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
ELSE IF @Type = 'D' --- For Ticket Dashboard Record
	BEGIN
		BEGIN TRY
			EXEC Get_Ticket_Summary @Cmp_ID = @Cmp_ID,@ChartType='header'
			
			EXEC Get_Ticket_Summary @Cmp_ID = @Cmp_ID,@ChartType='pie'
			
			EXEC Get_Ticket_Summary @Cmp_ID = @Cmp_ID,@ChartType='bardept'
			
			--EXEC Get_Ticket_Summary @Cmp_ID = @Cmp_ID,@ChartType='barmod'
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result
		END CATCH
	END
Else if @Type = 'R' -- For Remove Ticket Application
		Begin
			BEGIN TRY
				if Exists(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID )
					BEGIN
						raiserror('@@Ticket Type Application referance is Exists.@@',16,2)
						return
					END
				else
				begin
								Delete From T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
				
				SET @Result = 'Ticket Application Deleted Succesfully'

				select @Result  as Result
				
				end
				--Delete From T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
				--SET @Result = ERROR_MESSAGE()+'#True#'
			END TRY
			BEGIN CATCH
			
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result as Result
		END CATCH
		End

		Else if @Type = 'DE' -- For Remove Ticket Approval Record
		Begin
		--select 1
			BEGIN TRY
				if Exists(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  AND Ticket_App_ID = @Ticket_App_ID )
					BEGIN
					--select 12
					--select 1234
					Delete From T0100_Ticket_Approval Where Ticket_App_ID = @Ticket_App_ID and Cmp_ID=@Cmp_ID

					update T0090_Ticket_Application set Ticket_Status='O' where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID  and Cmp_ID=@Cmp_ID

					SET @Result = 'Ticket Approval Record Deleted Succesfully'

				select @Result  as Result
				return
				END
						--raiserror('@@Ticket Type Application referance is Exists.@@',16,2)
						--return
				else if Exists(SELECT 1 FROM T0090_Ticket_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  AND Ticket_App_ID = @Ticket_App_ID and Ticket_Status='H' )
				begin
				--select 123
				update T0090_Ticket_Application set Ticket_Status='O' where Ticket_App_ID = @Ticket_App_ID   and Cmp_ID=@Cmp_ID
				SET @Result = 'Ticket Approval Record Deleted Succesfully'

				select @Result  as Result
				return
				END
				else if Exists(SELECT 1 FROM T0090_Ticket_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  AND Ticket_App_ID = @Ticket_App_ID and Ticket_Status='C' )
				begin
				--select 123
				update T0090_Ticket_Application set Ticket_Status='O' where Ticket_App_ID = @Ticket_App_ID   and Cmp_ID=@Cmp_ID
				SET @Result = 'Ticket Approval Record Deleted Succesfully'

				select @Result  as Result
				return
				END
				

					
				--else
				--begin
				--				Delete From T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
				
				--SET @Result = 'Ticket Application Deleted Succesfully'

				--select @Result  as Result
				
				--end
				--Delete From T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
				--SET @Result = ERROR_MESSAGE()+'#True#'
			END TRY
			BEGIN CATCH
			
			SET @Result = ERROR_MESSAGE()+'#False#'
			SELECT @Result as Result
		END CATCH
		End
