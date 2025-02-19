

CREATE PROCEDURE [dbo].[pr_SendSmsSQL_Amul]
     
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
declare @For_Date as DATETIME 

set @For_Date = GETDATE()

--SELECT @sUrl = ISNULL(SMS_URL,'') FROM Gen_Setting
IF OBJECT_ID(N'tempdb..#tmpEmpMaster', N'U') IS NOT NULL 
		DROP TABLE #tmpEmpMaster

SELECT ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
,E.Enroll_No ,E.Emp_Full_Name, d.IO_DateTime, Mobile_No into #tmpEmpMaster
FROM T0080_EMP_MASTER as E 
LEFT OUTER JOIN T9999_DEVICE_INOUT_DETAIL AS  D
On E.Enroll_No = D.Enroll_No 
AND CONVERT(datetime,D.IO_DateTime ,103) > cast(@For_Date as DATE)
WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> ''
AND IO_DateTime IS NULL 

--code Added by Yogesh on 03092022 ---START---
SELECT ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
,E.Enroll_No ,E.Emp_Full_Name, M.IO_DateTime, Mobile_No into #tmpEmpMaster1
FROM T0080_EMP_MASTER as E 
LEFT OUTER JOIN T9999_MOBILE_INOUT_DETAIL AS  M
On E.Emp_id = M.Emp_ID
left outer join T9999_DEVICE_INOUT_DETAIL As D
on E.Enroll_No=D.Enroll_No
AND CONVERT(datetime,M.IO_DateTime ,103) > cast(@For_Date as DATE)
WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> ''
AND M.IO_DateTime IS Not NULL 
select Distinct Count(Enroll_No) from #tmpEmpMaster1

Delete from #tmpEmpMaster where Enroll_No  in (select Enroll_No from #tmpEmpMaster1)

--code Added by Yogesh on 03092022 ---End---
--code Added by Yogesh on 05092022 ---Start---
SELECT distinct--distinct ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
E.Enroll_No ,E.Emp_Full_Name,  Mobile_No
--,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID) as Time
into #tmpEmpMaster_LateComming
FROM T0080_EMP_MASTER as E 
LEFT OUTER JOIN T9999_DEVICE_INOUT_DETAIL AS  D
On E.Enroll_No = D.Enroll_No 
AND CONVERT(datetime,D.IO_DateTime ,103) > cast(@For_Date as DATE)
WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> ''
AND IO_DateTime IS not NULL
and (CONVERT(char(5),(select top 1 D.IO_DateTime where D.Enroll_No=E.Enroll_No ) , 108))>
right('0' + convert(varchar,LTRIM(DATEDIFF(MINUTE, 0,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID))+10) / 60),2) + ':' + right('0' + convert(varchar,LTRIM(DATEDIFF(MINUTE, 0,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID))+10) % 60),2)

AND CONVERT(datetime,D.IO_DateTime ,103) > cast(@For_Date as DATE)
 Order by Emp_Full_Name

SELECT distinct--distinct ROW_NUMBER() OVER(ORDER BY Emp_Full_Name ASC) AS RowNo
E.Enroll_No ,E.Emp_Full_Name, Mobile_No 
--,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID) as Time
into #tmpEmpMaster_LateComming1
FROM T0080_EMP_MASTER as E 
LEFT OUTER JOIN T9999_MOBILE_INOUT_DETAIL AS  M
On E.Emp_id = M.Emp_ID
left outer join T9999_DEVICE_INOUT_DETAIL As D
on E.Enroll_No=D.Enroll_No
AND CONVERT(datetime,M.IO_DateTime ,103) > cast(@For_Date as DATE)
WHERE ISNULL(E.Emp_Left,'N') = 'N' and ISNULL(e.Mobile_No , '') <> ''
AND M.IO_DateTime IS not NULL 
and (CONVERT(char(5),(select top 1 M.IO_DateTime where m.Emp_ID=E.Emp_ID) , 108) )>
 right('0' + convert(varchar,LTRIM(DATEDIFF(MINUTE, 0,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID))+10) / 60),2) + ':' + right('0' + convert(varchar,LTRIM(DATEDIFF(MINUTE, 0,(select Shift_St_Time from T0040_SHIFT_MASTER where Shift_ID=E.Shift_ID))+10) % 60),2)
AND CONVERT(datetime,M.IO_DateTime ,103) > cast(@For_Date as DATE)
 Order by Emp_Full_Name

  select * into #TempEmpList from( 
select * from #tmpEmpMaster  
Union 
select * from #tmpEmpMaster1 )a
--code Added by Yogesh on 05092022 ---End---

--select * from #tmpEmpMaster

declare @rowCnt as numeric(9) = 1
declare @Cnt as numeric(9) = 0

select @Cnt = COUNT(1) from #tmpEmpMaster

end
while @rowCnt <= @Cnt
BEGIN 

	SELECT @MobileNo = Mobile_No --, @EmpName = Emp_Name 
	from #tmpEmpMaster where rowNo = @rowCnt 
	
	
	--select	@Emp_Name =  Emp_Name ,@MobileNo=Mobile_No from	Emp_Master where Card_Ref_No = @Enroll_No
	--set @MobileNo = '9574012229'
	if @rowCnt > @Cnt
	begin
	print 'brk'
		  BREAK
	end
	
	--select * from #tmpEmpMaster
	
	--select @rowCnt,@Cnt
	
	--set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007528311358810471&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	--set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007993854491163996&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	set @sUrl = 'http://digimate.airtel.in:15181/BULK_API/SendMessage?loginID=your_username&password=your_password&mobile=your_recipient1&DLT_TM_ID=1001096933494158&DLT_CT_ID=1007741495759070908&DLT_PE_ID=1401460410000013671&route_id=DLT_SERVICE_IMPLICT&Unicode=0&camp_name=amul_user&senderid=your_senderid&text=your_msg'
	

	IF @sUrl = ''
	BEGIN
		Return
	END



	--set @smstext ='You are absent on ' +left(cast(convert(varchar(11), @For_Date) as datetime),12) +' as per our biometric record.' 
	
	set @smstext ='You are absent on ' +left(cast(convert(varchar(11), @For_Date) as datetime),12) +' as per our biometric record.You may apply your leave/tour on https://www.gcmmf.com/irj/portal' 

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
	set @sUrl = REPLACE(@sUrl,'your_username','amul_hsi')
	set @sUrl = REPLACE(@sUrl,'your_password','amul@123')
	set @sUrl = REPLACE(@sUrl,'your_senderid','AMULHO')
	set @sUrl = REPLACE(@sUrl,'your_recipient1',@MobileNo)
	set @sUrl = REPLACE(@sUrl,'your_msg',@smstext)



	--select @sUrl
	--return
	-- sms code start
		
		EXEC @hr = sp_OAMethod @iReq, 'Open', NULL, 'GET', @sUrl, true  
	    
	       
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

    

