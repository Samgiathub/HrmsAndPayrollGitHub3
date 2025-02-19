

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_CLAIM_LEVEL_APPROVAL]
	 @Tran_ID				NUMERIC(18,0)	OUTPUT
	,@Claim_App_ID NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	,@Approval_Status		varchar(500)
	,@Approval_Comments		Varchar(Max)
	,@Login_ID				NUMERIC(18,0)
	,@Rpt_Level				TinyInt	
	,@Claim_Apr_Amount		numeric(18,2)
	,@Claim_Apr_Pending_Amnt numeric(18,2)
	,@Claim_App_Amount      numeric(18,2)
	,@Curr_ID				numeric(18,0)
	,@Curr_Rate				numeric(18,2)
	,@Claim_App_Total_Amount numeric(18,2)	
	,@Tran_Type				Char(1) 	
	,@Attached_Doc_File		varchar(max)
	,@Claim_ID			numeric(18,0)=null
	,@Deduct_frm_salary		numeric(18,0)
	,@For_Date			Datetime=null
	,@Claim_App_Purpose	Varchar(500)=null
	,@Approved_Petrol_Km	Numeric(18,2) = 0	--Ankit 06022015
	,@Model varchar(500) = null
	,@IMEI varchar(500) = null
	,@NoofPerson varchar(500) = null
	,@DateOfPurchase varchar(50) = null
	,@BookName varchar(200) = null
	,@Subject varchar(200) = null
	,@ActualPrice float = null
	,@PriceAfterDiscount float = null
	,@FamilyMember varchar(200) = null
	,@Relation varchar(100) = null
	,@Age float = null
	,@FamilyLimit float = null
	,@RowId int = null
	,@Claim_Comments VARCHAR(250)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	Declare @Create_Date As Datetime
	
	Set @Create_Date = GETDATE()
	
	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	IF @Curr_ID=0
		SET @Curr_ID=null
		
	IF @Curr_Rate=0
		SET @Curr_Rate=null		
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			
			IF Exists(Select 1 From T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK) Where Emp_ID=@Emp_ID 
			and Claim_App_ID=@Claim_App_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
			--IF Exists(Select 1 From T0115_CLAIM_LEVEL_APPROVAL Where Emp_ID=@Emp_ID --and Claim_Apr_ID=@Claim_Apr_ID
			-- And S_Emp_Id = @S_Emp_ID 
			-- And Claim_App_Amount = @Claim_App_Amount
			-- And for_date = @For_Date
			-- And Claim_ID=@Claim_ID)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
		
			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)
			
			Insert Into T0115_CLAIM_LEVEL_APPROVAL
					(Tran_ID,Claim_App_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Claim_Apr_Status,Claim_Apr_Comments, Login_ID,System_date,Rpt_Level,Claim_Apr_Amount,Claim_Apr_Pending_Amnt,Claim_App_Amount,Curr_ID,Curr_Rate,Claim_App_Total_Amount,Attached_Doc_File,Deduct_from_salary,Claim_ID,for_date,Claim_App_Purpose,Approved_Petrol_Km,Claim_Model,Claim_IMEI,Claim_NoofPerson,Claim_DateOfPurchase,
					Claim_BookName,Claim_Subject,Claim_ActualPrice,Claim_PriceAfterDiscount,Claim_FamilyMember,Claim_Relation,Claim_Age,Claim_Limit,Claim_FamilyMeberId,Claim_Comments)
			Values (@Tran_ID, @Claim_App_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID,@Create_Date,@Rpt_Level,@Claim_Apr_Amount,@Claim_Apr_Pending_Amnt,@Claim_App_Amount,@Curr_ID,@Curr_Rate,@Claim_App_Total_Amount,@Attached_Doc_File,@Deduct_frm_salary,@Claim_ID,@For_Date,@Claim_App_Purpose,@Approved_Petrol_Km,@Model,@IMEI,@NoofPerson,@DateOfPurchase,
				@BookName,@Subject,@ActualPrice,@PriceAfterDiscount,@FamilyMember,@Relation,@Age,@FamilyLimit,@RowId,@Claim_Comments)
		End
END


