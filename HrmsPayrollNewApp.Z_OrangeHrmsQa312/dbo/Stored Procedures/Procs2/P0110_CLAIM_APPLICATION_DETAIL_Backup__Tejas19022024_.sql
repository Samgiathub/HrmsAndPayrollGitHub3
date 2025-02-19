---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0110_CLAIM_APPLICATION_DETAIL_Backup_(Tejas19022024)]
	 @Claim_App_Detail_ID	NUMERIC(18,0) OUTPUT
	,@Cmp_ID				NUMERIC(18,0)
	,@Claim_App_ID	numeric(18,0)
	,@Claim_ID		NUMERIC(18,0) 
	,@For_Date		DateTime--varchar(30)
	,@Application_Amount		NUMERIC(18,3)	= NULL
	,@Description				Nvarchar(500)	= NULL	
	,@Curr_ID		NUMERIC(18,0) = NULL
	,@Curr_Rate		NUMERIC(18,3) = NULL
	,@Claim_Amount	NUMERIC(18,3) = NULL
	,@Tran_Type		Char(1) 
	,@Claim_Attachment NVARCHAR(500) 
	,@Petrol_KM		Numeric(18,2) = 0	
	,@User_Id numeric(18,0) = 0 
	,@IP_Address varchar(30)= '' 
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
	,@UnitFlag int = null
	,@ConversionRate float = null
	,@UnitName varchar(100) = null
	,@SelfAmount NUMERIC(18,3) = NULL
	,@Claim_Date_Label Varchar(100) = null
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	

	SELECT @DateOfPurchase = CASE ISNULL(@DateOfPurchase,'') WHEN '' THEN null ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @DateOfPurchase, 105), 23) END
	if @Curr_ID = 0
	set @Curr_ID=null
	
	-- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 08072016(end)



	If UPPER(@Tran_Type) = 'I' or UPPER(@Tran_Type) = 'F' 
		Begin
			
			Select @Claim_App_Detail_ID = ISNULL(MAX(Claim_App_Detail_ID),0) + 1 From T0110_CLAIM_APPLICATION_DETAIL WITH (NOLOCK)
			
			Insert Into T0110_CLAIM_APPLICATION_DETAIL 
					(Claim_App_Detail_ID,Cmp_ID,Claim_App_ID ,For_Date, Application_Amount,Claim_description,Claim_Id,Curr_ID,Curr_Rate,Claim_Amount,Petrol_KM,Claim_Attachment, Claim_Model,Claim_IMEI,Claim_NoofPerson,Claim_DateOfPurchase,
					Claim_BookName,Claim_Subject,Claim_ActualPrice,Claim_PriceAfterDiscount,Claim_FamilyMember,Claim_Relation,Claim_Age,Claim_Limit,Claim_FamilyMeberId,Claim_UnitName,Claim_UnitFlag,Claim_ConversionRate,ClaimSelf_Value,Claim_Date_Label)
				Values (@Claim_App_Detail_ID,@Cmp_ID,@Claim_App_ID,@For_Date,isnull(@Application_Amount,0), @Description,@Claim_ID,@Curr_ID,@Curr_Rate,@Claim_Amount,@Petrol_KM,@Claim_Attachment, @Model,@IMEI,@NoofPerson,@DateOfPurchase,
				@BookName,@Subject,@ActualPrice,@PriceAfterDiscount,@FamilyMember,@Relation,@Age,@FamilyLimit,@RowId,@UnitName,@UnitFlag,@ConversionRate,@SelfAmount,@Claim_Date_Label)
					
			-- Add By Mukti 08072016(start)
				exec P9999_Audit_get @table = 'T0110_CLAIM_APPLICATION_DETAIL' ,@key_column='Claim_App_Detail_ID',@key_Values=@Claim_App_Detail_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			-- Add By Mukti 08072016(end)	
			
		End
		else if UPPER(@Tran_Type)='U' or UPPER(@Tran_Type) = 'F' 
		begin


			Select @Claim_App_Detail_ID = ISNULL(MAX(Claim_App_Detail_ID),0) + 1 From T0110_CLAIM_APPLICATION_DETAIL WITH (NOLOCK)
			
			Insert Into T0110_CLAIM_APPLICATION_DETAIL 
					(Claim_App_Detail_ID,Cmp_ID,Claim_App_ID ,For_Date, Application_Amount,Claim_description,Claim_Id,Curr_ID,Curr_Rate,Claim_Amount,Petrol_KM,Claim_Attachment, Claim_Model,Claim_IMEI,Claim_NoofPerson,Claim_DateOfPurchase,
					Claim_BookName,Claim_Subject,Claim_ActualPrice,Claim_PriceAfterDiscount,Claim_FamilyMember,Claim_Relation,Claim_Age,Claim_Limit,Claim_FamilyMeberId,Claim_UnitName,Claim_UnitFlag,Claim_ConversionRate,ClaimSelf_Value,Claim_Date_Label)
				Values (@Claim_App_Detail_ID,@Cmp_ID,@Claim_App_ID,
				--convert(varchar,@For_Date,103),
				cast (@for_date as varchar),
				isnull(@Application_Amount,0), @Description,@Claim_ID,@Curr_ID,@Curr_Rate,@Claim_Amount,@Petrol_KM,@Claim_Attachment, @Model,@IMEI,@NoofPerson,@DateOfPurchase,
				@BookName,@Subject,@ActualPrice,@PriceAfterDiscount,@FamilyMember,@Relation,@Age,@FamilyLimit,@RowId,@UnitName,@UnitFlag,@ConversionRate,@SelfAmount,@Claim_Date_Label) -- @Claim_Attachment ADDED ON 17022018 BY RAJPUT
				
			-- Add By Mukti 08072016(start)
				--exec P9999_Audit_get @table = 'T0110_CLAIM_APPLICATION_DETAIL' ,@key_column='Claim_App_Detail_ID',@key_Values=@Claim_App_Detail_ID,@String=@String output
				--set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			-- Add By Mukti 08072016(end)	
		--end
		End

		UPDATE W SET W.Claim_App_Amount = Amount FROM T0100_CLAIM_APPLICATION W
		INNER JOIN
		(
			SELECT SUM(Application_Amount) AS Amount,Claim_App_ID FROM T0110_CLAIM_APPLICATION_DETAIL
			WHERE Claim_App_ID = @Claim_App_ID GROUP BY Claim_App_ID	
		) t ON t.Claim_App_ID = w.Claim_App_ID
		WHERE w.Claim_App_ID = @Claim_App_ID

	--exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Application Details',@OldValue,@Claim_App_Detail_ID,@User_Id,@IP_Address
END


