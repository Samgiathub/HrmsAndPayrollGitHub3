

-- =============================================
-- Author:		<Jaina>
-- Create date: <01-05-2017>
-- Description:	<Quick Links>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Quick_Links]
	@Cmp_Id numeric(18,0),
	@Emp_Id numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Sort_No numeric(18,0)=0
		DECLARE @CNT INTEGER
		SET @CNT = 0
		
		CREATE TABLE #Quick_Link
		(
			Emp_ID numeric(18,0),
			Form_Id numeric(18,0),
			Form_name varchar(500),
			Form_Icon varchar(500),
			Form_url varchar(max),
			Form_Css varchar(max),
			Sorting_No numeric(18,0)
		)
		
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,7002,'Edit Profile','web','Default.aspx','quick-edit-profile',7)
						
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,9326,'Attendance Regularazation','language','Employee_Attendance.aspx','quick-edit-atte-reg',8)
			
		
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,9328,'Salary Slip','track_changes','Salary_Slip.aspx','quick-edit-salary-slip',9)
			
		
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,9332,'Change Password','settings_remote','ChangePassword.aspx','quick-edit-password',10)
			
		
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,9327,'Employee History','visibility','ESS_Employee_History.aspx','quick-edit-emp-history',11)
			
		
			INSERT INTO #Quick_Link (Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,Sorting_No)
			Values (@Emp_Id,9337,'Photo Gallary','assignment_turned_in','Employee_Gallery.aspx','quick-edit-photo-gallary',12)
			
		
		IF EXISTS(SELECT 1 FROM T0050_Quick_Links WITH (NOLOCK) WHERE EMP_ID=@EMP_ID)
		BEGIN
					
			INSERT INTO #Quick_Link 
			SELECT Emp_Id,Form_Id,Form_Name,Form_Icon,Form_url,Form_Css,ROW_NUMBER() OVER(ORDER BY Sorting_No)  
			FROM T0050_Quick_Links WITH (NOLOCK) WHERE EMP_ID=@EMP_ID
		END
		
		SELECT TOP 6 * FROM #QUICK_LINK ORDER BY SORTING_NO ASC
    
END

