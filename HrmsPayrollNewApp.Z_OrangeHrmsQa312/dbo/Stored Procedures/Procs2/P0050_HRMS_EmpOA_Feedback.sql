


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_HRMS_EmpOA_Feedback]
	   @Emp_OA_ID			numeric(18) output  
      ,@Cmp_ID				numeric(18)		= null
      ,@Initiation_Id		numeric(18)		= null
      ,@Emp_Id				numeric(18)		= null
      ,@OA_ID				numeric(18)		= null
      ,@EOA_Column1			varchar(50)		= null	
      ,@EOA_Column2			varchar(50)		= null
      ,@RM_Comments			varchar(500)	= ''
      ,@HOD_Comments		varchar(500)	= ''
      ,@GH_Comments			varchar(500)	= ''
      ,@tran_type			varchar(1)		= null
	  ,@User_Id				numeric(18,0)	= 0
	  ,@IP_Address			varchar(30)		= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as varchar(max)
	set @OldValue = ''

	If Upper(@tran_type) ='I'
		Begin
		if NOT EXISTS(SELECT 1 FROM T0050_HRMS_EmpOA_Feedback WITH (NOLOCK) where Initiation_Id=@Initiation_Id and OA_ID=@OA_ID and Emp_Id=@Emp_Id)
			BEGIN
				select @Emp_OA_ID = isnull(max(Emp_OA_ID),0) + 1 from T0050_HRMS_EmpOA_Feedback WITH (NOLOCK)
				Insert into T0050_HRMS_EmpOA_Feedback
				(
						Emp_OA_ID
					   ,Cmp_ID
					   ,Initiation_Id
					   ,Emp_Id
					   ,OA_ID
					   ,EOA_Column1
					   ,EOA_Column2
					   ,RM_Comments
					   ,HOD_Comments
					   ,GH_Comments
				)
				values
				(
						@Emp_OA_ID
					   ,@Cmp_ID
					   ,@Initiation_Id
					   ,@Emp_Id
					   ,@OA_ID
					   ,@EOA_Column1
					   ,@EOA_Column2
					   ,@RM_Comments
					   ,@HOD_Comments	
					   ,@GH_Comments			   
				)
			END
		ELSE
			BEGIN
			print 'kk'
				 UPDATE T0050_HRMS_EmpOA_Feedback
				 SET    EOA_Column1		= @EOA_Column1
						,EOA_Column2		= @EOA_Column2
						,RM_Comments		= @RM_Comments
						,HOD_Comments		= @HOD_Comments
						,GH_Comments		= @GH_Comments
				 WHERE  OA_ID=@OA_ID and Emp_Id=@Emp_Id and Initiation_Id = @Initiation_Id
			END
		End
Else If  Upper(@tran_type) ='U' 
	Begin
		  Update T0050_HRMS_EmpOA_Feedback
		  Set    EOA_Column1		= @EOA_Column1
				,EOA_Column2		= @EOA_Column2
				,RM_Comments		= @RM_Comments
				,HOD_Comments		= @HOD_Comments
				,GH_Comments		= @GH_Comments
		  Where  Emp_OA_ID = @Emp_OA_ID and Initiation_Id = @Initiation_Id
	End
Else If  Upper(@tran_type) ='D'
	Begin
		DELETE FROM T0050_HRMS_EmpOA_Feedback WHERE Emp_OA_ID = @Emp_OA_ID
	End
END



