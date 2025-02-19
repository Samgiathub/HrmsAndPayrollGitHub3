


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0080_KPIPMS_EVAL_Update] 
	 @KPIPMS_ID					numeric(18,0) Output
	,@Final_Score				numeric(18,2)=null
	,@SignOff_EmpDate		    datetime=null
	,@SignOff_SupDate			datetime=null
	,@Final_Close				int=null
	,@Final_ClosedOn			datetime=null
	,@Final_ClosedBy			numeric(18,0)=null
	,@Final_ClosingComment		varchar(500)=null
	,@KPIPMS_EmProcessFair		int=null
	,@KPIPMS_EmpAgree			int=null
	,@KPIPMS_EmpComments		varchar(500)=null
	,@KPIPMS_ProcessFairSup		int=null
	,@KPIPMS_SupAgree			int=null
	,@KPIPMS_SupComments		varchar(500)=null
	,@User_Id					numeric(18,0) = 0
	,@IP_Address				varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @KPIPMS_ID<>0
		begin
			Update T0080_KPIPMS_EVAL
			Set    final_score		=	@Final_Score
			      ,SignOff_EmpDate	=	case when @SignOff_EmpDate = '1753-01-01' then null else @SignOff_EmpDate end
			      ,SignOff_SupDate	=	case when @SignOff_SupDate = '1753-01-01' then null else @SignOff_SupDate end
			      ,Final_Close		=	@Final_Close
			      ,Final_ClosedOn	=	case when @Final_Close = 1 then GETDATE() else null end
			      ,Final_ClosedBy	=	@Final_ClosedBy
			      ,Final_ClosingComment = @Final_ClosingComment
			      ,KPIPMS_EmProcessFair	= @KPIPMS_EmProcessFair
			      ,KPIPMS_EmpAgree		= @KPIPMS_EmpAgree
			      ,KPIPMS_EmpComments	= @KPIPMS_EmpComments
			      ,KPIPMS_ProcessFairSup = @KPIPMS_ProcessFairSup
			      ,KPIPMS_SupAgree		= @KPIPMS_SupAgree
			      ,KPIPMS_SupComments	= @KPIPMS_SupComments
			Where KPIPMS_ID	= @KPIPMS_ID
		End
END


