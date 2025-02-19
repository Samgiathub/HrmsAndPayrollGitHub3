


-- Create By Nilesh Delete Production details Import.
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Production_Details_Import_Delete]    
 @Tran_ID numeric(18,0)    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @emp_id as numeric
declare @Month as numeric
declare @Year as numeric

select  @emp_id = Employee_ID ,@Month= production_month,@Year=production_year from T0050_Production_Details_Import WITH (NOLOCK) where Tran_ID = @Tran_ID

if exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and year(Month_End_Date) =@Year  )
begin
	RAISERROR('@@ Salary Exist for Month @@',16,2)
	return
end
else
begin
	Delete from T0050_Production_Details_Import where Tran_ID=@Tran_ID 
End
 RETURN    
    
  


