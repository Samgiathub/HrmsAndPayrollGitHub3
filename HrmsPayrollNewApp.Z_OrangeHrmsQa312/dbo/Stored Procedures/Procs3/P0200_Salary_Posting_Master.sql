
-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 07/01/2025
-- Description:	To Insert and Update the Records
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Salary_Posting_Master]
	@Sal_Pos_MID numeric(18) OUTPUT,
	@Cmp_ID numeric(18) ,
	@Doc_No nvarchar(50) = '',
	@Doc_Date datetime,
	@Doc_Type nvarchar(50) = '',
	@Com_Code nvarchar(50) = '',
	@Pos_Date datetime,
	@Currency_Type nvarchar(50) = '',
	@Req_Status_M int,
	@Login_ID numeric(18),	
	@tran_type  varchar(1)
AS
BEGIN
	If @tran_type  = 'I'    
		Begin
			Insert Into T0200_Salary_Posting_Master (Cmp_Id,Doc_No,Doc_Date,Doc_Type,Com_Code,Pos_Date,Currency_Type,Req_Status_M,Login_ID,System_Date)
			Values (@Cmp_ID,@Doc_No,@Doc_Date,@Doc_Type,@Com_Code,@Pos_Date,@Currency_Type,@Req_Status_M,@Login_ID,getdate())  

			Select @Sal_Pos_MID =Isnull(max(Sal_Pos_MID),0) From T0200_Salary_Posting_Master   
		end
	Else if @tran_type ='U'  
		begin
			If Not Exists (Select Sal_Pos_MID  from T0200_Salary_Posting_Master WITH (NOLOCK) Where Sal_Pos_MID = @Sal_Pos_MID )    
			   Begin   
			   Set @Sal_Pos_MID = 0  
			   Return  
			   End  
				 Update T0200_Salary_Posting_Master
				 SET
				 Cmp_Id = @Cmp_Id,
				 Doc_No = @Doc_No,
				 Doc_Date = @Doc_Date,
				 Doc_Type = @Doc_Type,
				 Com_Code = @Com_Code,
				 Pos_Date = @Pos_Date,
				 Currency_Type = @Currency_Type,
				 Req_Status_M = @Req_Status_M,
				 Login_ID = @Login_ID,
				 System_Date = getdate()
				 Where Sal_Pos_MID = @Sal_Pos_MID  
		end
END
