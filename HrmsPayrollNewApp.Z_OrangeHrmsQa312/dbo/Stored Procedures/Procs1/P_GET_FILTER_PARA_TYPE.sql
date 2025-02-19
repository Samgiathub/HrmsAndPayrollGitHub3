
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_FILTER_PARA_TYPE]
	@Property Varchar(32),
	@ParaConstraint Varchar(Max)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN
		DECLARE @Table_Name Varchar(128)

		IF @Property = 'Branch'
			SET @Table_Name = 'T0030_BRANCH_MASTER'
		ELSE IF @Property = 'Sub Branch'
			SET @Table_Name = 'T0050_SUBBRANCH'
		ELSE IF @Property = 'Department'
			SET @Table_Name = 'T0040_DEPARTMENT_MASTER'
		ELSE IF @Property = 'Designation'
			SET @Table_Name = 'T0040_DESIGNATION_MASTER'
		ELSE IF @Property = 'Vertical'
			SET @Table_Name = 'T0040_Vertical_Segment'
		ELSE IF @Property = 'Sub Vertical'
			SET @Table_Name = 'T0050_SubVertical'
		ELSE IF @Property = 'Business Segment'
			SET @Table_Name = 'T0040_Business_Segment'
		ELSE IF @Property = 'Grade'
			SET @Table_Name = 'T0040_GRADE_MASTER'
		ELSE IF @Property = 'Employee Type'
			SET @Table_Name = 'T0040_TYPE_MASTER'
		ELSE IF @Property = 'Salary Cycle'
			SET @Table_Name = 'T0040_Salary_Cycle_Master'		
		ELSE IF @Property = 'Company'
			SET @Table_Name = 'T0010_COMPANY_MASTER'
		ELSE IF @Property IN ('Reporting Manager', 'Employee')
			SET @Table_Name = 'T0080_EMP_MASTER'		

		SELECT	COLUMN_NAME , DATA_TYPE
		FROM	INFORMATION_SCHEMA.COLUMNS C 
				INNER JOIN dbo.Split(@ParaConstraint, ',') T ON C.COLUMN_NAME=t.Data
		WHERE	TABLE_NAME = @Table_Name 
	END
