
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0095_LEAVE_Credit_IMPORT_Bkp_09012024_Deepali]
 @Alpha_Emp_Code as varchar(50)
 ,@CMP_ID as numeric
 ,@LEAVE_NAME as varchar(50)
 ,@LEAVE_Credit_DAYS as numeric(18,2)
 ,@FOR_DATE  as datetime
 ,@Log_Status Int = 0 Output
 ,@Row_No int = 0
 ,@GUID Varchar(2000) = '' --Added by nilesh patel on 14062016
 ,@Credit_Type nvarchar(25) = 'Import' --Added by Sumit on 29092016
  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
				
		DECLARE @LEAVE_ID NUMERIC(18,0)
		DECLARE @LEAVE_CF_ID NUMERIC(18,0)
		DECLARE @EMP_ID NUMERIC(18,0)
		DECLARE @TRAN_TYPE Varchar(1)
		declare @EMP_CODE nvarchar(100)
		
		Declare @CF_From_Date DateTime
		declare @CF_To_Date DateTime
		
		DECLARE @Leave_Type as VARCHAR(30)
		DECLARE @Gender as VARCHAR(10)
		
		SET @LEAVE_CF_ID=0
		SET @EMP_ID =0
						
 		set @CF_From_Date= DATEADD(dd,-(DAY(@FOR_DATE)-1),@FOR_DATE)
		set @CF_To_Date = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@FOR_DATE)+1,0))



		SELECT @EMP_ID=EMP_ID , @EMP_CODE = Emp_code 
				,@Gender = Gender
		FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Alpha_Emp_Code And cmp_Id=@Cmp_Id
		
		SELECT @LEAVE_ID=LEAVE_ID 
				,@Leave_Type = Leave_Type
		FROM t0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_Name =@LEAVE_NAME And cmp_Id=@Cmp_Id
		
		if isnull(@EMP_CODE,'')=''
			set @EMP_CODE = @Alpha_Emp_Code
		
		If @Leave_Id Is Null
			Set @Leave_Id = 0
		
		IF @Emp_id is null
			Set @Emp_id = 0
		
		
		
		------Added By Jimit 05012018------
		If (@Leave_Type = 'Maternity Leave' and @Gender = 'M') or (@Leave_Type = 'Paternity Leave' and @Gender = 'F')
			BEGIN
					If @Gender = 'M'
						SET @Gender = 'Male'
					ELSE IF @Gender = 'F'
						SET @Gender = 'Female'
		
					 SET @Log_Status=1
					 Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Gender + '  Employee can not Apply for '  + @Leave_Name ,@Leave_Name,'Invalid Leave',GetDate(),'Leave Approval',@GUID)		
					 return		
			END
	
	------ended------
		--Added by Jaina 16-05-2018
		if @Leave_Type = 'Paternity Leave'
		BEGIN
			SET @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Gender + '  Employee can not Apply for '  + @Leave_Name,@Leave_Name,'Invalid Leave',GetDate(),'Leave Credit',@GUID)		
			return		
		end
		
		
		if @Leave_Id =0
		begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Leave Doesn''t exists',@LEAVE_NAME,'Enter proper Leave Name',GetDate(),'Leave Credit',@GUID)
			return
		end
    
		if @Emp_Id =0
		begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE ,'Enter proper Employee Code',GetDate(),'Leave Credit',@GUID)			
			return
			
		end	
		
		if @FOR_DATE is null
			Begin
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'For Date is invalid',@EMP_CODE ,'Enter Valid For Date',GetDate(),'Leave Credit',@GUID)			
				return
			End
		
		if @LEAVE_Credit_DAYS = 0
			Begin
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Enter Valid Credit Days',@EMP_CODE ,'Enter Valid Credit Days',GetDate(),'Leave Credit',@GUID)			
				return
			End 	

		--If Exists(Select Emp_ID From T0100_LEAVE_CF_DETAIL  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CONVERT(VARCHAR(25),CF_From_Date,101)=CONVERT(VARCHAR(25),@CF_From_Date,101) and CONVERT(VARCHAR(25),CF_To_Date,101) = CONVERT(VARCHAR(25),@CF_To_Date,101) and Leave_ID =@LEAVE_ID)
		If Exists(Select Emp_ID From T0100_LEAVE_CF_DETAIL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CF_From_Date = @FOR_DATE and Leave_ID =@LEAVE_ID)
		begin
			set @tran_type = 'U'
		end
		else
		begin
			set @tran_type = 'I'
		end
		BEGIN TRY		-- BEGIN TRY CATCH ADDED BY GADRIWALA 23012014 
		
		IF @TRAN_TYPE = 'I'
			BEGIN
							
					select @Leave_CF_ID = Isnull(max(Leave_CF_ID),0) + 1 	From T0100_LEAVE_CF_DETAIL WITH (NOLOCK)
					
					INSERT INTO T0100_LEAVE_CF_DETAIL
											  (Leave_CF_ID
												,Cmp_ID
												,Emp_ID
												,Leave_ID
												,CF_For_Date
												,CF_From_Date
												,CF_To_Date
												,CF_P_Days
												,CF_Leave_Days
												,CF_Type
											)
						VALUES     (	@Leave_CF_ID
										,@Cmp_ID
										,@Emp_ID
										,@Leave_ID
										--,@CF_To_Date
										,@FOR_DATE	--Ankit 28072014	
										,@CF_From_Date
										,@CF_To_Date
										,0.00
										,@LEAVE_Credit_DAYS
										,@Credit_Type
									)
			END
		Else If @Tran_Type = 'U'
		begin
				
				Update T0100_LEAVE_CF_DETAIL
							set 
							CF_Leave_Days=@LEAVE_Credit_DAYS
							,CF_Type=@Credit_Type
						Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CONVERT(VARCHAR(25),CF_From_Date,101)=CONVERT(VARCHAR(25),@CF_From_Date,101) and CONVERT(VARCHAR(25),CF_To_Date,101) = CONVERT(VARCHAR(25),@CF_To_Date,101) and Leave_ID =@LEAVE_ID
		end
			
		END TRY
		BEGIN CATCH   -- BEGIN TRY CATCH ADDED BY GADRIWALA 23012014 
				set @Log_Status = 1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE(),@For_Date,'Enter proper Leave Credit',GetDate(),'Leave Credit','')
				
		END CATCH;
		-- Commented By Gadriwala 23012014
		--if Exists(Select Im_Id from T0080_Import_Log where month(for_date) = month(getdate()) and year(for_date) = year(getdate()) )
		--	begin 
		--		set @Log_Status = 1
		--	end
		
RETURN




