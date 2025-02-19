
-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 07/01/2025
-- Description:	To Insert and Update the Records
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Salary_Posting_Detail]	
	@Sal_Pos_DID numeric(18) OUTPUT,
	@Sal_Pos_MID numeric(18),
	@Cmp_ID numeric(18),
	@Pos_Key int,
	@GL_AccNo nvarchar(50) = '',
	@GL_Name nvarchar(50) = '',
	@Asset_Name nvarchar(50) = '',
	@Total_Amount numeric(16, 2),
	@Tax_Code nvarchar(50) = '',
	@Cost_Center nvarchar(50) = '',
	@Profit_Center nvarchar(50) = '',
	@Plant_Name nvarchar(50) = '',
	@Req_Status_D int,		
	@Login_ID numeric(18),
	@tran_type  varchar(1)
AS
BEGIN
	If @tran_type  = 'I'    
		Begin
			Insert Into T0200_Salary_Posting_Detail (Sal_Pos_MID,Cmp_Id,Pos_Key,GL_AccNo,GL_Name,Asset_Name,Total_Amount,Tax_Code,Cost_Center,
						Profit_Center,Plant_Name,Req_Status_D,Login_ID,System_Date)
			Values (@Sal_Pos_MID,@Cmp_Id,@Pos_Key,@GL_AccNo,@GL_Name,@Asset_Name,@Total_Amount,@Tax_Code,@Cost_Center,
						@Profit_Center,@Plant_Name,@Req_Status_D,@Login_ID,getdate())  

			Select @Sal_Pos_MID =Isnull(max(Sal_Pos_MID),0) From T0200_Salary_Posting_Master   
		end
	Else if @tran_type ='U'  
		begin
			If Not Exists (Select Sal_Pos_DID  from T0200_Salary_Posting_Detail WITH (NOLOCK) Where Sal_Pos_DID = @Sal_Pos_DID )    
			   Begin   
			   Set @Sal_Pos_DID = 0  
			   Return  
			   End  
				 Update T0200_Salary_Posting_Detail
				 SET
				 Sal_Pos_MID = @Sal_Pos_MID,
				 Cmp_Id = @Cmp_Id,
				 Pos_Key = @Pos_Key,
				 GL_AccNo = @GL_AccNo,
				 GL_Name = @GL_Name,
				 Asset_Name = @Asset_Name,
				 Total_Amount = @Total_Amount,
				 Tax_Code = @Tax_Code,
				 Cost_Center = @Cost_Center,
				 Profit_Center = @Profit_Center,
				 Plant_Name = @Plant_Name,
				 Req_Status_D = @Req_Status_D,
				 Login_ID = @Login_ID,
				 System_Date = getdate()
				 Where Sal_Pos_DID = @Sal_Pos_DID  
		end
END
