

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Photo_Details_EMP_APP]
	  @Emp_Tran_ID bigint output
	 ,@CompID int
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
				Update T0060_EMP_MASTER_APP Set Image_Name = '0.jpg' where Emp_Tran_ID = @Emp_Tran_ID and Cmp_ID=@CompID  
			else If @UploadType = 'Signature'
				Update T0060_EMP_MASTER_APP Set Signature_Image_Name = '' where Emp_Tran_ID = @Emp_Tran_ID and Cmp_ID=@CompID
		end	
	
	else if @tran_type ='I' 
		begin    
			If @UploadType = 'Profile Photo'
				Update T0060_EMP_MASTER_APP Set Image_Name = @Filename where (Emp_Tran_ID = @Emp_Tran_ID )and (Cmp_ID=@CompID)   	
			ELSE If @UploadType = 'Signature'
				Update T0060_EMP_MASTER_APP Set Signature_Image_Name = @Filename where Emp_Tran_ID = @Emp_Tran_ID and Cmp_ID=@CompID
				
		end
			  
	RETURN


