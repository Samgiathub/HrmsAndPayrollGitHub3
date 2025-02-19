
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_Production_Bonus_Variable_Import]
 @Tran_Id	NUMERIC OUTPUT
,@Cmp_ID	NUMERIC(18, 0)
,@AD_Name	VARCHAR(50)
,@Month		int
,@Year		int
,@Amount_Perc	numeric(18,2)
,@Comment	VARCHAR(Max)
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= ''
,@Log_Status Int = 0 Output
,@Row_No Int
,@GUID  Varchar(2000) = '' --Added by nilesh patel on 16062016

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
declare @AD_ID numeric(18,0)
declare @Def_ID numeric(18,0)

if @Comment = NULL
	Set @Comment = ''

	BEGIN
		if not exists(select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where upper(AD_SORT_NAME) = upper(@AD_Name) and Cmp_id = @Cmp_id)
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Allowance Short Name not Exists',0,'Enter Proper Allowance Short Name',GetDate(),'Production Bonus Import',@GUID)						
				SET @Log_Status=1			
				return
			End
		ELSE
			BEGIN
				select @AD_ID=AD_ID,@Def_ID=AD_DEF_ID from T0050_AD_MASTER WITH (NOLOCK) where upper(AD_SORT_NAME) = upper(@AD_Name) and Cmp_id = @Cmp_id	
			END
		
		if @Month is null or @Month = 0
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Month Details not Exists',0,'Enter Proper Month Details',GetDate(),'Production Bonus Import',@GUID)						
				SET @Log_Status=1			
				return
			End
		
		if @Year is null or @Year = 0
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Year Details not Exists',0,'Enter Proper Year Details',GetDate(),'Production Bonus Import',@GUID)						
				SET @Log_Status=1			
				return
			End
		
		IF not (@Def_ID= 20 or @Def_ID=21)
			Begin		
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Allowance not Exists in Allowance Deduction Master with Production Bonus/Variable Def ID',0,'Allowance not Exists with Production Bonus/Variable Def ID',GetDate(),'Production Bonus Import',@GUID)						
				SET @Log_Status=1			
				return
			End	
		ELSE IF exists(select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_ID = @AD_ID and  AD_DEF_ID=21 and Cmp_id = @Cmp_id)
			Begin
				IF not (@Amount_Perc >= 0 and @Amount_Perc <= 100)
					BEGIN
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Enter proper Percentage value to import allowance Production Variable',0,'Enter proper Percentage value for allowance',GetDate(),'Production Bonus Import',@GUID)						
						SET @Log_Status=1			
						return
					END
			End			
		
		if exists(select 1 from T0190_Production_Bonus_Variable_Import WITH (NOLOCK) where Cmp_id = @Cmp_id AND AD_ID=@AD_ID and [Month] =@Month and [year] =@Year) 
			begin
				update T0190_Production_Bonus_Variable_Import set Amount_Perc=@Amount_Perc 
				where Cmp_id = @Cmp_id AND AD_ID=@AD_ID and [Month] =@Month and [year] =@Year		
			end
		ELSE
			BEGIN	
				select @Tran_Id = isnull(max(Tran_Id),0) + 1  from T0190_Production_Bonus_Variable_Import WITH (NOLOCK)
			
				insert into T0190_Production_Bonus_Variable_Import (Tran_ID,Cmp_ID,AD_ID,[Month],[Year],Amount_Perc,Comment,System_date,[User_ID],IP_Address)
				Values(@Tran_Id,@Cmp_ID,@AD_ID,@Month,@Year,@Amount_Perc,@Comment,GETDATE(),@User_Id,@IP_Address)
			END	
	END		

RETURN




