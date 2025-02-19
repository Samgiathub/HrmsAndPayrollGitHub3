

-- =============================================
-- Author     :	Alpesh
-- Create date: 13-Aug-2012
-- Description:	
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0065_EMP_REFERENCE_DETAIL_DELETE]

@Cmp_ID			int,
@Emp_Tran_ID    bigint,
@Emp_Application_ID int,
@Referance_ID   int

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If exists (Select 1 from T0065_EMP_REFERENCE_DETAIL_APP WITH (NOLOCK) where Cmp_ID = @Cmp_ID and 
			Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID AND Reference_ID = @Referance_ID)
		Begin
			
			Delete from T0065_EMP_REFERENCE_DETAIL_APP where Cmp_ID = @Cmp_ID and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID AND Reference_ID = @Referance_ID
		
		End
	
	
    
END


