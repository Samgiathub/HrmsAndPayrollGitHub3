

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_Update_Reporting_Manager]	
	@cmp_id numeric(18)
   ,@Alpha_Emp_Code	varchar(100)	
   ,@Current_Sup_Code varchar(100)
   ,@New_Sup_Code varchar(100)
   ,@Effect_Date datetime = NULL         --- jimit 28012015
   ,@Company_Name_Of_New_Manager varchar(100) = NULL
   ,@GUID Varchar(2000) = '' --Added by nilesh patel on 17062016
   
 AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @Emp_id numeric
	declare @Current_Sup_id numeric
	declare @New_Sup_id numeric
	declare @New_Cmp_id numeric
	
	
	set @Emp_id = 0
	set @Current_Sup_id = 0
	set @New_Sup_id = 0
	
	IF @Company_Name_Of_New_Manager = ''
		SET @Company_Name_Of_New_Manager = NULL
		
	IF @Effect_Date IS NULL
		SET @Effect_Date = GETDATE()

		
	     --select @Emp_id= emp_id  from T0080_EMP_MASTER where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
	
	IF(@CURRENT_SUP_CODE <> '')   -- Added By Rajput on 07/04/2017 , As it was not allowing to Import if Current_Sup_Code  is Blank.
		BEGIN
			SELECT @CURRENT_SUP_ID= EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE ALPHA_EMP_CODE = @CURRENT_SUP_CODE AND CMP_ID = @CMP_ID
			IF ISNULL(@CURRENT_SUP_ID,0) = 0
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Superior Code Does Not Exists.',GETDATE(),'Employee Superior Code Does Not Exists.',GETDATE(),'Reporting Manager',@GUID)  
					RETURN
				END
		 END
		 
	if @Effect_Date IS NULL or @Effect_Date = ''
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Effective Date Does Not Exists.',GETDATE(),'Effective Date Does Not Exists.',GETDATE(),'Reporting Manager',@GUID)  
			Return
		End
		
	--select @New_Sup_id= emp_id from T0080_EMP_MASTER where Alpha_Emp_Code = @New_Sup_Code and Cmp_ID = @cmp_id
	
	--if not isnull(@New_Sup_id,0) = 0
	--	begin
			
	--		update T0080_EMP_MASTER set Emp_Superior = @New_Sup_id where Emp_ID = @Emp_id and Emp_Superior = @Current_Sup_id and Cmp_ID = @cmp_id
			
	--		update T0090_EMP_REPORTING_DETAIL set R_Emp_ID = @New_Sup_id where Emp_ID = @Emp_id and r_emp_id = @Current_Sup_id and Cmp_ID = @cmp_id
									
	--		INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
	--						  ( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
	--		VALUES     (@Emp_id,@Current_Sup_id,@New_Sup_id,@cmp_id,'Import')
	--	end
	if @Company_Name_Of_New_Manager is null
		Begin     
		
			SELECT @Emp_id = emp_id --,@Current_Sup_id = Emp_Superior 
			FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
			
			SELECT @New_Sup_id = emp_id 
			FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @New_Sup_Code and Cmp_ID = @cmp_id
			
			if isnull(@Emp_id,0) = 0 --Mukti(07042017)
				Begin
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Does Not Exists.',GETDATE(),'Enter Proper Employee code.',GETDATE(),'Reporting Manager',@GUID)  
					Return
				End
				
			if isnull(@New_Sup_id,0) = 0
				Begin
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'New Manager Does Not Exists.',GETDATE(),'New Manager Does Not Exists.',GETDATE(),'Reporting Manager',@GUID)  
					Return
				End
			
			if not isnull(@New_Sup_id,0) = 0
				begin
				
				
				
					update T0080_EMP_MASTER set Emp_Superior = @New_Sup_id where Emp_ID = @Emp_id and Cmp_ID = @cmp_id
					
					if exists (select 1 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_id AND R_Emp_ID = @Current_Sup_id )
						begin
							update T0090_EMP_REPORTING_DETAIL set R_Emp_ID = @New_Sup_id ,Effect_Date = @Effect_Date where Emp_ID = @Emp_id and r_emp_id = @Current_Sup_id and Cmp_ID = @cmp_id   --jimit 28012015
						end
					else
					
						begin
							declare @row_id as numeric
							 exec P0090_EMP_REPORTING_DETAIL @row_id output,@Emp_ID,@Cmp_ID,'Supervisor',@New_Sup_id,'Direct','I',0,0,'',@Effect_date
							 
							
						end
						
						 INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
									  ( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
							VALUES     (@Emp_id,isnull(@Current_Sup_id,0),@New_Sup_id,@cmp_id,'Import')
					
				end
		End
	Else
		Begin
		
			select @Emp_id= emp_id --,@Current_Sup_id = Emp_Superior 
			from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
			Select @New_Cmp_id = Cmp_Id From T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Name = @Company_Name_Of_New_Manager
			select @New_Sup_id= emp_id from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @New_Sup_Code and Cmp_ID = @New_Cmp_id
			
			if isnull(@Emp_id,0) = 0 --Mukti(07042017)
				Begin
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Does Not Exists.',GETDATE(),'Enter Proper Employee code.',GETDATE(),'Reporting Manager',@GUID)  
					Return
				End
				
			if isnull(@New_Cmp_id,0) = 0
			begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Company Name Does Not Exists.',GETDATE(),'Company Name Does Not Exists.',GETDATE(),'Reporting Manager',@GUID)  
				raiserror('Company Not Exist',16,2);
				return -1	
			end
			
			if isnull(@New_Sup_id,0) = 0
				Begin
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'New Manager Does Not Exists.',GETDATE(),'New Manager Does Not Exists.',GETDATE(),'Reporting Manager',@GUID)  
					Return
				End
			
			if not isnull(@New_Sup_id,0) = 0
				begin
				
					update T0080_EMP_MASTER set Emp_Superior = @New_Sup_id where Emp_ID = @Emp_id and Cmp_ID = @cmp_id
					
					if exists (select 1 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_id AND R_Emp_ID = @Current_Sup_id)
						begin
							if (@New_Cmp_id=@cmp_id)
								Begin  
									update T0090_EMP_REPORTING_DETAIL set R_Emp_ID = @New_Sup_id,Effect_Date = @Effect_Date,Reporting_Method='Direct' where Emp_ID = @Emp_id and r_emp_id = @Current_Sup_id and Cmp_ID = @cmp_id
								End	
							Else
								Begin
									update T0090_EMP_REPORTING_DETAIL set R_Emp_ID = @New_Sup_id,Effect_Date = @Effect_Date,Reporting_Method='InDirect' where Emp_ID = @Emp_id and r_emp_id = @Current_Sup_id and Cmp_ID = @cmp_id
								End								
							end
						--Added InDirect by Sumit Problem Occur in Samarth 05012016
					else
						begin
							declare @row_id_1 as numeric
							
							 --exec P0090_EMP_REPORTING_DETAIL @row_id_1 output,@Emp_ID,@Cmp_ID,'Supervisor',@New_Sup_id,'Direct','I',0
							  --exec P0090_EMP_REPORTING_DETAIL @row_id output,@Emp_ID,@Cmp_ID,'Supervisor',@New_Sup_id,'Direct','I',0,0,'',@Effect_date
							if (@New_Cmp_id=@cmp_id)
								Begin  
									exec P0090_EMP_REPORTING_DETAIL @row_id output,@Emp_ID,@Cmp_ID,'Supervisor',@New_Sup_id,'Direct','I',0,0,'',@Effect_date									
								End
							Else
								Begin
									exec P0090_EMP_REPORTING_DETAIL @row_id output,@Emp_ID,@Cmp_ID,'Supervisor',@New_Sup_id,'InDirect','I',0,0,'',@Effect_date									
								End	
							--Added InDirect by Sumit Problem Occur in Samarth 05012016
						end
						 INSERT INTO T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY
									  ( Emp_id, Old_R_Emp_id, New_R_Emp_id, Cmp_id,  Comment)
							VALUES     (@Emp_id,isnull(@Current_Sup_id,0),@New_Sup_id,@cmp_id,'Import')
					
				end
		End 
RETURN




