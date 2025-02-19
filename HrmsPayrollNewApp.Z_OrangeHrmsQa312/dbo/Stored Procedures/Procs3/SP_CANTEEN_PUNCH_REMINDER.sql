

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 08-DEC-2017
-- Description:	TO SEND THE NAMES OF EMPLOYEE AND COUNT OF EMPLOYEE WHO HAS PUNCHED IN CANTEEN
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_CANTEEN_PUNCH_REMINDER]
	@CMP_ID			NUMERIC,
	@BEFORE_DAYS	TINYINT = 0,
	@CC_EMAIL		VARCHAR(250) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN


   DECLARE @FOR_DATE AS DATETIME
   SET @FOR_DATE = DATEADD(DD , @BEFORE_DAYS ,GETDATE())
   SET @FOR_DATE =  CONVERT(DATE , @FOR_DATE , 103)

   --SET @FOR_DATE = '2017-12-04 20:16:07.000' --ADDED ONLY FOR TEMPORARY TESTING
   
	
	
	IF OBJECT_ID('tempdb..#RPT_JOB') IS NULL
		BEGIN
			CREATE TABLE #RPT_JOB
			(
				EMP_ID			NUMERIC,
				Alpha_emp_code	VARCHAR(50),
				Emp_Full_Name	VARCHAR(100),
				Grd_Name		VARCHAR(100),
				Device_Name		VARCHAR(50),
				IP_Address		VARCHAR(50),
				For_date		DATETIME,
				Cnt_Name		VARCHAR(50),
				In_Time			DATETIME,
				Amount			NUMERIC(18,2),
				Subsidy_Amount	NUMERIC(18,2),
				Total_Amount	NUMERIC(18,2)
			)
		END

	IF OBJECT_ID('tempdb..#HR_Email') IS NULL
		BEGIN	
			CREATE table #HR_Email
			  ( 
				Cmp_ID		NUMERIC(18, 0),
				HR_Name		VARCHAR(100),
				HR_Email	VARCHAR(100),
				
			  )
		END  
	
   EXEC SP_RPT_CANTEEN_DEDUCTION @CMP_ID , @FOR_DATE , @FOR_DATE , '' , '' , '' , '' , '' , '' , 0 , '' , NULL
   
   SELECT * FROM #RPT_JOB

	SELECT	Device_Name,IP_Address, Cnt_Name, Count(EMP_ID) As TotalCount, Sum(Amount) As Amount
			,SUM(Subsidy_Amount) As Subsidy_Amount,SUM(Total_Amount) As Total_Amount
	FROM	#RPT_JOB	
	GROUP BY IP_Address, Cnt_Name,Device_Name,Subsidy_Amount,Total_Amount

	
	Declare  @TableHead		varchar(max)
	Declare  @TableHead1	varchar(max) 
	Declare  @TableTail		varchar(max) 
	declare	 @Final_Body	varchar(max)  
	Set @TableHead = '<html><head>' +
				  '<style>' +
				  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
				  '</style>' +
				  '</head>' +
				  '<body>
				  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
					border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
					color: #000000; text-decoration: none; font-weight: normal; text-align: left;
					font-size: 12px;">' +
						  '<tr border="1">
						  <td align=center><b><span style="font-size:small">ALPHA_EMP_CODE</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">EMP_FULL_NAME</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">GRADE NAME</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">FOR_DATE</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">CNT_NAME</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">IN_TIME</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">AMOUNT</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">SUBSIDY AMT</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">TOTAL AMT</span></b></td>'
	
	Set @TableHead1 = '<html><head>' +
					'</head>' +
					'<body>' +
					'<table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
					border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
					color: #000000; text-decoration: none; font-weight: normal; text-align: left;
					font-size: 12px;">' +
							'<tr><td colspan="9" align=center ><span style="font-size:medium;font-weight:bold"> Summary </span></td></tr>'+
						  '<tr border="1">
						  <td align=center><b><span style="font-size:small">Device_Name</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">IP_Address</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Canteen_Name</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Total Emp</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Amount</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Subsidy_Amount</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Total_Amount</span></b></td>'
	
	
	SET @TableTail = '</table></body></html>'; 				
			
					  DECLARE @Body AS VARCHAR(MAX)  
					  DECLARE @Body1 AS VARCHAR(MAX)
					     
					  SET @Body = ( SELECT  
											Alpha_emp_code  as [TD],
											Emp_Full_Name  as [TD],
											Grd_Name  as [TD],
											Replace(Convert(varchar(25), For_date,106) , ' ' , '-') As [TD],
											Cnt_Name as [TD],
											REPLACE(REPLACE(CONVERT(varchar(15), CAST(In_Time AS TIME), 100), 'P', ' P'), 'A', ' A')  as [TD],
											Amount as [TD],
											Subsidy_Amount as [TD],
											Total_Amount as [TD]
									FROM    #RPT_JOB
									ORDER BY Alpha_emp_code For XML raw('tr'), ELEMENTS) 
				
						SET @Body1 = ( SELECT	Device_Name			as [TD] ,
												IP_Address			as [TD], 
												Cnt_Name			as [TD], 
												Count(EMP_ID)		as [TD], 
												Sum(Amount)			as [TD],
												SUM(Subsidy_Amount) as [TD],
												SUM(Total_Amount)	as [TD]
									FROM	#RPT_JOB	
									GROUP BY IP_Address, Cnt_Name,Device_Name,Subsidy_Amount,Total_Amount
									For XML raw('tr'), ELEMENTS
									)
									 
           		  SET  @Body = @TableHead + @Body + @TableTail
           		  SET  @Body1 = @TableHead1 + @Body1 + @TableTail
           		  
           		  SET @Final_Body = @BODY + @BODY1
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Canteen Employee Details'
           		  
           		    Declare @profile as varchar(50)
   					 set @profile = ''
   					  
   					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
   					  
   					  if isnull(@profile,'') = ''
   					  begin
   						select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   					  end
           	
           	EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'ramiz@orangewebtech.com', @subject = @subject, @body = @Final_Body, @body_format = 'HTML',@copy_recipients = @CC_Email
           	
   
END

