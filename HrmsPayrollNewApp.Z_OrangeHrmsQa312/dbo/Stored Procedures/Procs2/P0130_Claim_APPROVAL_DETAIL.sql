

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_Claim_APPROVAL_DETAIL]
   @Claim_Apr_Dtl_ID numeric(18, 0) output
  ,@Claim_Apr_ID numeric(18, 0)
  ,@Cmp_ID numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@Claim_ID numeric(18, 0)  
  ,@Claim_Apr_Date datetime  
  ,@Claim_App_ID numeric(18, 0)  
  ,@Claim_Apr_Code varchar(20) output 
  ,@Claim_Apr_Amount numeric(18, 3)  
  ,@Claim_App_Status Char(1)   
  ,@Claim_App_Amount as numeric(18,3)
  ,@Curr_ID as numeric(18,0)
  ,@Curr_Rate as numeric(18,3)
  ,@Purpose as nvarchar(250)
  ,@Claim_App_Total_Amount as numeric(18,3)
  ,@S_Emp_ID numeric(18,0)  
  ,@Petrol_KM	NUMERIC(18,2)--Ankit 05022015
  ,@tran_type char  
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
  ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
  ,@Claim_Limit Numeric(18,2) = 0  --Added by Jaina 12-10-2020
  ,@Claim_Exceed_Amount Numeric(18,2) = 0 --Added by Jaina 12-10-2020
  ,@Model varchar(200) = ''
  ,@IMEI varchar(200) = ''
  ,@NoOfEntertained varchar(500) = ''
  ,@PurchaseDate varchar(50) = ''
  ,@BookName varchar(200) = null
  ,@Subject varchar(200) = null
  ,@ActualPrice float = null
  ,@PriceAfterDiscount float = null
  ,@FamilyMember varchar(200) = null
  ,@Relation varchar(50) = null
  ,@Age float = null
  ,@Limit float = null
  ,@RowId int = null
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Comment by Jaina 07-10-020
--If @Claim_App_ID  =0   
--  set @Claim_App_ID  = null  
SELECT @PurchaseDate = CASE ISNULL(@PurchaseDate,'') WHEN '' THEN null ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @PurchaseDate, 105), 23) END
If @Claim_App_ID Is Null
	set @Claim_App_ID = 0
  
If @Claim_ID=0
set @Claim_ID=null  
 
 -- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
-- Add By Mukti 08072016(end)
  
   
  If UPPER(@Tran_Type) = 'I'
  begin
  select @Claim_Apr_Dtl_ID = Isnull(max(Claim_Apr_Dtl_ID),0) + 1  From T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK)

  Insert Into T0130_Claim_APPROVAL_DETAIL
  (Claim_Apr_Dtl_ID,Claim_Apr_ID,Cmp_ID,Emp_ID,Claim_ID,Claim_Apr_date,Claim_App_ID,Claim_Apr_Code,Claim_Apr_Amount,Claim_Status,Claim_App_Amount,Curr_ID,Curr_rate,Purpose,Claim_App_Ttl_Amount,S_Emp_ID,
  Petrol_KM,Claim_Limit,Claim_Exceed_Amount,Claim_Model,Claim_IMEI,Claim_NoofPerson,Claim_DateOfPurchase,Claim_BookName,Claim_Subject,Claim_ActualPrice,Claim_PriceAfterDiscount,Claim_FamilyMember,Claim_Relation,Claim_Age,Claim_FamilyLimit,Claim_FamilyMeberId)
  values
  (@Claim_Apr_Dtl_ID,@Claim_Apr_ID,@Cmp_ID,@Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_App_ID,@Claim_Apr_Code,@Claim_Apr_Amount,@Claim_App_Status,@Claim_App_Amount,@Curr_ID,@Curr_Rate,@Purpose,@Claim_App_Total_Amount,
  @S_Emp_ID,@Petrol_KM,@Claim_Limit,@Claim_Exceed_Amount,@Model,@IMEI,@NoOfEntertained,@PurchaseDate,@BookName,@Subject,@ActualPrice,@PriceAfterDiscount,@FamilyMember,@Relation,@Age,@Limit,@RowId)
    
         -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0130_Claim_APPROVAL_DETAIL' ,@key_column='Claim_Apr_Dtl_ID',@key_Values=@Claim_Apr_Dtl_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	
  end   
  
   exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Approval Details',@OldValue,@Emp_ID,@User_Id,@IP_Address,1 
return

