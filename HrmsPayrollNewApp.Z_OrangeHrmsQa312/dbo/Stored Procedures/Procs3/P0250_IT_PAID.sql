


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0250_IT_PAID]
	@IT_Paid_ID			numeric output
   ,@Cmp_ID				numeric
   ,@For_Date			Datetime
   ,@IT_Tran_Year		varchar(12)
   ,@IT_Payment_Date	datetime
   ,@IT_Challan_No		varchar(30)
   ,@IT_Ack_No			varchar(30)
   ,@IT_Bank_Name		varchar(50)
   ,@IT_BSR_No			varchar(20)
   ,@IT_Payment_Mode	varchar(10)	
   ,@IT_Cheque_No		varchar(15)
   ,@IT_Amount			numeric(10,0)
   ,@IT_Interest_Amount	numeric(7,0)
   ,@IT_Other_Amount	numeric(7,0)
   ,@IT_Total_Amount	numeric(12,0)
   ,@IT_Comments        varchar(250)
   ,@Login_ID			numeric(18,0)
   ,@tran_type as varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
		select @IT_Paid_ID = Isnull(max(IT_Paid_ID),0) + 1 	From T0250_IT_PAID WITH (NOLOCK)
		
				
			INSERT INTO T0250_IT_PAID
			                      (IT_Paid_ID,Cmp_ID,For_Date,IT_Tran_Year,IT_Payment_Date,IT_Challan_No,IT_Acknowledgement_No,IT_Bank_Name,IT_Bank_BSR_Code,IT_Payment_Mode,IT_Cheque_No,IT_Amount,IT_Interest_Amount,IT_Other_Amount,IT_Total_Amount,IT_Comments,Login_ID,System_Date )
			VALUES     (@IT_Paid_ID,@Cmp_ID,@For_Date,@IT_Tran_Year,@IT_Payment_Date,@IT_Challan_No,@IT_Ack_No,@IT_Bank_Name,@IT_BSR_No,@IT_Payment_Mode,@IT_Cheque_No,@IT_Amount,@IT_Interest_Amount,@IT_Other_Amount,@IT_Total_Amount,@IT_Comments,@Login_ID,getdate())	
			
			
			  
		End
	else if @tran_type  = 'D'
		Begin
		Delete from  T0251_IT_PAID_Detail where  cmp_id=@Cmp_ID and IT_Paid_ID = @IT_Paid_ID
		Delete from T0250_IT_PAID where cmp_id=@Cmp_ID and IT_Paid_ID = @IT_Paid_ID
		end
	RETURN




