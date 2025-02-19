
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_Attendance_Request_Details]  
	 @Company_Id	NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		Varchar(Max) = ''
	,@Grade_ID 		Varchar(Max) = ''
	,@Type_ID 		Varchar(Max) = ''
	,@Dept_ID 		Varchar(Max) = ''
	,@Desig_ID 		Varchar(Max) = ''
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        Varchar(Max) = ''
	,@Filter_Flag	tinyint = 0 -- 0 For ALL 1 For Pending 2 For Approval
	,@Order_By	varchar(30) = 'Code'
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
	
     
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )            
    
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0               
	

	If OBJECT_ID('tempdb..#Attendance_App_Data') is not NULL	
		Drop TABLE #Attendance_App_Data
		
	Create TABLE #Attendance_App_Data
	(
		Emp_ID NUMERIC,
		Increment_ID Numeric, 
		Att_App_ID NUMERIC,
		For_Date Datetime,
		App_Date Datetime,
		Apr_Date DATETIME,
		Apr_By Numeric(18,0),
		P_Day NUMERIC(5,2),
		App_Status Varchar(20)
	)
	
	
	
	INSERT #Attendance_App_Data
		Select AA.Emp_ID,EC.Increment_ID,AA.Att_App_ID,AA.For_Date,AA.Modify_Date,NULL,0,AA.P_Days,'P' 
			From #Emp_Cons EC 
		Inner Join T0160_Attendance_Application AA WITH (NOLOCK) ON EC.Emp_ID = AA.Emp_ID
		WHERE AA.Cmp_ID = @Company_Id and AA.For_Date >= @From_Date and AA.For_Date <= @To_Date


	UPDATE AAD
		SET 
		   AAD.Apr_Date = AA.Modify_Date,
		   AAD.P_Day = AA.P_Days,
		   AAD.App_Status = AA.Att_Status,
		   Apr_By = AA.Approver_Emp_ID
	From #Attendance_App_Data AAD INNER Join T0165_Attendance_Approval AA
		ON AAD.Emp_ID = AA.Emp_ID AND AAD.Att_App_ID = AA.Att_App_ID
	Where AA.Cmp_ID = @Company_Id and AA.For_Date >= @From_Date and AA.For_Date <= @To_Date


	INSERT #Attendance_App_Data 
		Select AA.Emp_ID,EC.Increment_ID,0,AA.For_Date,NULL,AA.Modify_Date,AA.Approver_Emp_ID,AA.P_Days,'A' 
			From #Emp_Cons EC 
		Inner Join T0165_Attendance_Approval AA WITH (NOLOCK) ON EC.Emp_ID = AA.Emp_ID
		WHERE AA.Cmp_ID = @Company_Id and AA.For_Date >= @From_Date and AA.For_Date <= @To_Date and AA.Att_App_ID = 0
		AND NOT EXISTS(Select 1 From T0160_Attendance_Application TAA WITH (NOLOCK) Where TAA.Att_App_ID = AA.Att_App_ID)

	
	SELECT '="' + Alpha_Emp_Code + '"' AS Emp_code, 
			Emp_Full_Name, BM.Branch_Name, GM.Grd_Name As Grade_Name,
			DT.Dept_Name As Department,DM.Desig_Name As Designation_Name,
			'="' + Convert(Varchar(11),AA.For_Date,103) + '"' As For_Date,
			'="' + Convert(Varchar(11),AA.App_Date,103) + '"' As Application_Date,
			'="' + Convert(Varchar(11),AA.Apr_Date,103) + '"' As Approval_Date,
			(Select Alpha_Emp_Code + '-' + Emp_Full_Name From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = AA.Apr_By ) as Approve_By,
			Case When AA.App_Status = 'A' Then 'Approve' When AA.App_Status = 'P' Then 'Pending' END As Request_Status
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Attendance_App_Data AA ON AA.Emp_ID = E.Emp_ID 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = AA.Increment_ID	
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = GM.Grd_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_Id
			LEFT OUTER JOIn T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON DT.Dept_Id = I.Dept_ID
			LEFT OUTER JOIn T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I.Desig_Id = DM.Desig_Id
	WHERE E.Cmp_ID = @Company_Id 
		  And (CASE WHEN @Filter_Flag IN(0,1) THEN  AA.For_Date WHEN @Filter_Flag = 2 THEN AA.For_Date END) >= @From_Date
	      And (CASE WHEN @Filter_Flag IN(0,1) THEN  AA.For_Date WHEN @Filter_Flag = 2 THEN AA.For_Date END) <= @To_Date
		  And (CASE WHEN @Filter_Flag = 0  THEN AA.App_Status WHEN @Filter_Flag = 1 THEN 'P' WHEN @Filter_Flag = 2 THEN 'A' END) <= AA.App_Status
	Order by CASE WHEN @Order_By='Name' THEN E.Emp_Full_Name  
					WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0', 21) +  CAST(E.Enroll_No AS VARCHAR), 21)
					ELSE 
					(CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code END)
		End
 RETURN
