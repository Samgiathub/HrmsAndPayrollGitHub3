-- =============================================
-- Author:		Niraj Parmar
-- Create date: 18/04/2022
-- Description:	Scheduler to get API data and insert to table
-- =============================================
CREATE PROCEDURE [dbo].[Mittsure_RestAPI_Integration_ToSql]
	@URL nvarchar(4000) = 'http://api.staffcare.in/StaffCareClientAPI/api/Attendance',
	@Object as int = 0,
	@ResponseText as varchar(8000) = '',
	@Body as varchar(8000) = '
	{
		"groupUserName": "MITTSURETECH",

		"userName": "ADMIN-MITTSURETECH",

		"userPassword": "MITTSURETECH@875",

		"lastId": 0
	}'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @vReturnCode int
	DECLARE @vResponse nvarchar(4000)
	DECLARE @Startdate varchar(10) = CONVERT(varchar(10), GetDate()-21, 126)
	DECLARE @Enddate varchar(10) = CONVERT(varchar(10), GetDate(), 126)
	DECLARE @lastId numeric(18,0) = 0
	DECLARE @IO_tran_ID numeric(18,0)

	--SELECT @lastId = ISNULL(MAX(Pk_PID),0) FROM Mittsure_Json_Master
	--Select @lastId

	BEGIN TRY

	SET @URL = 'http://api.staffcare.in/StaffCareClientAPI/api/Attendance'  -- Add API URL
	SET @Object = 0	                                                        -- Set Default 0
	SET @ResponseText = ''                                                  -- Set Default blank
	SET @Body = '
	{
		"groupUserName": "MITTSURETECH",

		"userName": "ADMIN-MITTSURETECH",

		"userPassword": "MITTSURETECH@875",

		"lastId": '+CAST(@lastId as varchar(5))+'
	}'


	IF NOT EXISTS(SELECT 1 FROM Sys.configurations WHERE name = 'Ole Automation Procedures' and value = 1)
	BEGIN -- Settings for enabled HTTP request calling
		EXEC master.dbo.sp_configure 'show advanced options', 1;
		RECONFIGURE WITH OVERRIDE

		EXEC master.dbo.sp_configure 'Ole Automation Procedures', 1;
		RECONFIGURE WITH OVERRIDE
		print 'RECONFIGURED'
	END

	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false'
	EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	EXEC sp_OAMethod @Object, 'send', null, @body
	
	DECLARE @tResponse TABLE (ResponseText VARCHAR(8000))
	INSERT INTO @tResponse (ResponseText)

	EXEC @vReturnCode = sp_OAGetProperty @Object, 'ResponseText'
	
	Select * from @tResponse
	--return

	--DECLARE @TestTable nvarchar(max) 
	--Select @TestTable = REPLACE(REPLACE(ResponseText,'[','<datas> '),'}]','} />') from @tResponse
	--set @TestTable = REPLACE(@TestTable, '{"Pk_PID":', '<data Pk_PID=')
	--set @TestTable = REPLACE(@TestTable, ',"Fk_Staff_ID":', ' Fk_Staff_ID=')
	--set @TestTable = REPLACE(@TestTable, ',"Staff_Name":', ' Staff_Name=')
	--set @TestTable = REPLACE(@TestTable, ',"Start_date_time":',' Start_date_time=')
	--set @TestTable = REPLACE(@TestTable, ',"Start_Detail":', ' Start_Detail=')
	--set @TestTable = REPLACE(@TestTable, ',"End_date_time":', ' End_date_time=')
	--set @TestTable = REPLACE(@TestTable, ',"End_Detail":', ' End_Detail=')
	--set @TestTable = REPLACE(@TestTable, ',"start_meter":', ' start_meter=')
	--set @TestTable = REPLACE(@TestTable, ',"end_meter":', ' end_meter=')
	--set @TestTable = REPLACE(@TestTable, ',"distance":', ' distance=')
	--set @TestTable = REPLACE(@TestTable, ',"da_type":', ' da_type=')
	--set @TestTable = REPLACE(@TestTable, ',"tot_time":', ' tot_time=')
	--set @TestTable = REPLACE(@TestTable, ',"route_name":', ' route_name=')
	--set @TestTable = REPLACE(@TestTable, ',"visit_route":', ' visit_route=')
	--set @TestTable = REPLACE(@TestTable, ',"workingType":', ' workingType=')
	--set @TestTable = REPLACE(@TestTable, ',"workingDay":', ' workingDay=')
	--set @TestTable = REPLACE(@TestTable, ',"workingDayDetails":', ' workingDayDetails=')
	--set @TestTable = REPLACE(@TestTable, ',"Start_Lat":', ' Start_Lat=')
	--set @TestTable = REPLACE(@TestTable, ',"Start_Log":', ' Start_Log=')
	--set @TestTable = REPLACE(@TestTable, ',"End_Lat":', ' End_Lat=')
	--set @TestTable = REPLACE(@TestTable, ',"End_Log":', ' End_Log=')
	--set @TestTable = REPLACE(@TestTable, ',"Start_Extra":', ' Start_Extra=')
	--set @TestTable = REPLACE(@TestTable, ',"End_Extra":', ' End_Extra=')
	--set @TestTable = REPLACE(@TestTable, ',"start_photo":', ' start_photo=')
	--set @TestTable = REPLACE(@TestTable, ',"End_Photo":', ' End_Photo=')
	--set @TestTable = REPLACE(@TestTable, ',"Emp_ID":', ' Emp_ID=')
	--set @TestTable = REPLACE(@TestTable, '},', ' />')
	--set @TestTable = REPLACE(@TestTable, '"} />', '" /> </datas>')

	--Select @TestTable

	--DECLARE @lXML XML                    
	--SET @lXML = CAST(@TestTable AS xml)

	--SELECT @lXML

	------ 1 WAY TO DROP
	----IF OBJECT_ID('tempdb..##TBL_ConvertJSONToTableObject') IS Not NULL
	----BEGIN		
	----	drop table ##TBL_ConvertJSONToTableObject
	----END 
	------ 2 WAY TO DROP
	----IF EXISTS
	----(
	----	SELECT *
	----	FROM sys.objects
	----	WHERE object_id = OBJECT_ID(N'dbo.##TBL_ConvertJSONToTableObject')
	----)
	----BEGIN
	----	DROP TABLE dbo.##TBL_ConvertJSONToTableObject;
	----END;
	---- 3 WAY TO DROP
	--DROP TABLE IF EXISTS ##TBL_ConvertJSONToTableObject;

	--CREATE TABLE ##TBL_ConvertJSONToTableObject(
	--	EmployeeId int not null,
	--	EmpCode varchar(200),
	--	DayInDate varchar(200),
	--	DayInTime varchar(200),
	--	DayOutDate varchar(200),
	--	DayOutTime varchar(200)
	--)


	--INSERT INTO ##TBL_ConvertJSONToTableObject (
	--	EmployeeId,
	--	EmpCode,
	--	DayInDate,
	--	DayInTime,
	--	DayOutDate,
	--	DayOutTime
	--)
	--SELECT T.c.value('@EmployeeId','int') AS EmployeeId,
	--rtrim(Ltrim(replace(T.c.value('@EmpCode','varchar(200)'),' ',''))) as EmpCode,
	--T.c.value('@DayInDate','varchar(200)') AS DayInDate,
	--T.c.value('@DayInTime','varchar(200)') AS DayInTime,
	--T.c.value('@DayOutDate','varchar(200)') AS DayOutDate,
	--T.c.value('@DayOutTime','varchar(200)') AS DayOutTime
	--FROM @lXML.nodes('/datas/data') AS T(c)
	--WHERE T.c.value('@EmpCode','varchar(200)') not like '%[A-Z]%'
	--and T.c.value('@EmpCode','varchar(200)') like '%[0-9]%'

	--Select * from ##TBL_ConvertJSONToTableObject
	----UPDATE ##TBL_ConvertJSONToTableObject
	----SET DayOutDate = '01/01/1900', DayOutTime = '00:00:00'
	----WHERE ISNULL(DayOutDate, '') = '' or ISNULL(DayOutTime, '') = ''
	

	--Declare @MaxNo numeric(18,0)
 --   select @MaxNo= isnull(MAX(IO_Tran_ID),0) from dbo.T9999_DEVICE_INOUT_DETAIL


 --  	insert into dbo.T9999_DEVICE_INOUT_DETAIL
	--select @MaxNo + ROW_NUMBER() OVER (ORDER BY EmpCode) AS IO_TranID, API_Data.Cmp_ID,
	--API_Data.EmpCode, API_Data.[Datetime], API_Data.[IP], API_Data.Flag, API_Data.IsVerify 
	--from  
	--(  
	--	SELECT @Cmp_ID as Cmp_ID
	--	 ,TRY_CAST(rtrim(Ltrim(replace(EmpCode,' ',''))) as NUMERIC(18,0)) as EmpCode
	--	, CAST(CONVERT(DATETIME, DayInDate + ' ' + DayInTime, 103) as Datetime) as [Datetime]
	--	, 'RestAPI' as [IP]
	--	, '0' as Flag
	--	, 0 as IsVerify
	--	From ##TBL_ConvertJSONToTableObject
	--	where ISNUMERIC(EmpCode) = 1 and EmpCode not like '%[A-Z]%'
	--	and EmpCode like '%[0-9]%' AND
	--	ISNULL(DayInDate, '') <> '' AND ISNULL(DayInTime, '') <> ''

	--	UNION ALL

	--	SELECT @Cmp_ID as Cmp_ID
	--	,TRY_CAST(rtrim(Ltrim(replace(EmpCode,' ',''))) as NUMERIC(18,0)) as EmpCode
	--	,CAST(CONVERT(DATETIME, DayOutDate + ' ' + DayOutTime, 103) as Datetime) as [Datetime]
	--	,'RestAPI' as [IP]
	--	,'1' as Flag,
	--	0 as IsVerify
	--	From ##TBL_ConvertJSONToTableObject
	--	where ISNUMERIC(EmpCode) = 1 and EmpCode not like '%[A-Z]%'
	--	and EmpCode like '%[0-9]%' AND
	--	ISNULL(DayOutDate, '') <> '' or ISNULL(DayOutTime, '') <> ''

	--)as API_Data 
	--left join(select Enroll_No as Enroll_No, IO_DateTime as MaxDate
	--from dbo.T9999_DEVICE_INOUT_DETAIL) as InOut
	--on API_Data.EmpCode = InOut.Enroll_No and API_Data.[Datetime] = MaxDate
	--inner join T0080_EMP_MASTER WITH (NOLOCK)
	--on API_Data.EmpCode = T0080_EMP_MASTER.Enroll_No
	--where isnull(InOut.Enroll_No,0) = 0 AND
	--API_Data.[Datetime] <= CONVERT(DATETIME, GETDATE(), 103)
	--AND EmpCode not like '%[A-Z]%' and EmpCode like '%[0-9]%'

 --   --EXEC (@SQL)
	--exec SP_EMP_INOUT_SYNCHRONIZATION_AUTO 1  

	EXEC sp_OADestroy @Object
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
    
END
