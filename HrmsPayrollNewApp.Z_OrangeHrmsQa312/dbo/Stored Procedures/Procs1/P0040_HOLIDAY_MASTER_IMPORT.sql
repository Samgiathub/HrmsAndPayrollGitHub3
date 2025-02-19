

-- =============================================
-- Author:		<Jaina>
-- Create date: <18-01-2018>
-- Description:	<Holiday Import>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HOLIDAY_MASTER_IMPORT]
	@Holiday_Id as numeric(18,0) output,
	@Cmp_Id as numeric(18,0),
	@Holiday_Name as varchar(500),	
	@Branch_Name as varchar(500),
	@From_Date as datetime,
	@To_Date as datetime,
	@Holiday_Category as varchar(50) = 'National',
	@Repeat_Annually as varchar(10),
	@Half_Day as varchar(10),
	@Present_Complusary as varchar(10),
	@Optional_Holiday as varchar(10),
	@Approval_Max_Limit as varchar(10),
	@Unpaid_Holiday as varchar(10),
	@Log_Status Int = 0 Output,  
	@Row_No as Int, 
	@GUID as Varchar(2000) = '',
	@User_Id as numeric
	 

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	Declare @Is_Fix char(1)
	Declare @Branch_Id varchar(max) = 'All'
	Declare @Is_Half_day tinyint
	declare @Is_P_Comp tinyint
	declare @Is_National tinyint
	declare @Is_Optional tinyint
	declare @Branch_Limit varchar(max) = ''
	declare @Setting_Value Bit = 0
	declare @Multiple_Holiday tinyint 
	
	if @To_Date  = '01-01-1900'
		set @To_Date = @From_date
		
	if @From_Date > @To_Date 
	begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Dates is not proper Inserted',0,'Enter Proper From/To Date',GetDate(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	end
	
	If @Holiday_Name = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Holiday Name is not Inserted',0,'Enter Proper Holiday Name',GetDate(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	If @Branch_Name = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Branch Name is not Inserted',0,'Enter Proper Branch Name',GetDate(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	IF @From_Date = ''
	Begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'From date is not Inserted',0,'Enter From Date',GetDate(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	ENd
	
	IF 	@Branch_Name <> 'All'
	begin
		if not exists (SELECT 1 FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id and Branch_Name = @Branch_Name)
		BEGIN
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Branch Name Not Exists',0,'Enter Proper Branch Name',GETDATE(),'Holiday Master Import',@GUID)						
			SET @LOG_STATUS=1			
			RETURN
		END
	END
	--Added by Jaina 06-04-2018
	If ISNUMERIC(@Approval_Max_Limit) = 0
	begin
		
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Approval Max Limit Not Proper',0,'Enter Proper Approval Max Limit',GETDATE(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
		
	end
	if ISDATE(@From_Date) = 0 or isdate(@To_Date) = 0
	BEGIN
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Date is Not Proper',0,'Enter Proper date',GETDATE(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	End
	
	if @Repeat_Annually = 'Yes'
		set @Is_Fix = 'Y'
	else
		set @Is_Fix = 'N'
		
	IF @Half_Day = 'Yes'
		set @Is_Half_day = 1
	else
		set @Is_Half_day = 0
		
	if @Holiday_Category = 'National'
		set @Is_National = 0
	else
		set @Is_National = 1
	
	if @Optional_Holiday = 'Yes'
		set @Is_Optional = 1
	else
		set @Is_Optional = 0
		
	IF @Is_Optional = 1  --If Optional Holiday than repeat Annually not allowed.
		set @Is_Fix = 'N'
	
	IF @Present_Complusary = 'Yes'  --Added by Jaina 06-04-2018
		set @Is_P_Comp = 1
	else
		set @Is_P_Comp = 0
		
	IF Datediff(dd,@From_date,@To_date) > 1
		set @Multiple_Holiday = 1
	else
		set @Multiple_Holiday = 0
		
	If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID=@Cmp_ID And 					
					((@From_Date >= Month_St_Date and @From_Date <= Month_End_Date) or 
					(@To_Date >= Month_St_Date and 	@To_Date <= Month_End_Date) or 
					(Month_St_Date >= @From_Date and Month_St_Date <= @To_Date) or
					(Month_End_Date >= @From_Date and Month_End_Date <= @To_Date)))
	Begin
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'This Months Salary Exists',0,'This Months Salary Exists',GETDATE(),'Holiday Master Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN		
	End
	
	IF 	@Branch_Name = 'All'
		BEGIN	
			--set @Branch_Id = 'All'	
			set @Branch_Id = null	
			SELECT	@Branch_Id = COALESCE(@Branch_Id + '#', '') + CAST(Branch_ID AS VARCHAR(6))  
			FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
			WHERE	Cmp_ID=@Cmp_ID 		
			
			--select @Branch_Id		
			
			--IF @Is_Optional  = 1
			--	BEGIN	
			--		SELECT  @Branch_Limit = COALESCE(@Branch_Limit + ',', '') + CAST(Branch_ID AS VARCHAR(5)) + ':' + @Approval_Max_Limit  
			--		FROM	T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 									
			--	ENd
			
		END
	else	
		SELECT @Branch_Id = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_Name = @Branch_Name and Cmp_ID = @Cmp_Id
		
		
	IF 	@Branch_Id <> 'All'
		begin
			--if @Is_Optional  = 1
			--	set @Branch_Limit =','+ @Branch_Id + ':'+@Approval_Max_Limit
			--Added by Jaina 17-12-2018
			SELECT  @Branch_Limit = COALESCE(@Branch_Limit + ',', '') + CAST(Branch_ID AS VARCHAR(5)) + ':' + @Approval_Max_Limit  
			FROM	T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 	
		END
	
	declare @Is_Unpaid_Holiday as Int
	if @Unpaid_Holiday = 'Yes'	
		set @Is_Unpaid_Holiday = 1
	else
		set @Is_Unpaid_Holiday = 0
		
	IF Datediff(dd,@From_date,@To_date) > 1
		set @Multiple_Holiday = 1
	else
		set @Multiple_Holiday = 0
	
	SELECT @Setting_Value = ISNULL(Setting_Value,0) FROM T0040_SETTING WITH (NOLOCK) WHERE Setting_Name='Show Gradewise Salary Textbox in Grade Master' AND Cmp_ID = @Cmp_id
	if @Setting_Value = 1		
		set @Unpaid_Holiday = @Is_Unpaid_Holiday	
	else	
		set @Unpaid_Holiday = 0
	
	
	exec P0040_HOLIDAY_MASTER @Hday_ID = @Holiday_Id,@cmp_Id= @cmp_Id,@Hday_Name=@Holiday_Name,@H_From_Date=@From_Date,
							@H_To_Date = @To_Date,@Is_Fix = @Is_Fix,@Hday_Ot_setting = 0,@Branch_ID = @Branch_Id,
							@tran_type = 'I',@Is_Half = @Is_Half_day,@Is_P_Comp = @Is_P_Comp,@Message_Text = '',@Sms = 0,
							@is_National_Holiday=@Is_National,@User_Id=0,@IP_Address='',@Is_Optional=@Is_Optional
							,@Multiple_Holiday = @Multiple_Holiday,@Is_Unpaid_Holiday = @Is_Unpaid_Holiday,@Branch_Limit=@Branch_Limit
    
    	
END

