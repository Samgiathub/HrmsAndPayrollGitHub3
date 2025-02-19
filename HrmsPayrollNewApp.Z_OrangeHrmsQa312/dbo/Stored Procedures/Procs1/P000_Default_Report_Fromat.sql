


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 27/04/2016
-- Description:	For Set Default Format of Report
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P000_Default_Report_Fromat] 
   @Trans_ID Numeric(18,0) output,
   @Emp_ID Numeric(18,0),
   @UserID Numeric(18,0),
   @Report_ID Numeric(18,0),
   @Report_Name Varchar(500),
   @ddlformat Varchar(500),
   @ddl_Type Varchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if Exists(Select 1 From Default_Report_Fromat WITH (NOLOCK) where Emp_ID = @Emp_ID AND UserID = @UserID AND Report_ID = @Report_ID)
		BEGIN
			UPDATE Default_Report_Fromat
				Set Report_Name = @Report_Name,
					ddlformat  = @ddlformat,
					ddl_Type = @ddl_Type,
					sys_date = GETDATE()
			    Where Emp_ID = @Emp_ID AND UserID = @UserID AND Report_ID = @Report_ID
		END
	Else
		Begin
			Insert INTO Default_Report_Fromat(Emp_ID,UserID,Report_ID,Report_Name,ddlformat,ddl_Type,sys_date) VALUES(@Emp_ID,@UserID,@Report_ID,@Report_Name,@ddlformat,@ddl_Type,GETDATE())
		End
END

