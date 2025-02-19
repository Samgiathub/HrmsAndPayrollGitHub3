

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[pr_SendSmsSQL]   
    @MobileNo varchar(12),   
    @smstext as varchar(300),   
    @cmp_id as numeric(18,0),
    @sResponse varchar(1000) OUT, 
    @Type  Varchar(50) = 'System'
    as 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    BEGIN       
Declare @iReq int,@hr int       
Declare @sUrl as varchar(500)       
DECLARE @errorSource VARCHAR(8000)   
DECLARE @errorDescription VARCHAR(8000)  

Declare @sms_url as varchar(max)
Declare @sms_username as varchar(500)
Declare @sms_password as varchar(500) 
Declare @sms_senderid as varchar(500)   

 --This is to configure the Ole Automation Procedures command.  
 IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'Ole Automation Procedures' AND value=1) BEGIN  
  
	EXEC master.dbo.sp_configure 'show advanced options', 1
	RECONFIGURE WITH OVERRIDE


	EXEC master.dbo.sp_configure 'Ole Automation Procedures', 1
	RECONFIGURE WITH OVERRIDE

 END  

-- ALTER Object for XMLHTTP
   EXEC @hr = sp_OACREATE 'Microsoft.XMLHTTP', @iReq OUT        print @hr        if @hr <> 0     
      Raiserror('sp_OACREATE Microsoft.XMLHTTP FAILED!', 16, 1)        
--set @sUrl='http://168.63.236.46/sendsms.aspx?mobile=9426068968&pass=orange505&senderid=PAYROL&to=#MobNo#&msg=#Msg#' -- commented by rohit on 19012017
--set @sUrl = 'http://168.63.236.46/sendsms.aspx?mobile=8866068968&pass=orange505&senderid=PAYROL&to=#MobNo#&msg=#Msg#'

Select @sms_url = Url,@sms_username = UserId,@sms_password = Password,@sms_senderid = SenderId From T0040_Sms_Setting WITH (NOLOCK) where Cmp_Id = @cmp_id
--set @sUrl='http://10.10.0.1/sendsms.aspx?mobile=8523235653&pass=payroll&senderid=payroll&to=#MobNo#&msg=#Msg#'

if @sms_url <> '' -- added by rohit on 19012017 for default birthday message send.
begin
	set @sUrl = @sms_url+'?mobile='+@sms_username+'&pass='+@sms_password+'&senderid='+@sms_senderid+'&to=#MobNo#&msg=#Msg#'
end
else
begin
	set @sUrl = 'http://13.67.118.0/sendsms.aspx?mobile=8866068968&pass=orange505&senderid=PAYROL&to=#MobNo#&msg=#Msg#'
end

set @sUrl=REPLACE(@sUrl,'#MobNo#',@MobileNo)       
set @sUrl=REPLACE(@sUrl,'#Msg#',@smstext)        

-- sms code start
   EXEC @hr = sp_OAMethod @iReq, 'Open', NULL, 'GET', @sUrl, true       
--print @hr        
if @hr <> 0     
      Raiserror('sp_OAMethod Open FAILED!', 16, 1)        
EXEC @hr = sp_OAMethod @iReq, 'send'       
--select @iReq       
--print @hr        
if @hr <> 0       Begin               
EXEC sp_OAGetErrorInfo @iReq, @errorSource OUTPUT, @errorDescription OUTPUT               
 SELECT [Error Source] = @errorSource, [Description] = @errorDescription               
  Raiserror('sp_OAMethod Send FAILED!', 16, 1)       end else 
  Begin    EXEC @hr = sp_OAGetProperty @iReq,'responseText', @sResponse OUT   
    --print @hr   
    SET IDENTITY_INSERT send_log ON
    insert into send_log (Id, mobile, sendtext, response, created, createddate)   
    values(0, @MobileNo, @smstext, @sResponse, @Type , GETDATE())end end
    SET IDENTITY_INSERT send_log OFF
    
/*
sp_configure 'show advanced options', 1 
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 1
GO
RECONFIGURE;


ALTER TABLE [dbo].[send_log](
	[ID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[mobile] [nvarchar](50) NULL,
	[sendtext] [nvarchar](1000) NULL,
	[response] [nvarchar](500) NULL,
	[created] [nvarchar](50) NULL,
	[createddate] [datetime] NULL
) ON [PRIMARY]
*/


