
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Home_Page_Ess_Static_Link] 
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Privilege_Id Numeric(18,0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
    IF Object_ID('tempdb..#Temp_Emp_Rights') is not null
		Drop TABLE #Temp_Emp_Rights
    
    Create Table #Temp_Emp_Rights
    (
		Form_Name Varchar(2000),
		Form_Details Varchar(2000),
		Form_Url Varchar(2000),
		Form_Visible tinyint
    )
    
    IF Object_ID('tempdb..#Temp_Privilege') is not null
		Drop TABLE #Temp_Privilege
    
    Create Table #Temp_Privilege
    (
		Form_Name Varchar(200)
    )
    
    Exec GET_EMP_PRIVILEGE @Cmp_ID,@Privilege_Id,1
     
    Declare @In_DateTime as Datetime
    Set @In_DateTime = NULL
    Declare @Str_InTime As varchar(100)
    Set @Str_InTime = '<span class="awards_red">Pending</span>'
     
    select @In_DateTime = MIN(in_time)  from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID and For_Date= CONVERT(date,GETDATE()-1,101)
    if @In_DateTime is not null
		Begin
			Set @Str_InTime = CONVERT(varchar(10),@In_DateTime,103) + ' ' + convert(char(5), @In_DateTime, 108)
		End
    
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_263','My Team Member Details','Employee_Downline.aspx',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_267','In Time',@Str_InTime,1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_268','Attendance Summary','Emp_Inout_New.aspx',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_269','Employee History','ESS_Employee_History.aspx',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_270','Current Year Salary Detail','',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_271','Holiday Calendar','',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_272','Leave Balance','',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_279','View Graphical Report','Graphical_chart_Ess.aspx',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_285','About Me','',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_264','Warning Details','Employee_Warning.aspx',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_Ess_289','Whosoff','',1)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_281','Graph','',0)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_282','Attendance Graph','',0)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_283','Attendance Summary','',0)
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Form_Visible)  Values('TD_Home_ESS_284','Attendance Hourly Summary','',0)
    
    Delete FROM #Temp_Emp_Rights Where Form_Name Not in(Select Form_Name From #Temp_Privilege)
    
    Select * From #Temp_Emp_Rights where Form_Visible = 1
    Select * From #Temp_Emp_Rights where Form_Visible = 0
END

