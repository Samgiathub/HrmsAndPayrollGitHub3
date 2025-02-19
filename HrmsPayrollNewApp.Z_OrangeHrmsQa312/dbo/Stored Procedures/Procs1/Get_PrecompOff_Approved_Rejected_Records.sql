


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <30052015>
-- Description:	<Get PrecompOff Approved Rejected Records>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PrecompOff_Approved_Rejected_Records]
  @Cmp_ID    numeric        
 ,@Emp_ID    numeric        
 ,@Constrains   varchar(max)    
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	  declare @strQuery as nvarchar(max)
		
		set @strQuery = 'select Alpha_Emp_Code, Emp_Full_Name, Tran_ID, cmp_ID,PreCompOff_App_ID, 
                      Emp_ID, S_Emp_ID, From_Date, To_Date, Period, Remarks, Approval_Status as App_Status, RPT_Level, Final_Approval as Final_Approver, Is_FWD_REJECT as Is_Fwd_Rej, 
                      PrecompOff_App_Date, PreCompOff_Apr_Date, emp_First_Name,0 as Scheme_ID from V0115_PreCompOff_Approval_Level VPA where
						S_Emp_ID = ''' + cast(@emp_ID as varchar(20)) + ''' and '   + @Constrains
						--'' remove Cmp_ID ''Ankit 02082016
		
		--Print @strQuery
		exec(@strQuery)
		

    
END

