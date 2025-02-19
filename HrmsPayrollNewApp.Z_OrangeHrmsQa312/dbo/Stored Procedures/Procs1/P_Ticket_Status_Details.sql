CREATE PROCEDURE [dbo].[P_Ticket_Status_Details]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''	
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) ,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Status INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
	DECLARE @columns VARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )    
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    


	if @Status = 1 -- For Open Ticket
		Begin
		   SELECT 
			  ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Req_UserCode,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Req_UserName,
				TA.Ticket_App_ID as Ticket_ID,
				TM.Ticket_Type as Ticket_Type,
				TP.Priority_Name as [Priority],
				TM.Ticket_Dept_Name as Dept_Name,
				TA.Ticket_Gen_Date as Requested_Date,
				(Select Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserCode,
				(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserName,
				T_Apr.Ticket_Apr_Date as Responded_Date,
				TA.Ticket_Description as [Description],
				TA.Escalation_Hours as Standard_TAT_Time,
				[DBO].GET_DATETIME_DIFF(TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) As Total_Time_Taken,
				(Case When TA.Ticket_Status = 'O' Then 'Open' 
					When TA.Ticket_Status = 'H' Then 'On Hold'
					When TA.Ticket_Status = 'C' Then 'Close'
				END) as Status,
				Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
				T_Apr.Feedback_Rating,
				T_Apr.Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   Inner JOIN T0040_Ticket_Type_Master TM  WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   LEFT OUTER JOIN T0040_Ticket_Priority TP WITH (NOLOCK) ON T_Apr.Ticket_Priority = TP.Tran_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'O'
		   and TA.Ticket_Gen_Date between @From_Date and @To_Date
		End
	Else if @Status = 2 -- For Hold Ticket
		Begin
		   SELECT 
			  ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Req_UserCode,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Req_UserName,
				TA.Ticket_App_ID as Ticket_ID,
				TM.Ticket_Type as Ticket_Type,
				TP.Priority_Name as [Priority],
				TM.Ticket_Dept_Name as Dept_Name,
				TA.Ticket_Gen_Date as Requested_Date,
				(Select Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserCode,
				(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserName,
				T_Apr.Ticket_Apr_Date as Responded_Date,
				TA.Ticket_Description as [Description],
				TA.Escalation_Hours as Standard_TAT_Time,
				[DBO].GET_DATETIME_DIFF(TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) As Total_Time_Taken,
				(Case When TA.Ticket_Status = 'O' Then 'Open' 
					When TA.Ticket_Status = 'H' Then 'On Hold'
					When TA.Ticket_Status = 'C' Then 'Close'
				END) as Status,
				Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
				T_Apr.Feedback_Rating,
				T_Apr.Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   Inner JOIN T0040_Ticket_Type_Master TM WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   LEFT OUTER JOIN T0040_Ticket_Priority TP WITH (NOLOCK) ON T_Apr.Ticket_Priority = TP.Tran_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'H'
		   and TA.Ticket_Gen_Date between @From_Date and @To_Date
		End
	Else if @Status = 3 -- For Closed Ticket
		Begin
		   SELECT 
			   ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Req_UserCode,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Req_UserName,
				TA.Ticket_App_ID as Ticket_ID,
				TM.Ticket_Type as Ticket_Type,
				TP.Priority_Name as [Priority],
				TM.Ticket_Dept_Name as Dept_Name,
				TA.Ticket_Gen_Date as Requested_Date,
				(Select Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserCode,
				(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserName,
				T_Apr.Ticket_Apr_Date as Responded_Date,
				TA.Ticket_Description as [Description],
				TA.Escalation_Hours as Standard_TAT_Time,
				[DBO].GET_DATETIME_DIFF(TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) As Total_Time_Taken,
				(Case When TA.Ticket_Status = 'O' Then 'Open' 
					When TA.Ticket_Status = 'H' Then 'On Hold'
					When TA.Ticket_Status = 'C' Then 'Close'
				END) as Status,
				Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
				T_Apr.Feedback_Rating,
				T_Apr.Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   Inner JOIN T0040_Ticket_Type_Master TM  WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   LEFT OUTER JOIN T0040_Ticket_Priority TP WITH (NOLOCK) ON T_Apr.Ticket_Priority = TP.Tran_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'C'
		   and TA.Ticket_Gen_Date between @From_Date and @To_Date
		End
	Else -- For All Ticket
		Begin
			SELECT 
				ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Req_UserCode,
				(Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Req_UserName,
				TA.Ticket_App_ID as Ticket_ID,
				TM.Ticket_Type as Ticket_Type,
				TP.Priority_Name as [Priority],
				TM.Ticket_Dept_Name as Dept_Name,
				TA.Ticket_Gen_Date as Requested_Date,
				(Select Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserCode,
				(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = T_Apr.S_Emp_ID) as Responded_UserName,
				T_Apr.Ticket_Apr_Date as Responded_Date,
				TA.Ticket_Description as [Description],
				TA.Escalation_Hours as Standard_TAT_Time,
				[DBO].GET_DATETIME_DIFF(TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) As Total_Time_Taken,
				(Case When TA.Ticket_Status = 'O' Then 'Open' 
					When TA.Ticket_Status = 'H' Then 'On Hold'
					When TA.Ticket_Status = 'C' Then 'Close'
				END) as Status,
				Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
				T_Apr.Feedback_Rating,
				T_Apr.Feedback_Suggestion
			FROM T0090_Ticket_Application TA WITH (NOLOCK)
			Inner JOIN T0040_Ticket_Type_Master TM WITH (NOLOCK)
			ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
			LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
			LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
			LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
			LEFT OUTER JOIN T0040_Ticket_Priority TP WITH (NOLOCK) ON T_Apr.Ticket_Priority = TP.Tran_ID
			Where TA.Cmp_ID = @Cmp_ID
			and TA.Ticket_Gen_Date between @From_Date and @To_Date
		End
End