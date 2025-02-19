

-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,11/10/2013>
-- Description:	<Description,,For Getting Data for Audit Chart>
-- =============================================
CREATE PROCEDURE [dbo].[Sp_GetDataForAuditChart]
	 @Cmp_Id as numeric
	,@Branch_Id as numeric
	,@Month as varchar(50)
	,@Year as numeric
	,@Op as numeric
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
				DECLARE @Table TABLE( 
				Banch_ID numeric NOT NULL, 
				Branch_Name varchar(150) NOT NULL,
				Audit_Module_Name varchar(150) NOT NULL,
				Cmp_ID numeric NOT NULL,
				Audit_Date datetime NOT NULL
				); 
	IF @Op = 1 
	BEGIN
			SELECT * FROM (
			Select 'Leave' as 'Module Name',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And 
			(Audit_Module_Name = 'Leave Master' OR Audit_Module_Name = 'Leave Details' OR
			Audit_Module_Name = 'Leave Opening' OR Audit_Module_Name = 'Leave Application' OR
			Audit_Module_Name = 'Leave Approval' OR Audit_Module_Name = 'Admin Leave Approval')

			UNION 

			Select 'Employee' as 'Module Name',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And 
			(Audit_Module_Name = 'Salary Cycle Transfer' OR Audit_Module_Name = 'Reporting Manager' OR
			Audit_Module_Name = 'Employee Privileges' OR Audit_Module_Name = 'Emp Type Master' OR
			Audit_Module_Name = 'Shift Master' OR Audit_Module_Name = 'Employee Weekoff' OR 
			Audit_Module_Name = 'Employee Warning')

			UNION 

			Select 'Attendance' as 'Module Name',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And 
			(Audit_Module_Name = 'EMPlOYEE IN OUT' OR Audit_Module_Name = 'EMPlOYEE DEFAULT IN OUT' OR
			Audit_Module_Name = 'Shift Change')

			UNION 

			Select 'Masters' as 'Module Name',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And 
			(Audit_Module_Name = 'Branch Master' OR Audit_Module_Name = 'Grade Master' OR
			Audit_Module_Name = 'Department Master' OR Audit_Module_Name = 'Designation Master' OR
			Audit_Module_Name = 'Country Master' OR Audit_Module_Name = 'Project Master' OR 
			Audit_Module_Name = 'State Master' OR Audit_Module_Name = 'Assert Master' OR 
			Audit_Module_Name = 'Insurance Master' OR Audit_Module_Name = 'Categary Master' OR 
			Audit_Module_Name = 'Cost Master' OR Audit_Module_Name = 'Question Master' OR 
			Audit_Module_Name = 'Company Master' OR Audit_Module_Name = 'Bank Master' OR 
			Audit_Module_Name = 'Warning Master' OR Audit_Module_Name = 'Holiday Master' OR 
			Audit_Module_Name = 'Perform Master' OR Audit_Module_Name = 'WeekOff Master' OR 
			Audit_Module_Name = 'License Master' OR Audit_Module_Name = 'Document Master' OR 
			Audit_Module_Name = 'News Master' OR Audit_Module_Name = 'Policy Master' OR 
			Audit_Module_Name = 'Salary Cycle Master' OR Audit_Module_Name = 'Vertical Master' OR 
			Audit_Module_Name = 'SubVertical Master' OR Audit_Module_Name = 'SubBranch Master' OR 
			Audit_Module_Name = 'Business Segment Master' OR Audit_Module_Name = 'Company Information')

			UNION 

			Select 'Salary' as 'Module Name', COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And 
			(Audit_Module_Name = 'Salary Monthly' OR Audit_Module_Name = 'Salary Manually' OR 
			Audit_Module_Name = 'OT Approval' OR Audit_Module_Name = 'Salary Settlement' OR
			Audit_Module_Name = 'Full and Final Settlement' OR Audit_Module_Name = 'Salary Monthly/Manually' OR
			Audit_Module_Name = 'Bonus Detail' OR Audit_Module_Name = 'Performance Detail' OR 
			Audit_Module_Name = 'Salary Advance Approval' OR Audit_Module_Name = 'Admin Advance Approval' OR
			Audit_Module_Name = 'PF Challan' OR Audit_Module_Name = 'ESIC Challan' OR 
			Audit_Module_Name = 'ESIC Challan Sett' OR Audit_Module_Name = 'TDS Challan' OR 
			Audit_Module_Name = 'PT Challan' OR Audit_Module_Name = 'Month Lock' OR Audit_Module_Name = 'IT Lock' OR
			Audit_Module_Name = 'IT Master' OR Audit_Module_Name = 'IT Declaration')) 
			as Temptbl order by [Module Name]
			 
	END
	IF @Op = 2
	BEGIN
			SELECT * FROM (
			Select 'Add' as 'Op',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month 
			AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And (Audit_Change_Type = 'I')

			UNION 

			Select 'Delete' as 'Op',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month  
			AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And (Audit_Change_Type = 'D')

			UNION 

			Select 'Update' as 'Op',COUNT(*) as Cnt  
			from T9999_Audit_Trail WITH (NOLOCK) Where DATENAME(MONTH,Audit_Date) = @Month  
			AND DATEPART(yyyy,Audit_Date) = @Year AND 
			(Cmp_ID = @Cmp_Id OR Cmp_ID = 0) And (Audit_Change_Type = 'U')
			) as Temptbl order by Op
	END
	IF @Op = 3
	BEGIN
		IF @Branch_Id = 0
		BEGIN
				Insert into @Table
				Select * from (Select em.Branch_ID,bm.Branch_Name,Audit_Module_Name,at.Cmp_ID,at.Audit_Date
				from T9999_Audit_Trail as at WITH (NOLOCK) Inner join
				T0080_EMP_MASTER as em WITH (NOLOCK) ON em.Emp_ID = at.Audit_Change_For Inner join
				T0030_BRANCH_MASTER as bm WITH (NOLOCK) ON bm.Branch_ID = em.Branch_ID
				where Audit_Change_For <> 0 And 
				at.Cmp_ID = @Cmp_Id And bm.Cmp_ID = @Cmp_Id And em.Cmp_ID = @Cmp_Id) as temptbl
				SELECT * FROM (
				Select 'Leave' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND  (Audit_Module_Name = 'Leave Master' OR Audit_Module_Name = 'Leave Details' OR
				Audit_Module_Name = 'Leave Opening' OR Audit_Module_Name = 'Leave Application' OR
				Audit_Module_Name = 'Leave Approval' OR Audit_Module_Name = 'Admin Leave Approval')

				UNION 

				Select 'Employee' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND  (Audit_Module_Name = 'Salary Cycle Transfer' OR Audit_Module_Name = 'Reporting Manager' OR
				Audit_Module_Name = 'Employee Privileges' OR Audit_Module_Name = 'Emp Type Master' OR
				Audit_Module_Name = 'Shift Master' OR Audit_Module_Name = 'Employee Weekoff' OR 
				Audit_Module_Name = 'Employee Warning')

				UNION 

				Select 'Attendance' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND  (Audit_Module_Name = 'EMPlOYEE IN OUT' OR Audit_Module_Name = 'EMPlOYEE DEFAULT IN OUT' OR
				Audit_Module_Name = 'Shift Change')

				UNION 

				Select 'Masters' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND  (Audit_Module_Name = 'Branch Master' OR Audit_Module_Name = 'Grade Master' OR
				Audit_Module_Name = 'Department Master' OR Audit_Module_Name = 'Designation Master' OR
				Audit_Module_Name = 'Country Master' OR Audit_Module_Name = 'Project Master' OR 
				Audit_Module_Name = 'State Master' OR Audit_Module_Name = 'Assert Master' OR 
				Audit_Module_Name = 'Insurance Master' OR Audit_Module_Name = 'Categary Master' OR 
				Audit_Module_Name = 'Cost Master' OR Audit_Module_Name = 'Question Master' OR 
				Audit_Module_Name = 'Company Master' OR Audit_Module_Name = 'Bank Master' OR 
				Audit_Module_Name = 'Warning Master' OR Audit_Module_Name = 'Holiday Master' OR 
				Audit_Module_Name = 'Perform Master' OR Audit_Module_Name = 'WeekOff Master' OR 
				Audit_Module_Name = 'License Master' OR Audit_Module_Name = 'Document Master' OR 
				Audit_Module_Name = 'News Master' OR Audit_Module_Name = 'Policy Master' OR 
				Audit_Module_Name = 'Salary Cycle Master' OR Audit_Module_Name = 'Vertical Master' OR 
				Audit_Module_Name = 'SubVertical Master' OR Audit_Module_Name = 'SubBranch Master' OR 
				Audit_Module_Name = 'Business Segment Master' OR Audit_Module_Name = 'Company Information')

				UNION 

				Select 'Salary' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND  (Audit_Module_Name = 'Salary Monthly' OR Audit_Module_Name = 'Salary Manually' OR 
						Audit_Module_Name = 'OT Approval' OR Audit_Module_Name = 'Salary Settlement' OR
						Audit_Module_Name = 'Full and Final Settlement' OR Audit_Module_Name = 'Salary Monthly/Manually' OR
						Audit_Module_Name = 'Bonus Detail' OR Audit_Module_Name = 'Performance Detail' OR 
						Audit_Module_Name = 'Salary Advance Approval' OR Audit_Module_Name = 'Admin Advance Approval' OR
						Audit_Module_Name = 'PF Challan' OR Audit_Module_Name = 'ESIC Challan' OR 
						Audit_Module_Name = 'ESIC Challan Sett' OR Audit_Module_Name = 'TDS Challan' OR 
						Audit_Module_Name = 'PT Challan' OR Audit_Module_Name = 'Month Lock' OR Audit_Module_Name = 'IT Lock' OR
						Audit_Module_Name = 'IT Master' OR Audit_Module_Name = 'IT Declaration' )
					  ) as Temptbl order by [Module Name]
		END
		IF @Branch_Id <> 0
		BEGIN
				Insert into @Table
				Select * from (Select em.Branch_ID,bm.Branch_Name,Audit_Module_Name,at.Cmp_ID,at.Audit_Date
				from T9999_Audit_Trail as at WITH (NOLOCK) Inner join
				T0080_EMP_MASTER as em WITH (NOLOCK) ON em.Emp_ID = at.Audit_Change_For Inner join
				T0030_BRANCH_MASTER as bm WITH (NOLOCK) ON bm.Branch_ID = em.Branch_ID
				where Audit_Change_For <> 0 And 
				at.Cmp_ID = @Cmp_Id And bm.Cmp_ID = @Cmp_Id And em.Cmp_ID = @Cmp_Id) as temptbl
				SELECT * FROM (
				Select 'Leave' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND Banch_ID = @Branch_Id
				AND  (Audit_Module_Name = 'Leave Master' OR Audit_Module_Name = 'Leave Details' OR
				Audit_Module_Name = 'Leave Opening' OR Audit_Module_Name = 'Leave Application' OR
				Audit_Module_Name = 'Leave Approval' OR Audit_Module_Name = 'Admin Leave Approval')

				UNION 

				Select 'Employee' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND Banch_ID = @Branch_Id
				AND  (Audit_Module_Name = 'Salary Cycle Transfer' OR Audit_Module_Name = 'Reporting Manager' OR
				Audit_Module_Name = 'Employee Privileges' OR Audit_Module_Name = 'Emp Type Master' OR
				Audit_Module_Name = 'Shift Master' OR Audit_Module_Name = 'Employee Weekoff' OR 
				Audit_Module_Name = 'Employee Warning')

				UNION 

				Select 'Attendance' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND Banch_ID = @Branch_Id
				AND  (Audit_Module_Name = 'EMPlOYEE IN OUT' OR Audit_Module_Name = 'EMPlOYEE DEFAULT IN OUT' OR
				Audit_Module_Name = 'Shift Change')

				UNION 

				Select 'Masters' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND Banch_ID = @Branch_Id
				AND  (Audit_Module_Name = 'Branch Master' OR Audit_Module_Name = 'Grade Master' OR
				Audit_Module_Name = 'Department Master' OR Audit_Module_Name = 'Designation Master' OR
				Audit_Module_Name = 'Country Master' OR Audit_Module_Name = 'Project Master' OR 
				Audit_Module_Name = 'State Master' OR Audit_Module_Name = 'Assert Master' OR 
				Audit_Module_Name = 'Insurance Master' OR Audit_Module_Name = 'Categary Master' OR 
				Audit_Module_Name = 'Cost Master' OR Audit_Module_Name = 'Question Master' OR 
				Audit_Module_Name = 'Company Master' OR Audit_Module_Name = 'Bank Master' OR 
				Audit_Module_Name = 'Warning Master' OR Audit_Module_Name = 'Holiday Master' OR 
				Audit_Module_Name = 'Perform Master' OR Audit_Module_Name = 'WeekOff Master' OR 
				Audit_Module_Name = 'License Master' OR Audit_Module_Name = 'Document Master' OR 
				Audit_Module_Name = 'News Master' OR Audit_Module_Name = 'Policy Master' OR 
				Audit_Module_Name = 'Salary Cycle Master' OR Audit_Module_Name = 'Vertical Master' OR 
				Audit_Module_Name = 'SubVertical Master' OR Audit_Module_Name = 'SubBranch Master' OR 
				Audit_Module_Name = 'Business Segment Master' OR Audit_Module_Name = 'Company Information')

				UNION 

				Select 'Salary' as 'Module Name',COUNT(*) as Cnt  
				from @Table Where DATENAME(MONTH,Audit_Date) = @Month AND DATEPART(yyyy,Audit_Date) = @Year 
				AND Banch_ID = @Branch_Id
				AND  (Audit_Module_Name = 'Salary Monthly' OR Audit_Module_Name = 'Salary Manually' OR 
					Audit_Module_Name = 'OT Approval' OR Audit_Module_Name = 'Salary Settlement' OR
					Audit_Module_Name = 'Full and Final Settlement' OR Audit_Module_Name = 'Salary Monthly/Manually' OR
					Audit_Module_Name = 'Bonus Detail' OR Audit_Module_Name = 'Performance Detail' OR 
					Audit_Module_Name = 'Salary Advance Approval' OR Audit_Module_Name = 'Admin Advance Approval' OR
					Audit_Module_Name = 'PF Challan' OR Audit_Module_Name = 'ESIC Challan' OR 
					Audit_Module_Name = 'ESIC Challan Sett' OR Audit_Module_Name = 'TDS Challan' OR 
					Audit_Module_Name = 'PT Challan' OR Audit_Module_Name = 'Month Lock' OR Audit_Module_Name = 'IT Lock' OR
					Audit_Module_Name = 'IT Master' OR Audit_Module_Name = 'IT Declaration') 
				) as Temptbl order by [Module Name]
		END
	END
END

