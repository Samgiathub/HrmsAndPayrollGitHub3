-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Ticket_Application]
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Constrains Varchar(200),
	@Flag Numeric(1,0)
AS
BEGIN


-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
		Create table #tmp (
			Ticket_App_ID			Numeric(18,0)
			,Ticket_Type			varchar(500)
			,Ticket_Dept_Name		varchar(100)
			,Alpha_Emp_Code			varchar(100)
			,Emp_Full_Name			varchar(500)
			,Ticket_Gen_Date		dateTime
			,Ticket_Status			varchar(100)
			,Ticket_Description		varchar(100)
			,Ticket_Priority		varchar(100)
			,Ticket_Type_ID			numeric(18,0)
			,Ticket_Dept_ID			numeric(18,0)	
			,Emp_ID					numeric(18,0)
			,Cmp_ID					numeric(18,0)
			,Ticket_Attachment		varchar(500)
			,Is_Escalation			numeric(18,0)
			,Ticket_Priority_ID		numeric(18,0)
			,On_Hold_Reason			varchar(100)
			,Ticket_Status_Flag		varchar(10)
			,Ticket_Apr_ID			numeric(18,0)
			,Ticket_Apr_Attachment	varchar(500)
			,Is_Candidate			numeric(18,0)
			,[User_ID]				numeric(18,0)
			,AppliedByName			varchar(250)
			,AppliedById			numeric(18,0)
			,appliedByEmail			varchar(250)
			,Escalation_Hours		numeric(18,2)
			,Sendto					numeric(18,0)
			,SendTo_Full_Name		varchar(250)
	)

	Declare @Sql_Query Varchar(max)
	Set @Sql_Query = ''
	
	Declare @IT_Manager Numeric(5,0)
	Declare @IT_Manager_Email Varchar(50)
	
	Declare @Acc_Manager Numeric(5,0)
	Declare @Acc_Manager_Email Varchar(50)
	
	Declare @HR_Manager Numeric(5,0)
	Declare @HR_Manager_Email Varchar(50)
	
	Declare @Travel_Manager Numeric(5,0)
	Declare @Travel_Manager_Email Varchar(50)
	
	Set @IT_Manager = 0
	Set @IT_Manager_Email = ''
	
	Set @Acc_Manager =0
	Set @Acc_Manager_Email = ''
	
	Set @HR_Manager = 0
	Set @HR_Manager_Email = ''
	
	Set @Travel_Manager = 0
	Set @Travel_Manager_Email = ''
	
	Select @IT_Manager = Isnull(TL.IS_IT,0),
		   @IT_Manager_Email = Isnull(TL.Email_ID_IT,''),
		   @Acc_Manager = Isnull(TL.Is_Accou,0),
		   @Acc_Manager_Email = Isnull(TL.Email_ID_Accou,''),
		   @HR_Manager = Isnull(TL.Is_HR,0),
		   @HR_Manager_Email = Isnull(TL.Email_ID,''),
		   @Travel_Manager = Isnull(TL.Travel_Help_Desk,0),
		   @Travel_Manager_Email = Isnull(TL.Email_ID_HelpDesk,'')
	From T0011_LOGIN TL WITH (NOLOCK) Where TL.Cmp_ID = @Cmp_ID and TL.Emp_ID = @Emp_ID

	Declare @Str_Flag as Varchar(100)
	Set @Str_Flag = ''
	
	if @Flag = 1
		Begin
			Set @Str_Flag = 'and Ticket_Status = ''Open'''
			insert into #tmp
			Select * From V0090_Ticket_Application Where Cmp_ID = @Cmp_ID and Sendto = @Emp_ID  and Ticket_Status = 'Open'
		End
	Else if @Flag = 2
		Begin
			Set @Str_Flag = 'and Ticket_Status = ''On Hold'''
			insert into #tmp
			Select * From V0090_Ticket_Application Where Cmp_ID = @Cmp_ID and Sendto = @Emp_ID  and Ticket_Status = 'On Hold'
		End
	Else if @Flag = 3
		Begin
			Set @Str_Flag = 'and Ticket_Status = ''Closed'''
			insert into #tmp
			Select * From V0090_Ticket_Application Where Cmp_ID = @Cmp_ID and Sendto = @Emp_ID  and Ticket_Status = 'Closed'
		End
	
	if @IT_Manager > 0
		Begin
			Set @Sql_Query = 'insert into #tmp Select * From V0090_Ticket_Application_withOut_Sendto Where Cmp_ID = ' + cast(@Cmp_ID AS varchar(10)) + ' and Ticket_Dept_ID = 1 ' + @Constrains + '' + @Str_Flag
		End
	Else if @HR_Manager > 0
		Begin
			Set @Sql_Query = 'insert into #tmp
							Select * From V0090_Ticket_Application_withOut_Sendto Where Cmp_ID = ' + cast(@Cmp_ID AS varchar(10)) + ' and Ticket_Dept_ID = 2 ' + @Constrains + '' + @Str_Flag
		End
	Else if @Acc_Manager > 0
		Begin
			Set @Sql_Query = 'insert into #tmp Select * From V0090_Ticket_Application_withOut_Sendto Where Cmp_ID = ' + cast(@Cmp_ID AS varchar(10)) + ' and Ticket_Dept_ID = 3 ' + @Constrains + '' + @Str_Flag
		End
	Else if @Travel_Manager > 0
		Begin
			Set @Sql_Query = 'insert into #tmp Select * From V0090_Ticket_Application_withOut_Sendto Where Cmp_ID = ' + cast(@Cmp_ID AS varchar(10)) + ' and Ticket_Dept_ID = 4 ' + @Constrains + '' + @Str_Flag
		END
	
	Exec(@Sql_Query)
	
	SELECT Ticket_App_ID ,TICKET_TYPE ,TICKET_DEPT_NAME ,ALPHA_EMP_CODE ,EMP_FULL_NAME ,TICKET_GEN_DATE
	,TICKET_STATUS ,TICKET_DESCRIPTION ,TICKET_PRIORITY ,TICKET_TYPE_ID ,TICKET_DEPT_ID ,EMP_ID 
	,CMP_ID ,TICKET_ATTACHMENT ,IS_ESCALATION ,TICKET_PRIORITY_ID ,ON_HOLD_REASON ,TICKET_STATUS_FLAG 
	,TICKET_APR_ID ,TICKET_APR_ATTACHMENT ,IS_CANDIDATE ,USER_ID ,APPLIEDBYNAME ,APPLIEDBYID ,APPLIEDBYEMAIL
	,ESCALATION_HOURS ,SENDTO ,SENDTO_FULL_NAME
	FROM #TMP
	--SELECT *  FROM V0090_TICKET_APPLICATION where Sendto = @Emp_ID and Cmp_ID = @Cmp_ID
END


