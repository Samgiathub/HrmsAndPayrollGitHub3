
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_CLAIM_LEVEL_APPROVAL_DETAIL]
   @Claim_Tran_ID numeric(18, 0) output
  ,@Claim_Apr_ID numeric(18, 0)
  ,@Claim_App_ID numeric(18, 0)  
  ,@Cmp_ID numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@S_Emp_ID numeric(18,0)  
  ,@Claim_ID numeric(18, 0)  
  ,@Claim_Apr_Date datetime  
  ,@Claim_Apr_Code varchar(20) output 
  ,@Claim_Apr_Amount numeric(18, 3)  
  ,@Claim_Status varchar(20)
  ,@Claim_App_Amount as numeric(18,3)
  ,@Curr_ID as numeric(18,0)
  ,@Curr_Rate as numeric(18,3)
  ,@Claim_Purpose as nvarchar(250)
  ,@Claim_App_Total_Amount as numeric(18,3)
  ,@Approved_Petrol_Km	NUMERIC(18,3)--Ankit 05022015
  ,@Login_ID numeric(18,0)
  ,@Rpt_Level numeric(18,0)
  ,@For_Date datetime
  ,@tran_type char  
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
  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @Claim_App_ID  =0   
  set @Claim_App_ID  = null  
  
If @Claim_ID=0
set @Claim_ID=null  
 
 
  
  If UPPER(@Tran_Type) = 'I'
  begin
  select @Claim_Tran_ID = Isnull(max(Claim_Tran_ID),0) + 1  From T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
  
  Insert Into T0115_CLAIM_LEVEL_APPROVAL_DETAIL
  (Claim_Tran_ID,Claim_Apr_ID,Claim_App_ID,Cmp_ID,Emp_ID,S_Emp_ID,Claim_ID,Claim_Apr_date,Claim_Apr_Code,Claim_Apr_Amnt,Claim_Status,Claim_App_Amnt,Curr_ID,Curr_rate,Purpose,Claim_App_Total_Amnt,PetrolKM,Login_ID,Rpt_Level,For_Date,Claim_Model,Claim_IMEI,Claim_NoofPerson,Claim_DateOfPurchase,
  Claim_BookName,Claim_Subject,Claim_ActualPrice,Claim_PriceAfterDiscount,Claim_FamilyMember,Claim_Relation,Claim_Age,Claim_Limit,Claim_FamilyMeberId)
  values
  (@Claim_Tran_ID,@Claim_Apr_ID,@Claim_App_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_Apr_Code,@Claim_Apr_Amount,@Claim_Status,@Claim_App_Amount,@Curr_ID,@Curr_Rate,@Claim_Purpose,@Claim_App_Total_Amount,@Approved_Petrol_Km,@Login_ID,@Rpt_Level,@For_Date,@Model,@IMEI,@NoofPerson,@DateOfPurchase,
  @BookName,@Subject,@ActualPrice,@PriceAfterDiscount,@FamilyMember,@Relation,@Age,@FamilyLimit,@RowId)
  
  end
    
  
    
return

