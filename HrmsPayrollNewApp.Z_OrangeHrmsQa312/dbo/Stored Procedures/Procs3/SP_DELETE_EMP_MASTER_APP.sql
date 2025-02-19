

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_DELETE_EMP_MASTER_APP]
	-- Add the parameters for the stored procedure here
	@Emp_Tran_ID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


							Delete from T0090_EMP_PRIVILEGE_DETAILS_APP
								 Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_REPORTING_DETAIL_APP 
								 Where Emp_Tran_ID=@Emp_Tran_ID  
								 
							Delete From T0065_EMP_SHIFT_DETAIL_APP 
								 Where Emp_Tran_ID=@Emp_Tran_ID  
								 
							Delete From T0065_EMP_CHILDRAN_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_CONTRACT_DETAIL_APP  
								 Where Emp_Tran_ID=@Emp_Tran_ID  
								 
							Delete From T0065_EMP_DEPENDANT_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_DOC_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_EXPERIENCE_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_IMMIGRATION_DETAIL_APP 
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_LANGUAGE_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
							
							Delete From T0065_EMP_LICENSE_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_QUALIFICATION_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_SKILL_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0065_EMP_REFERENCE_DETAIL_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
							
							Delete From T0070_WEEKOFF_ADJ_APP 
								 Where Emp_Tran_ID=@Emp_Tran_ID  
								 
							Delete From T0070_EMP_SCHEME_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0070_EMP_INCREMENT_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID  
								
							Delete From T0075_EMP_EARN_DEDUCTION_APP  
								Where Emp_Tran_ID=@Emp_Tran_ID 
								
									Delete From T0060_EMP_MASTER_APP   
								Where Emp_Tran_ID=@Emp_Tran_ID  
	
END

