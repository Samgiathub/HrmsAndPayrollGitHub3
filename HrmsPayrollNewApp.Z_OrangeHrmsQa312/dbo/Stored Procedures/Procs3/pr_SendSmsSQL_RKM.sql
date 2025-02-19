CREATE PROCEDURE [dbo].[pr_SendSmsSQL_RKM]
     @Cmp_ID 		numeric(3)
	 ,@Shift_flag	varchar(10)
as
begin    

Declare @CurrDate as Datetime
SELECT  @CurrDate=cast(cast(getdate() as varchar(11)) as datetime)

if  cast('2021-08-30'as datetime)=@CurrDate
	Or cast('2021-09-10'as datetime)=@CurrDate
	Or cast('2021-10-02'as datetime)=@CurrDate
	Or cast('2021-10-15'as datetime)=@CurrDate
	Or cast('2021-11-04'as datetime)=@CurrDate	
	Or cast('2021-11-05'as datetime)=@CurrDate
	Or cast('2021-11-06'as datetime)=@CurrDate
	Or cast('2021-11-19'as datetime)=@CurrDate	
	Or cast('2021-12-25'as datetime)=@CurrDate
	------------- Year 2022 Holiday Date ------------------------
	Or cast('14-Jan-2022'as datetime)=@CurrDate
	Or cast('26-Jan-2022'as datetime)=@CurrDate
	Or cast('01-Mar-2022'as datetime)=@CurrDate
	Or cast('18-Mar-2022'as datetime)=@CurrDate
	Or cast('15-Apr-2022'as datetime)=@CurrDate
	Or cast('03-May-2022'as datetime)=@CurrDate
	Or cast('11-Aug-2022'as datetime)=@CurrDate
	Or cast('15-Aug-2022'as datetime)=@CurrDate
	Or cast('19-Aug-2022'as datetime)=@CurrDate
	Or cast('31-Aug-2022'as datetime)=@CurrDate
	Or cast('05-Oct-2022'as datetime)=@CurrDate
	Or cast('24-Oct-2022'as datetime)=@CurrDate
	Or cast('26-Oct-2022'as datetime)=@CurrDate
	Or cast('31-Oct-2022'as datetime)=@CurrDate
	Or cast('08-Nov-2022'as datetime)=@CurrDate
	---------------- End ----------------------------------

Begin
	Return
End

SET NOCOUNT ON

Declare @iReq int,@hr int       
Declare @sUrl as varchar(Max)       
DECLARE @errorSource VARCHAR(8000)   
DECLARE @errorDescription VARCHAR(8000)  
DECLARE @Type  Varchar(50)-- = 'System'

Set @Type= 'System'

Declare @sms_url as varchar(max)
Declare @sms_username as varchar(500)
Declare @sms_password as varchar(500) 
Declare @sms_senderid as varchar(500)
declare @sResponse varchar(4000)

declare @MobileNo as varchar(25)
declare @smstext as varchar(500)
Declare @Emp_Name as Varchar(150)
Declare @In_Time nVarchar(10)
Declare @Out_Time as nVarchar(10)
declare @For_Date as DATETIME 

set @For_Date = GETDATE()

--SELECT @sUrl = ISNULL(SMS_URL,'') FROM Gen_Setting
IF OBJECT_ID(N'tempdb..#tmpEmpMaster', N'U') IS NOT NULL 
		DROP TABLE #tmpEmpMaster


CREATE TABLE #tmpEmpMaster
	(
		RowNo int,
		Emp_Full_Name varchar(50),
		Mobile_No numeric(12),
		IN_Time varchar(10),
		Out_Time varchar(10)
	)

IF @Shift_flag = 'day'
BEGIN 
	insert into #tmpEmpMaster
	SELECT distinct ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
	 ,E.Emp_Full_Name, Mobile_No,CONVERT(char(10), MIN(ISNULL(IN_Time,'00:00')), 108) In_Time,
	 CONVERT(char(10), MAX(ISNULL(Out_Time,'00:00')), 108)Out_Time 
	FROM T0080_EMP_MASTER  as E WITH (NOLOCK)
	INNER JOIN T0150_EMP_INOUT_RECORD  AS  M WITH (NOLOCK)
	On E.Emp_id = M.Emp_ID
	INNER JOIN T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)  ON ESD.Emp_ID = E.Emp_ID
	INNER JOIN T0040_SHIFT_MASTER  SM WITH (NOLOCK)  ON SM.Cmp_ID = ESD.Cmp_ID and SM.Shift_ID = ESD.Shift_ID
	WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> '' AND CAST(ISNULL(IN_Time,'00:00') as time) > CAST('06:00' as time)
	and E.Cmp_ID = @Cmp_ID
	--and E.Emp_COde IN (11444,11359,10559,10944,10536,11751,75059,10589,10567,11360,12338) 
	AND M.for_date = CAST(Getdate() as DATE) --AND M.For_Date IS NOT NULL 
	and CAST(SM.Shift_St_Time as time) > CAST('06:00' as time)
	 Group by Emp_Full_Name,Mobile_No
	 order by E.Emp_Full_Name
 END
 ELSE
 BEGIN
 insert into #tmpEmpMaster
	SELECT distinct ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
	,E.Emp_Full_Name, Mobile_No,CONVERT(char(10), MIN(ISNULL(IN_Time,'00:00')), 108) In_Time,
	 CONVERT(char(10), MAX(ISNULL(Out_Time,'00:00')), 108)Out_Time 
	FROM T0080_EMP_MASTER  as E WITH (NOLOCK) 
	INNER JOIN T0150_EMP_INOUT_RECORD  AS  M WITH (NOLOCK)
	On E.Emp_id = M.Emp_ID
	INNER JOIN T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) ON ESD.Emp_ID = E.Emp_ID
	INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Cmp_ID = ESD.Cmp_ID and SM.Shift_ID = ESD.Shift_ID
	WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> '' AND CAST(ISNULL(IN_Time,'00:00') as time) > CAST('20:00' as time)
	--and E.Cmp_ID in (4) 
	AND M.for_date = CAST(DATEADD(d,-1,Getdate()) as date)  --AND M.For_Date IS NOT NULL 
	and CAST(SM.Shift_St_Time as time) > CAST('20:00' as time)
	Group by Emp_Full_Name,Mobile_No
	 order by E.Emp_Full_Name
 END

select * from #tmpEmpMaster
return

DECLARE @rowCnt AS NUMERIC(9) = 1
DECLARE @Cnt as NUMERIC(9) = 0


SELECT @Cnt = COUNT(1) FROM #tmpEmpMaster

END
WHILE @rowCnt <= @Cnt
BEGIN 

	SELECT @MobileNo = Mobile_No , @Emp_Name = Emp_Full_Name ,@In_Time = In_Time, @Out_Time = Out_Time
	from #tmpEmpMaster where rowNo = @rowCnt 
	
	
	--select	@Emp_Name =  Emp_Name ,@MobileNo=Mobile_No from	Emp_Master where Card_Ref_No = @Enroll_No
	set @MobileNo = '9429906564'
	if @rowCnt > @Cnt
	begin
	print 'brk'
		  BREAK
	end
	
	--select * from #tmpEmpMaster
	
	--select @rowCnt,@Cnt
	
	--set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007528311358810471&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	--set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007993854491163996&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	--set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007741495759070908&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	
	--/////////////////// For Rk Marbal ////////////////////////////////////
	set @sUrl = 'https://smschilly.in/app/smsapi/index.php?key=35D764C1EAB611&campaign=8122&routeid=101462&type=text&contacts=your_recipient&senderid=RKMARB&msg=your_msg&template_id=1007829600932790487&pe_id=1001877707251331422'

	IF @sUrl = ''
	BEGIN
		Return
	END



	--set @smstext ='You are absent on ' +left(cast(convert(varchar(11), @For_Date) as datetime),12) +' as per our biometric record.' 
	
	set @smstext ='Your attendance for ' + FORMAT(GETDATE(), 'dd/MM/yyyy') +' is : '+ CHAR(13) +  'In : '+ @In_Time+'' + CHAR(13) + 'Out : '+ @Out_Time +'' + CHAR(13) + 'Kindly contact to HR Immediately for any discrepancies. RK Marble %20 Granite Pvt. Ltd.' 
	
	--select @smstext
	--return
	IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'Ole Automation Procedures' AND value=1) BEGIN  
		
		EXEC master.dbo.sp_configure 'show advanced options', 1
		RECONFIGURE WITH OVERRIDE

		EXEC master.dbo.sp_configure 'Ole Automation Procedures', 1
		RECONFIGURE WITH OVERRIDE

	 END  
		---WaitFor Delay '00:0:05:000'
		
		-- ALTER Object for XMLHTTP
	   EXEC @hr = sp_OACREATE 'MSXML2.ServerXMLHTTP.6.0', @iReq OUT      -- Scripting.FileSystemObject    --Microsoft.XMLHTTP
	   
	   --print @hr        
	 if @hr <> 0     
	 begin 
		  Raiserror('sp_OACREATE Microsoft.XMLHTTP FAILED!', 16, 1) 
		  print 'err;'       
		  goto a;
	end
	
	
	---set @sUrl = ''
	--set @sUrl = REPLACE(@sUrl,'your_username','amul_hsi')
	--set @sUrl = REPLACE(@sUrl,'your_password','amul@123')
	--set @sUrl = REPLACE(@sUrl,'your_senderid','AMULHO')
	--set @sUrl = REPLACE(@sUrl,'your_recipient','9377369838')
	set @sUrl = REPLACE(@sUrl,'your_recipient',@MobileNo)
	set @sUrl = REPLACE(@sUrl,'your_msg',@smstext)



	--select @sUrl
	--return
	-- sms code start
		
		EXEC @hr = sp_OAMethod @iReq, 'Open', NULL, 'POST', @sUrl, 'false' 
		--EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
	    
		
	       
		if @hr <> 0     
		begin 
			  Raiserror('sp_OAMethod Open FAILED!', 16, 1)        
			  goto a;
			  
		end 

		EXEC @hr = sp_OAMethod @iReq, 'send'       
	 

	--print @hr        
	if @hr <> 0       
	Begin               
		EXEC sp_OAGetErrorInfo @iReq, @errorSource OUTPUT, @errorDescription OUTPUT               
		 SELECT [Error Source] = @errorSource, [Description] = @errorDescription     
		 print 'error'          
			Raiserror('sp_OAMethod Send FAILED!', 16, 1)      
		goto a;
	   end 
	else 
	  Begin    
	  EXEC @hr = sp_OAGetProperty @iReq,'responseText', @sResponse OUT   
	  begin
	  		goto a;
	  		print '456'
	  end
	  --  --print @hr   
	  --  SET IDENTITY_INSERT send_log ON
	  --  insert into send_log (Id, mobile, sendtext, response, created, createddate)   
	  --  values(0, @MobileNo, @smstext, @sResponse, @Type , GETDATE())end 
	  --end
	  --  SET IDENTITY_INSERT send_log OFF
		End
a:	
	
		SET @rowCnt = @rowCnt + 1
	
	End
--end

--EXEC sp_OAGetErrorInfo

RETURN

    

