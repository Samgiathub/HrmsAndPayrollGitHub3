


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0195_Allowance_Days_Import] 
	@Cmp_ID	numeric(18,0)
   ,@Allow_Name varchar(100)
   ,@Month numeric(18,0)
   ,@Year numeric(18,0)
   ,@Days numeric(18,2)
   ,@GUID Varchar(2000) = '' --Added By Nilesh patel on 15062016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @AD_ID as numeric
		Declare @Tran_id as numeric
		Set @AD_ID = 0 
		Set @Tran_id = 0 
		
		SELECT @AD_ID = Isnull(AD_ID,0) from T0050_AD_MASTER WITH (NOLOCK) where AD_NAME = UPPER(@Allow_Name) and CMP_ID = @Cmp_ID
		
		if @AD_ID = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Allow_Name ,'Allowance Name Doesn''t exists',@Allow_Name,'Enter proper Allowance Details',GetDate(),'Allowance Days',@GUID)			
				RETURN
			End
		
		if @Month = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Allow_Name ,'Month Details Doesn''t exists',@Allow_Name,'Enter proper Month Details',GetDate(),'Allowance Days',@GUID)			
				RETURN
			End
			
		if @Year = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Allow_Name ,'Year Details Doesn''t exists',@Allow_Name,'Enter proper Year Details',GetDate(),'Allowance Days',@GUID)			
				RETURN
			End
		
		if @Days = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Allow_Name ,'Days Details Doesn''t exists',@Allow_Name,'Enter proper Days Details',GetDate(),'Allowance Days',@GUID)			
				RETURN
			End
		
		IF Exists (Select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_NAME = @Allow_Name and CMP_ID = @Cmp_ID)
			BEGIN
					Select @AD_ID = AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_NAME = @Allow_Name and CMP_ID = @Cmp_ID
					
					IF Exists (select Tran_Id from T0195_Allowance_Days WITH (NOLOCK) where AD_ID = @AD_ID and Cmp_Id = @Cmp_ID and [MONTH] = @Month and [YEAR] = @Year)
						BEGIN
								Select @Tran_id = Tran_Id from T0195_Allowance_Days WITH (NOLOCK) where AD_ID = @AD_ID and Cmp_Id = @Cmp_ID and [MONTH] = @Month and [YEAR] = @Year
								
								Update T0195_Allowance_Days 
								SET [Month] = @Month,[Year] = @Year,[Days] = @Days
								where Tran_Id = @Tran_id
						END
					ELSE
						BEGIN
								Select @Tran_id = Isnull(max(Tran_Id),0) + 1  From dbo.T0195_Allowance_Days WITH (NOLOCK)
								INSERT INTO T0195_Allowance_Days 
								Values (@Tran_id,@Cmp_ID,@AD_ID,@Month,@Year,@Days)
						END
			END
END


