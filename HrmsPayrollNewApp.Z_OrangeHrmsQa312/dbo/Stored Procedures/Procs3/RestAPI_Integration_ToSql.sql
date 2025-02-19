-- =============================================
-- Author:		Niraj Parmar
-- Create date: 18/04/2022
-- Description:	Scheduler to get API data and insert to table
-- =============================================
CREATE PROCEDURE [dbo].[RestAPI_Integration_ToSql]
	@URL nvarchar(4000) = 'http://sfa.arkray.co.in:8080/WebApi/api/EmployeeAttendence/GetAttendenceData/',
	@Object as int = 0,
	@ResponseText as varchar(8000) = '',
	@Body as varchar(8000) = '
	{
	"Empcode": "",
	"StartDate": "2022-04-14",
	"EndDate": "2022-04-15",
	"CompanyId": 1
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
	DECLARE @Cmp_ID numeric(18,0) = 1
	DECLARE @IO_tran_ID numeric(18,0)

	BEGIN TRY

	SET @URL = 'http://sfa.arkray.co.in:8080/WebApi/api/EmployeeAttendence/GetAttendenceData/'  -- Add API URL
	SET @Object = 0	                                                                            -- Set Default 0
	SET @ResponseText = ''                                                                      -- Set Default 0
	SET @Body = '
	{
	"Empcode": "",
	"StartDate": "'+@Startdate+'",
	"EndDate": "'+@Enddate+'",
	"CompanyId": '+CAST(@Cmp_ID as varchar(5))+'
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

	DECLARE @tResponse TABLE (ResponseText nvarchar(max))
	INSERT INTO @tResponse (ResponseText)
	EXEC @vReturnCode = sp_OAGetProperty @Object, 'ResponseText' --, @vResponse OUTPUT
	

	DECLARE @TestTable varchar(max) 
	Select @TestTable = REPLACE(REPLACE(ResponseText,'{"statuscode":true,"data":[','<datas> '),'}]}','} />') from @tResponse
	set @TestTable = REPLACE(@TestTable, '{"EmployeeId":', '<data EmployeeId="')
	set @TestTable = REPLACE(@TestTable, ',"EmpCode":', '" EmpCode=')
	set @TestTable = REPLACE(@TestTable, ',"DayInDate":', ' DayInDate=')
	set @TestTable = REPLACE(@TestTable, ',"DayInTime":',' DayInTime=')
	set @TestTable = REPLACE(@TestTable, ',"DayOutDate":', ' DayOutDate=')
	set @TestTable = REPLACE(@TestTable, ',"DayOutTime":', ' DayOutTime=')
	set @TestTable = REPLACE(@TestTable, '},', ' />')
	set @TestTable = REPLACE(@TestTable, '"} />', '" /> </datas>')


	DECLARE @lXML XML                    
	SET @lXML = CAST(@TestTable AS xml)

	---- 1 WAY TO DROP
	--IF OBJECT_ID('tempdb..##TBL_ConvertJSONToTableObject') IS Not NULL
	--BEGIN		
	--	drop table ##TBL_ConvertJSONToTableObject
	--END 
	---- 2 WAY TO DROP
	--IF EXISTS
	--(
	--	SELECT *
	--	FROM sys.objects
	--	WHERE object_id = OBJECT_ID(N'dbo.##TBL_ConvertJSONToTableObject')
	--)
	--BEGIN
	--	DROP TABLE dbo.##TBL_ConvertJSONToTableObject;
	--END;
	-- 3 WAY TO DROP
	DROP TABLE IF EXISTS ##TBL_ConvertJSONToTableObject;

	CREATE TABLE ##TBL_ConvertJSONToTableObject(
		EmployeeId int not null,
		EmpCode varchar(200),
		DayInDate varchar(200),
		DayInTime varchar(200),
		DayOutDate varchar(200),
		DayOutTime varchar(200)
	)


	INSERT INTO ##TBL_ConvertJSONToTableObject (
		EmployeeId,
		EmpCode,
		DayInDate,
		DayInTime,
		DayOutDate,
		DayOutTime
	)
	SELECT T.c.value('@EmployeeId','int') AS EmployeeId,
	rtrim(Ltrim(replace(T.c.value('@EmpCode','varchar(200)'),' ',''))) as EmpCode,
	T.c.value('@DayInDate','varchar(200)') AS DayInDate,
	T.c.value('@DayInTime','varchar(200)') AS DayInTime,
	T.c.value('@DayOutDate','varchar(200)') AS DayOutDate,
	T.c.value('@DayOutTime','varchar(200)') AS DayOutTime
	FROM @lXML.nodes('/datas/data') AS T(c)
	WHERE T.c.value('@EmpCode','varchar(200)') not like '%[A-Z]%'
	and T.c.value('@EmpCode','varchar(200)') like '%[0-9]%'

	Select * from ##TBL_ConvertJSONToTableObject
	--UPDATE ##TBL_ConvertJSONToTableObject
	--SET DayOutDate = '01/01/1900', DayOutTime = '00:00:00'
	--WHERE ISNULL(DayOutDate, '') = '' or ISNULL(DayOutTime, '') = ''
	

	Declare @MaxNo numeric(18,0)
    select @MaxNo= isnull(MAX(IO_Tran_ID),0) from dbo.T9999_DEVICE_INOUT_DETAIL


   	insert into dbo.T9999_DEVICE_INOUT_DETAIL
	select @MaxNo + ROW_NUMBER() OVER (ORDER BY EmpCode) AS IO_TranID, API_Data.Cmp_ID,
	API_Data.EmpCode, API_Data.[Datetime], API_Data.[IP], API_Data.Flag, API_Data.IsVerify 
	from  
	(  
		SELECT @Cmp_ID as Cmp_ID
		 ,TRY_CAST(rtrim(Ltrim(replace(EmpCode,' ',''))) as NUMERIC(18,0)) as EmpCode
		, CAST(CONVERT(DATETIME, DayInDate + ' ' + DayInTime, 103) as Datetime) as [Datetime]
		, 'RestAPI' as [IP]
		, '0' as Flag
		, 0 as IsVerify
		From ##TBL_ConvertJSONToTableObject
		where ISNUMERIC(EmpCode) = 1 and EmpCode not like '%[A-Z]%'
		and EmpCode like '%[0-9]%' AND
		ISNULL(DayInDate, '') <> '' AND ISNULL(DayInTime, '') <> ''

		UNION ALL

		SELECT @Cmp_ID as Cmp_ID
		,TRY_CAST(rtrim(Ltrim(replace(EmpCode,' ',''))) as NUMERIC(18,0)) as EmpCode
		,CAST(CONVERT(DATETIME, DayOutDate + ' ' + DayOutTime, 103) as Datetime) as [Datetime]
		,'RestAPI' as [IP]
		,'1' as Flag,
		0 as IsVerify
		From ##TBL_ConvertJSONToTableObject
		where ISNUMERIC(EmpCode) = 1 and EmpCode not like '%[A-Z]%'
		and EmpCode like '%[0-9]%' AND
		ISNULL(DayOutDate, '') <> '' or ISNULL(DayOutTime, '') <> ''

	)as API_Data 
	left join(select Enroll_No as Enroll_No, IO_DateTime as MaxDate
	from dbo.T9999_DEVICE_INOUT_DETAIL) as InOut
	on API_Data.EmpCode = InOut.Enroll_No and API_Data.[Datetime] = MaxDate
	inner join T0080_EMP_MASTER WITH (NOLOCK)
	on API_Data.EmpCode = T0080_EMP_MASTER.Enroll_No
	where isnull(InOut.Enroll_No,0) = 0 AND
	API_Data.[Datetime] <= CONVERT(DATETIME, GETDATE(), 103)
	AND EmpCode not like '%[A-Z]%' and EmpCode like '%[0-9]%'

    --EXEC (@SQL)
	exec SP_EMP_INOUT_SYNCHRONIZATION_AUTO 1  

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
