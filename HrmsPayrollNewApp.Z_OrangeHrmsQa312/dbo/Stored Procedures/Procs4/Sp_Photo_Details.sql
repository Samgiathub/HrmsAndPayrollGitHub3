
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Photo_Details]
	  @EmpID numeric(18) output
	 ,@CompID numeric(18)
	 ,@Filename varchar(200)
	 ,@tran_type char
	 ,@UploadType varchar(15)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type ='D'
		begin
			If @UploadType = 'Profile Photo'
				Update T0080_EMP_MASTER Set Image_Name = '0.jpg' where Emp_ID = @EmpID and Cmp_ID=@CompID  
			else If @UploadType = 'Signature'
				Update T0080_EMP_MASTER Set Signature_Image_Name = '' where Emp_ID = @EmpID and Cmp_ID=@CompID
		end	
	
	else if @tran_type ='I' 
		begin    
			If @UploadType = 'Profile Photo'
				Update T0080_EMP_MASTER Set Image_Name = @Filename where (Emp_ID = @EmpID )and (Cmp_ID=@CompID)   	
			ELSE If @UploadType = 'Signature'
				Update T0080_EMP_MASTER Set Signature_Image_Name = @Filename where Emp_ID = @EmpID and Cmp_ID=@CompID
				
		end
			  
	RETURN




