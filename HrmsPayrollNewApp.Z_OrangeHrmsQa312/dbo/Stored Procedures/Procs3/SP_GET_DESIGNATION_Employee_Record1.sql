


CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_Employee_Record1]
@Cmp_Id numeric(18,0),
@Desig_id numeric(18,0),
@Branch_ID numeric(18,0)=0,
@Emp_ID numeric(18,0),
@Emp_Search int=0 
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	SELECT VEM.Emp_ID,CASE @Emp_Search 
					 WHEN 0 THEN cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
					 WHEN 1 THEN cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
					 WHEN 2 THEN cast( Alpha_Emp_Code as varchar)
					 WHEN 3 THEN Initial + SPACE(1) + Emp_First_Name + SPACE(1) + Emp_Second_Name+SPACE(2) + Emp_Last_Name
					 WHEN 4 THEN Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar)
				  END as Emp_Full_Name
	FROM V0080_EMPLOYEE_MASTER as VEM
		INNER JOIN (SELECT TOP 1 * FROM dbo.fn_getReportingManager(@Cmp_Id , @Emp_ID , GETDATE()) order by Row_ID desc ) REM ON VEM.EMP_ID = REM.R_Emp_ID
	WHERE Cmp_ID = @Cmp_Id AND VEM.Emp_ID <> @Emp_ID AND
		(VEM.Emp_Left<>'Y' OR (VEM.Emp_Left='Y' and CONVERT(VARCHAR(10),ISNULL(VEM.Emp_Left_Date,0),120) > CONVERT(VARCHAR(10),GETDATE(),120)))
		
	--and VEM.Emp_ID in (select R_Emp_ID from T0090_EMP_REPORTING_DETAIL where Emp_ID=@Emp_Id 
	--			And Effect_Date = (select Max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where Emp_ID=@Emp_Id and effect_Date<=Getdate()) )
	--order by 
	--Case @Emp_Search When 3 Then emp.Emp_First_Name When 4 Then emp.Emp_First_Name
	--Else
	--Case When IsNumeric(emp.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + emp.Alpha_Emp_Code, 20)
	--When IsNumeric(emp.Alpha_Emp_Code) = 0 then Left(emp.Alpha_Emp_Code + Replicate('',21), 20)
	--Else emp.Alpha_Emp_Code 
	--End
	--end 


/******* OLD CODE COMMENTED BY RAMIZ ON 23/01/2019 ****************/

/*
if @Branch_ID =0
	SET @Branch_ID =NULL
Declare @is_Designationwise tinyint
select @is_Designationwise = ISNULL(is_organo_designationwise,0) from T0010_COMPANY_MASTER where Cmp_Id = @Cmp_Id 

Select Emp_ID,
case @Emp_Search when 0 then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
when 1 then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
when 2 then cast( Alpha_Emp_Code as varchar)
when 3 then Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
when 4 then Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar) end as Emp_Full_Name
from v0080_employee_MASTER as emp
Where Cmp_ID=@Cmp_Id and 
(Emp_Left<>'Y' or (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))
and emp.Emp_ID <> @Emp_ID
and Emp_ID in (select R_Emp_ID from T0090_EMP_REPORTING_DETAIL where Emp_ID=@Emp_Id 
				And Effect_Date = (select Max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where Emp_ID=@Emp_Id and effect_Date<=Getdate()) )
order by 

Case @Emp_Search When 3 Then emp.Emp_First_Name When 4 Then emp.Emp_First_Name
Else
Case When IsNumeric(emp.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + emp.Alpha_Emp_Code, 20)
When IsNumeric(emp.Alpha_Emp_Code) = 0 then Left(emp.Alpha_Emp_Code + Replicate('',21), 20)
Else emp.Alpha_Emp_Code 
End
end
*/ 



RETURN

