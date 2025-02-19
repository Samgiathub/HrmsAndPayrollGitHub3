

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_Asset_Allocation]
	@Asset_Approval_ID numeric OUTPUT
	,@Resume_Id numeric
	,@Cmp_ID numeric
	,@Asset_Id numeric
	,@Brand_Id numeric
	,@Model_Name varchar(250)
	,@Allocation_Date datetime
	,@Purchase_Date datetime
	,@AssetM_Id numeric
	,@Asset_Code varchar(250)
	,@Installment_Date datetime
	,@Installment_Amount numeric(18, 2)
	,@Issue_Amount numeric(18, 2)
	,@Deduction_Type varchar(15)=''
	,@Serial_No varchar(50)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	select @Asset_Approval_ID = isnull(max(Asset_Approval_ID),0) + 1  from T0090_HRMS_Asset_Allocation WITH (NOLOCK)
	
	if exists(select top 1 Resume_Id from T0090_HRMS_Asset_Allocation WITH (NOLOCK) where Resume_Id=@Resume_Id and cmp_id=@cmp_id and Asset_Code=@Asset_Code)
		begin
			update T0090_HRMS_Asset_Allocation
			set Asset_Id=@Asset_Id,
			Brand_Id=@Brand_Id,
			Model_Name=@Model_Name,
			Allocation_Date=@Allocation_Date,
			Purchase_Date=@Purchase_Date,
			AssetM_Id=@AssetM_Id,
			Asset_Code=@Asset_Code,
			Installment_Date=@Installment_Date,
			Installment_Amount=@Installment_Amount,
			Issue_Amount=@Issue_Amount,
			Deduction_Type=@Deduction_Type,
			Serial_No=@Serial_No
			where Resume_Id=@Resume_Id and Asset_Code=@Asset_Code and cmp_id=@cmp_id
		end
	else 
		begin
			insert into T0090_HRMS_Asset_Allocation(Asset_Approval_ID,Resume_Id,Cmp_ID,Asset_Id,Brand_Id,Model_Name,Allocation_Date,Purchase_Date,AssetM_Id,Asset_Code,Installment_Date,Installment_Amount,Issue_Amount,Deduction_Type,Serial_No)
			values(@Asset_Approval_ID,@Resume_Id,@Cmp_ID,@Asset_Id,@Brand_Id,@Model_Name,@Allocation_Date,@Purchase_Date,@AssetM_Id,@Asset_Code,@Installment_Date,@Installment_Amount,@Issue_Amount,@Deduction_Type,@Serial_No)
		end

 
RETURN @Asset_Approval_ID




