-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 15-07-2020
-- Description:	Mandatory Fields 
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Default_Mandatory_Fields]	
	@Cmp_ID numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Tran_ID Numeric
	DECLARE @CAPTION_NAME VARCHAR(250)	
	
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Department')
				Begin
					Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
					Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Department',0,'Department Name','Dept_ID'
				End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Date-of-Birth')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Date-of-Birth',0,'Date of Birth','Date_Of_Birth'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Login-Alias')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Login-Alias',0,'Login Alias','Login_Alias'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Gross-Salary')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Gross-Salary',0,'Gross Salary','Gross_Salary'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Basic-Salary')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Basic-Salary',0,'Basic Salary','Basic_Salary'
					End

		
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Adhar-No.')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Adhar-No.',0,'Aadhar Card No','Aadhar_Card_No'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Work-Email-ID')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Work-Email-ID',0,'Working EMail ID','Work_Email'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'No-of-Child')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)  
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','No-of-Child',0,'No. of Children','Emp_Childran'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'CTC')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','CTC',0,'CTC','CTC'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Category')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) 
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Category',0,'Category','Cat_ID'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'PAN-No')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','PAN-No',0,'PAN No','PAN_No'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Bank-Account-No')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Bank-Account-No',0,'Bank Account No','Bank_Account_No'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'ESIC-No')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','ESIC-No',0,'ESIC No','ESIC_No'
					End
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Left Employee' and Fields_Name= 'Reason')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Left Employee','Reason',0,'Reason','Reason'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Left Employee' and Fields_Name= 'Other Reason')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Left Employee','Other-Reason',0,'Other Reason','Other_Reason'
					End
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Left Employee' and Fields_Name= 'Reporting-Manager')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)  
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Left Employee','Reporting-Manager',0,'Reportin _Manager','Reporting_ Manager'
					End
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Image Name')
			Begin
				Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
				Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Image-Name',0,'Image Name','Image_Name'
			End
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Signature Image Name')
			Begin
				Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
				Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Signature-Image-Name',0,'Signature Image Name','Signature_Image_Name'
			End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Bank IFSC Code')
			Begin
				Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)
				Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Bank-IFSC-Code',0,'Bank IFSC Code','Bank_IFSC_Code'
			End
	
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Bank Branch Name')
				Begin
					Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)
					Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Bank-Branch-Name',0,'Bank Branch Name','Bank_Branch_Name'
				End

			--IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Bank Name')
			--Begin
			--	Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)
			--	Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Bank-Name',0,'Bank Name','Bank_Name'
			--End
END

