

-- =============================================
-- Author:		<Jaina>
-- Create date: <03-06-2016>
-- Description:	<Exit Clearance>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_EMP_Exit_Clearance]
	@Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(max) = ''
	,@Cat_ID		varchar(max) = ''
	,@Grd_ID		varchar(max) = ''
	,@Type_ID		varchar(max) = ''
	,@Dept_ID		varchar(max) = ''
	,@Desig_ID		varchar(max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Segment_Id		varchar(MAX) =''
	,@Vertical_Id		varchar(MAX)=''
	,@SubVertical_Id	varchar(MAX) =''
	,@SubBranch_Id		varchar(MAX) =''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0
	
		SELECT DISTINCT  Em.Emp_ID,Em.Emp_Full_Name,EM.Emp_Second_Name,EM.Alpha_Emp_Code,EM.Branch_ID
		from T0080_EMP_MASTER AS EM WITH (NOLOCK) INNER JOIN
             T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK) ON ECA.Emp_ID =EM.Emp_id 
            left OUTER JOIN T0350_Exit_Clearance_Approval_Detail AS ED WITH (NOLOCK) ON ED.Approval_id = ECA.Approval_Id 
			INNER JOIN T0040_Clearance_Attribute As C WITH (NOLOCK) ON C.Clearance_id = ED.Clearance_id 
			INNER JOIN T0200_Emp_ExitApplication AS EE WITH (NOLOCK) ON EE.emp_id = ECA.Emp_ID 
			inner JOIN #Emp_Cons AS EMC ON EMC.Emp_ID= ECA.Emp_ID	 
		WHERE   EM.Cmp_ID = @Cmp_id
		
			
END


