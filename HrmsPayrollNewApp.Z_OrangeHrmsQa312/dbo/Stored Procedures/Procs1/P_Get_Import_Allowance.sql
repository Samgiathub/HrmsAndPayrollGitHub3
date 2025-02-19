

-- =============================================
-- Author:		<Jaina>
-- Create date: <25-04-2018>
-- Description:	<Allowance Import Report>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Import_Allowance]
	@Cmp_Id numeric(18,0),
	@Month numeric(18,0),
	@Year numeric(18,0),
	@Branch_Id numeric(18,0) = 0,
	@Ad_Id numeric(18,0) = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Branch_Id = 0
		set @Branch_Id = NULL
	
	IF @Ad_Id = 0
		set @Ad_Id = NULL
	
	SELECT E.Alpha_Emp_Code as [Employee Code],E.Emp_Full_Name as [Employee Name],
		dbo.F_GET_MONTH_NAME(MAD.Month) As Month, MAD.Year,A.AD_NAME As [Allowance Name],MAD.Amount,MAD.Comments
			
	from T0190_MONTHLY_AD_DETAIL_IMPORT MAD WITH (NOLOCK) inner JOIN
		 T0050_AD_MASTER A WITH (NOLOCK) ON A.AD_ID = MAD.AD_ID inner JOIN
		 T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = MAD.Emp_ID 
		 CROSS APPLY (SELECT IQ.Increment_ID,IQ.Branch_Id
					  FROM	dbo.fn_getEmpIncrement(mad.cmp_id,mad.emp_id,mad.for_date) IQ )IQ 					  		 
	where A.CMP_ID = @Cmp_Id and mad.Month = @Month and MAD.Year = @Year
		and IQ.Branch_Id = isnull(@Branch_Id,IQ.Branch_Id) 
		and mad.AD_ID = ISNULL(@Ad_Id,MAD.AD_ID)
    
END

