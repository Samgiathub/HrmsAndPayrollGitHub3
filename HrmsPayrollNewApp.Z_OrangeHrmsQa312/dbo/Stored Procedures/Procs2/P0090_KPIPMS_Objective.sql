

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_KPIPMS_Objective]
	   @KPIPMS_ObjID	numeric(18,0) output
      ,@Cmp_Id			numeric(18,0)
      ,@KPIPMS_ID		numeric(18,0)
      ,@KPIObj_ID		numeric(18,0)
      ,@Emp_ID			numeric(18,0)
      ,@Status			varchar(250)
      ,@tran_type		varchar(1) 
	  ,@User_Id			numeric(18,0) = 0
	  ,@IP_Address		varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		Begin
			if @KPIPMS_ID =0
				begin
					select @KPIPMS_ID = max(kpipms_id) from T0080_KPIPMS_EVAL WITH (NOLOCK) where Cmp_ID=@Cmp_Id
				end
			select @KPIPMS_ObjID = isnull(max(KPIPMS_ObjID),0) + 1 from T0090_KPIPMS_Objective	 WITH (NOLOCK)
			
			Insert into T0090_KPIPMS_Objective
			(
			   [KPIPMS_ObjID]
			  ,[Cmp_Id]
			  ,[KPIPMS_ID]
			  ,[KPIObj_ID]
			  ,[Emp_ID]
			  ,[Status]
			)
			Values
			(
				 @KPIPMS_ObjID
				,@Cmp_Id
				,@KPIPMS_ID
				,@KPIObj_ID
				,@Emp_ID
				,@Status
			)
		End
	Else If  Upper(@tran_type) ='U' 
		begin
			UPDATE  T0090_KPIPMS_Objective
			SET	 [Status] = @Status
			WHERE 	KPIPMS_ObjID = @KPIPMS_ObjID
		End
	Else if Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0090_KPIPMS_Objective WHERE  KPIPMS_ObjID = @KPIPMS_ObjID 
		End
END

