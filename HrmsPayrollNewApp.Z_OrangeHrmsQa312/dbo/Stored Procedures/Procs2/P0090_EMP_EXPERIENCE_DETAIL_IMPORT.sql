
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_EXPERIENCE_DETAIL_IMPORT]
		 @Row_ID numeric(18,0) output
		,@Alpha_Emp_Code varchar(100)
		,@Cmp_ID numeric(18,0)
		,@Employer_Name varchar(100)
		,@Desig_Name varchar(100)
		,@St_Date datetime
		,@End_Date datetime	
		,@CTC_Amount numeric(18,0) = 0		
		,@Gross_Salary numeric(18,0) = 0	
		,@Exp_Remarks  nvarchar(500) = ''	
		,@Industry_Type varchar(150) = '' --added by jimit 21032017	
		,@tran_type varchar(1)
		,@GUID		Varchar(2000) = '' --Added by nilesh patel on 17062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Emp_Id Numeric
Set @Emp_id = 0
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
		

if @St_Date = ''  
  SET @St_Date  = NULL
if @End_Date = ''  
  SET @End_Date  = NULL
If @CTC_Amount = 0
	Set @CTC_Amount = NULL

If @Gross_Salary = 0
	Set @Gross_Salary = NULL

If @Exp_Remarks = ''
	Set @Exp_Remarks = NULL

	If @Industry_Type = ''        --added by aswini 2/11/2023
	Set @Industry_Type = NULL

if @Employer_Name = '' 
	Set @Employer_Name = NULL
	
	if isnull(@Emp_id,0) = 0
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Employee Code Does Not Exists.',GETDATE(),'Verify Employee Code With Employee Master',GetDate(),'Experience Import',@GUID)
			return
		End
	

	
	if @Employer_Name is null
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Please Enter valid Employer Name.',GETDATE(),'Please Enter valid Employer Name',GetDate(),'Experience Import',@GUID)
			return
		End
		
	if @Desig_Name IS NULL or @Desig_Name = ''
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Designation Details.',GETDATE(),'Enter Designation Details',GetDate(),'Experience Import',@GUID)
			return
		End
		
	if @St_Date IS NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Exp.Start Date.',GETDATE(),'Enter Start Date Details',GetDate(),'Experience Import',@GUID)
			return
		End
	--Added By Jimit 14032019
	if @St_Date > getdate()
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Fuuter Date is not allow as Exp.Start Date.',GETDATE(),'Enter Valid Exp.Start Date.',GetDate(),'Experience Import',@GUID)
			return
		End
	--Ended
	if @End_Date IS NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Exp.Start Date.',GETDATE(),'Enter Start Date Details',GetDate(),'Experience Import',@GUID)
			return
		End	
		
	if @St_Date > @End_Date
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Start Date Should be less than End Date.',GETDATE(),'Enter Start Date Should be less than End Date',GetDate(),'Experience Import',@GUID)
			return
		End
	
	if @CTC_Amount Is NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Valid CTC Amount.',GETDATE(),'Enter Valid CTC Amount',GetDate(),'Experience Import',@GUID)
			return
		End
		
	if @Gross_Salary Is Null
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Valid Gross Salary.',GETDATE(),'Enter Valid Gross Salary',GetDate(),'Experience Import',@GUID)
			return
		End
	
	if @Exp_Remarks is null
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Valid Remarks details.',GETDATE(),'Enter Valid Remarks details',GetDate(),'Experience Import',@GUID)
			return
		End
if @Industry_Type is null   --added by aswini 2/11/2023
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@alpha_Emp_Code,'Enter Valid Industry Type.',GETDATE(),'Enter Valid Industry Type',GetDate(),'Experience Import',@GUID)
			return
		End



	-- Added by rohit For update if Same entry is Inserted on 08-apr-2014	
	if  exists(select row_id from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Emp_ID=@Emp_ID and UPPER(Employer_Name)=UPPER(@Employer_Name) and St_Date=@St_Date and End_Date=@End_Date)
	BEGIN
		select @Row_ID = row_id from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Emp_ID=@Emp_ID and UPPER(Employer_Name)=UPPER(@Employer_Name) and St_Date=@St_Date and End_Date=@End_Date
		set @tran_type='u'
	END
	
	-- Ended by rohit For update if Same entry is Inserted on 08-apr-2014	

	If @tran_type ='I'
		
 		Begin
			If Exists(select  Row_ID from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Employer_Name=@Employer_Name and Desig_Name=@Desig_Name and St_Date=@St_Date and End_Date=@End_Date and CTC_Amount = @CTC_Amount and Gross_Salary = @Gross_Salary and Exp_Remarks = @Exp_Remarks and Cmp_ID = @Cmp_ID and upper(IndustryType) = Upper(@Industry_Type))
					Begin 
						set @Row_ID = 0
						Return
					End
					
				select @Row_ID = isnull(max(Row_ID),0)+1 from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_EXPERIENCE_DETAIL
						(Row_ID ,Emp_ID ,Cmp_ID ,Employer_Name ,Desig_Name ,St_Date ,End_Date,CTC_Amount,Gross_Salary ,Exp_Remarks,IndustryType)
				VALUES	(@Row_ID ,@Emp_ID ,@Cmp_ID ,@Employer_Name ,@Desig_Name ,@St_Date ,@End_Date ,@CTC_Amount,@Gross_Salary,@Exp_Remarks,@Industry_Type)	
		End
	else if @tran_type ='u' 
				begin
					UPDATE    T0090_EMP_EXPERIENCE_DETAIL
					SET			Cmp_ID = @Cmp_ID, Employer_Name = @Employer_Name, Desig_Name = @Desig_Name, 
								St_Date = @St_Date, End_Date = @End_Date, CTC_Amount = @CTC_Amount,
								Gross_Salary = @Gross_Salary, Exp_Remarks = @Exp_Remarks,
								IndustryType = @Industry_Type	
					where Emp_ID = @Emp_ID and Row_ID = @Row_ID
					
					insert into T0090_EMP_EXPERIENCE_DETAIL_Clone(
						 Row_ID 
						,Emp_ID 
		                ,Cmp_ID 
		                ,Employer_Name 
		                ,Desig_Name 
		                ,St_Date 
		                ,End_Date
		                ,System_Date
		                ,Login_Id
		                ,CTC_Amount
		                ,Gross_Salary
		                ,Exp_Remarks
						,IndustryType
						)
				 values(
						 @Row_ID 
						,@Emp_ID 
		                ,@Cmp_ID 
		                ,@Employer_Name 
		                ,@Desig_Name 
		                ,@St_Date 
		                ,@End_Date
		                ,GETDATE()
		                ,0
		                ,@CTC_Amount
		                ,@Gross_Salary
		                ,@Exp_Remarks
		                ,@Industry_Type
		               )		
					
				end
RETURN




