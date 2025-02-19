

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[rpt_Employee_Training_Identification]
		 @Cmp_ID		Numeric(18,0)
		,@From_Date		Datetime 
		,@To_Date		Datetime
		,@Branch_ID		varchar(Max) 
		,@Cat_ID		varchar(Max)
		,@Grd_ID		varchar(Max) 
		,@Type_ID		varchar(Max) 
		,@Dept_ID		varchar(Max)
		,@Desig_ID		varchar(Max)
		,@Emp_ID		Numeric
		,@Constraint	varchar(MAX)
		,@Condition		varchar(MAX)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	

	declare @query as varchar(max) 
	set @query =''
	
	CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric 
	 )  
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
		
	if @Condition <> ''
		BEGIN
			set @query='select EI.Alpha_Emp_Code as [Employee Code],EI.Emp_Full_Name as [Employee Name],
						TM.Training_name as [Training Name],EI.Dept_Name as [Department],ET.Training_Year as [Training Year] from T0110_Employee_Training_Identification ET
							INNER JOIN T0040_Hrms_Training_master TM on ET.Training_ID=TM.Training_id
							INNER JOIN #Emp_Cons EC on ET.Emp_ID=EC.Emp_ID 
							INNER join V0080_EMP_MASTER_INCREMENT_GET EI on EI.Emp_ID=ET.Emp_ID 
						where ET.cmp_id='+ cast( @cmp_id  as varchar(18)) + cast( @Condition as varchar(500))+ ''
		
			exec(@query)	
		END
	else
		BEGIN	
			select EI.Alpha_Emp_Code as [Employee Code],EI.Emp_Full_Name as [Employee Name],
				TM.Training_name as [Training Name],EI.Dept_Name as [Department],ET.Training_Year as [Training Year] from T0110_Employee_Training_Identification ET WITH (NOLOCK)
				INNER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) on ET.Training_ID=TM.Training_id
				INNER JOIN #Emp_Cons EC on ET.Emp_ID=EC.Emp_ID 
				INNER join V0080_EMP_MASTER_INCREMENT_GET EI on EI.Emp_ID=ET.Emp_ID 
			where ET.Cmp_Id=@Cmp_ID 
		END
	
END

