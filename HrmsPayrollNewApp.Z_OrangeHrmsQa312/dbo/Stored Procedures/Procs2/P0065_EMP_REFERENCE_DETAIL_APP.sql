

-- =============================================
-- Author:		Binal Prajapati
-- Create date: 18-March-2019
-- Description:	Make A CHECKER EMPLOYEE APPLICATION INSERT REFERENCE DETAIL
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0065_EMP_REFERENCE_DETAIL_APP]

@Reference_ID	int output,
@Emp_Tran_ID bigint,
@Emp_Application_ID int,
@Cmp_ID			int,
@R_Emp_ID		int,
@Ref_Description	varchar(100),
@Amount			numeric(18, 2),
@Comments		varchar(100),
@Contact_Person varchar(100) = '',
@Contact_Number varchar(100)= 0,
@Designation    varchar(100) = '',
@City			varchar(50) ='',
@Source_Type	integer = 2,
@Source_Name	integer = 0,
@Ref_Month		int = 0,
@Ref_Year		int = 0,
@tran_type		varchar(1),
@Approved_Emp_ID int,
@Approved_Date datetime = Null,
@Rpt_Level int 

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Source_Type = 0 
		 set @Source_Type = 2
		
		
    If @tran_type = 'I'
		Begin
			
			
			
			Select @Reference_ID = isnull(max(Reference_ID),0) + 1 from T0065_EMP_REFERENCE_DETAIL_APP WITH (NOLOCK)
			
			Insert Into T0065_EMP_REFERENCE_DETAIL_APP(Reference_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID,R_Emp_ID,Ref_Description,Amount,Comments,Contact_Person,Mobile,Designation,City,Source_Type,Source_Name,Ref_Month,Ref_Year,Approved_Emp_ID,Approved_Date,Rpt_Level)
			Values (@Reference_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@R_Emp_ID,@Ref_Description,@Amount,@Comments,@Contact_Person,@Contact_Number,@Designation,@City,@Source_Type,@Source_Name,@Ref_Month,@Ref_Year,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
			
		End
    
    
END


