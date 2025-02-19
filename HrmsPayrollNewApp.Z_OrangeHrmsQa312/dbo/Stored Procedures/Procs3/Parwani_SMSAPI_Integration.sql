CREATE PROCEDURE [dbo].[Parwani_SMSAPI_Integration]
	@Emp_ID Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@MobileNo varchar(12),
	@In_Out_Time datetime,
	@Flag bit
    --@smstext as varchar(300),
    --@sResponse varchar(1000) OUT
as 
BEGIN 
	Declare @iReq int,@hr int 
	Declare @sUrl as varchar(500) 
	DECLARE @errorSource VARCHAR(8000)
	DECLARE @errorDescription VARCHAR(8000) 
	Declare @sResponse varchar(1000)

	Declare @Send_SMS bit = (Select Send_SMS from SMS_Settings)
	Declare @SMS_URL varchar(500)
	Declare @URL_Data varchar(500)
	Declare @API_Key varchar(50)
	Declare @Sender_ID varchar(50)
	Declare @Msg_Type varchar(50)
	Declare @Response varchar(50)
	Declare @Header_ID varchar(50)
	Declare @Entity_ID varchar(50)
	Declare @Temp_ID varchar(50)
	Declare @Temp_Name varchar(50)
	Declare @Temp_Message varchar(500)

	Declare @Emp_Name varchar(50)

	if @Send_SMS = 1
	Begin
		BEGIN TRY

			IF NOT EXISTS(SELECT 1 FROM Sys.configurations WHERE name = 'Ole Automation Procedures' and value = 1)
			BEGIN -- Settings for enabled HTTP request calling
				EXEC master.dbo.sp_configure 'show advanced options', 1;
				RECONFIGURE WITH OVERRIDE

				EXEC master.dbo.sp_configure 'Ole Automation Procedures', 1;
				RECONFIGURE WITH OVERRIDE
				print 'RECONFIGURED'
			END
			
			Select @SMS_URL = SMS_URL, @URL_Data = URLData, @API_Key = API_key, @Sender_ID = Sender_ID,
			@Msg_Type = Msg_Type, @Response = Response, @Header_ID = Header_ID, @Entity_ID = Entity_ID
			from SMS_Settings

			

			-- Create Object for XMLHTTP 
			EXEC @hr = sp_OACreate 'Microsoft.XMLHTTP', @iReq OUT 
		
			if @hr <> 0 
				Raiserror('sp_OACreate Microsoft.XMLHTTP FAILED!', 16, 1) 
			
			
			--set @sUrl='http://smsjust.com/sms/user/urlsms.php?apikey=43c0e9-848bf9-5acd93-9f5eb6-eec542&senderid=PCMATT&message=You%20have%20entered%20the%20office.PCMATT&dest_mobileno=#MobNo#&msgtype=TXT&response=Y&dltheaderid=1505164743742967596&dlttempid=1507165304873520713&dltentityid=1501540680000037689'
			set @sUrl = @SMS_URL + @URL_Data
			set @sUrl=REPLACE(@sUrl, '#API_key#', @API_Key) 
			set @sUrl=REPLACE(@sUrl, '#Sender_ID#', @Sender_ID) 
			set @sUrl=REPLACE(@sUrl, '#Dest_Mobile#', @MobileNo) 
			set @sUrl=REPLACE(@sUrl, '#Msg_Type#', @Msg_Type) 
			set @sUrl=REPLACE(@sUrl, '#Response#', @Response) 
			set @sUrl=REPLACE(@sUrl, '#Header_ID#', @Header_ID) 
			set @sUrl=REPLACE(@sUrl, '#Entity_ID#', @Entity_ID) 


			Select @Emp_Name = Emp_First_Name from T0080_EMP_MASTER where Emp_ID = @EMP_ID

			if @Flag = 0
			Begin
				Select @Temp_ID = Temp_ID, @Temp_Name = Temp_Name, @Temp_Message = Message
				from SMS_Template where Entity_ID = @Entity_ID and Temp_Name = 'Att-in'

				
				set @Temp_Message=REPLACE(@Temp_Message, '{#var#}entered', 'Dear ' + @Emp_Name + ', You entered')
				set @Temp_Message=REPLACE(@Temp_Message, 'on{#var#}', 'on ' + convert(varchar, @In_Out_Time, 106) + ' ')
				set @Temp_Message=REPLACE(@Temp_Message, 'at{#var#}', 'at ' + CONVERT(varchar(15),CAST(@In_Out_Time AS TIME),100))

				set @sUrl=REPLACE(@sUrl, '#Temp_ID#', @Temp_ID)
				set @sUrl=REPLACE(@sUrl, '#Message#', @Temp_Message)
			End
			Else
			Begin
				Select @Temp_ID = Temp_ID, @Temp_Name = Temp_Name, @Temp_Message = Message
				from SMS_Template where Entity_ID = @Entity_ID and Temp_Name = 'Att-out'

				set @Temp_Message=REPLACE(@Temp_Message, '{#var#}exited', 'Dear ' + @Emp_Name + ', You exited')
				set @Temp_Message=REPLACE(@Temp_Message, 'on{#var#}', 'on ' + convert(varchar, @In_Out_Time, 106) + ' ')
				set @Temp_Message=REPLACE(@Temp_Message, 'at{#var#}', 'at ' + CONVERT(varchar(15),CAST(@In_Out_Time AS TIME),100))

				set @sUrl=REPLACE(@sUrl, '#Temp_ID#', @Temp_ID)
				set @sUrl=REPLACE(@sUrl, '#Message#', @Temp_Message)
			End


			--set @sUrl=REPLACE(@sUrl,'#Msg#',@smstext) 

			-- sms code start 
			EXEC @hr = sp_OAMethod @iReq, 'Open', NULL, 'GET', @sUrl, true 
		
			if @hr <> 0 
				Raiserror('sp_OAMethod Open FAILED!', 16, 1)

			EXEC @hr = sp_OAMethod @iReq, 'send' 

			if @hr <> 0 
			Begin 
				EXEC sp_OAGetErrorInfo @iReq, @errorSource OUTPUT, @errorDescription OUTPUT
				SELECT [Error Source] = @errorSource, [Description] = @errorDescription
				Raiserror('sp_OAMethod Send FAILED!', 16, 1) 
			End
			else 
			Begin
				EXEC @hr = sp_OAGetProperty @iReq,'responseText', @sResponse OUT 
			
				--insert into send_log (Id, mobile, sendtext, response, created, createddate) 
				--values((Select ISNULL(MAX(ID),0)+1 FROM send_log), @MobileNo, @smstext, @sResponse, 'System', GETDATE())
			end

		END TRY  
		BEGIN CATCH  
			SELECT  
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState
				,ERROR_LINE () AS ErrorLine 
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_MESSAGE() AS ErrorMessage;  
		END CATCH; 
	End
END