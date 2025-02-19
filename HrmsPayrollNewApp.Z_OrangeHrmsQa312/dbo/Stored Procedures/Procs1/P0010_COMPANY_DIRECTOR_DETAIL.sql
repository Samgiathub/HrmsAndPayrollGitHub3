



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0010_COMPANY_DIRECTOR_DETAIL]  
   @Director_Id numeric(18,0)  output
  ,@Cmp_Id numeric(18,0) 
  ,@Director_Name nvarchar(MAX)
  ,@Director_Address nvarchar(MAX)
  ,@Director_DOB Datetime
  ,@Director_Branch nvarchar(MAX)
  ,@Director_Designation nvarchar(MAX)
  ,@Tran_Type char(1)   
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
	If @Tran_Type ='I'
		Begin 
			select @Director_Id = isnull(max(Director_Id),0) +1 from dbo.T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK)       

			INSERT INTO dbo.T0010_COMPANY_DIRECTOR_DETAIL    
						(Director_Id,Cmp_Id,Director_Name,Director_Address,Director_DOB,Director_Branch,Director_Designation)    
			  VALUES     (@Director_Id,@Cmp_Id,@Director_Name,@Director_Address ,@Director_DOB,@Director_Branch,@Director_Designation)
		End
        
	Else if @Tran_Type ='U'  
		Begin  
			 UPDATE	T0010_COMPANY_DIRECTOR_DETAIL SET          
					Director_Name = @Director_Name,
					Director_Address = @Director_Address,
					Director_DOB = @Director_DOB,
					Director_Branch = @Director_Branch,
					Director_Designation = @Director_Designation
			 WHERE  Director_Id = @Director_Id  and Cmp_Id=@Cmp_Id
		End 
		
	Else If @Tran_Type='D'
		Begin
			Delete From T0010_COMPANY_DIRECTOR_DETAIL where Director_Id=@Director_Id and Cmp_Id=@Cmp_Id
		End       	     

RETURN


