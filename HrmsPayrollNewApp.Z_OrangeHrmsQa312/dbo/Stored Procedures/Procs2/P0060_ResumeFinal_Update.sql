



-- =============================================
-- Author:	Sneha
-- ALTER date:31 jul 2013
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_ResumeFinal_Update] 
	 @Cmp_ID			numeric(18, 0)
	,@Resume_ID			numeric(18, 0)
	,@SalaryCycle_Id    numeric(18, 0)
	,@PaymentMode      	numeric(18, 0)
	,@BankId			numeric(18, 0)
	,@AccountNo_Bank    varchar(100)
	,@Remarks           varchar(100)
	,@FinalStatus       int
	,@ApprovedBy        numeric(18,0)
	,@IsEmployee        int
	,@Basic_Salay		numeric(18,0)
	,@Joining_date      datetime
	,@Salary_Rule       int
	,@IFSC_Code varchar(25) = '' --Mukti(28102017)
	,@Adhar_No varchar(50) = '' --Mukti(28102017)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	if @BankId = 0
		set @BankId = null
		
		if exists(select 1 from T0060_RESUME_FINAL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Resume_ID=@Resume_ID)
			begin
				Update T0060_RESUME_FINAL
				set    PaymentMode = @PaymentMode
					  ,SalaryCycle_Id = @SalaryCycle_Id
					  ,BankId   = @BankId
					  ,AccountNo_Bank = @AccountNo_Bank
					  ,Remarks = @Remarks
					  ,FinalStatus = @FinalStatus
					  ,ApprovedBy = @ApprovedBy
					  ,IsEmployee =@IsEmployee
					  ,Basic_Salay= @Basic_Salay
					  ,Joining_date=@Joining_date
					  ,Salary_Rule=@Salary_Rule
					  ,IFSC_Code = @IFSC_Code --Mukti(28102017)
				Where  Resume_ID = @Resume_ID and Cmp_ID = @Cmp_ID	
			end		
			
			update T0055_Resume_Master set Aadhar_CardNo=@Adhar_No  --Mukti(28102017)
			Where  Resume_ID = @Resume_ID and Cmp_ID = @Cmp_ID	
END



