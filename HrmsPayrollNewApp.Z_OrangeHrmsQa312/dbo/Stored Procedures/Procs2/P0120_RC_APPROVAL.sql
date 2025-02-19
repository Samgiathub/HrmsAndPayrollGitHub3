


CREATE PROCEDURE [dbo].[P0120_RC_APPROVAL]  
    @RC_APR_ID	numeric(18,0) output
	,@Cmp_ID	numeric(18,0)
	,@RC_APP_ID	numeric(18,0)
	,@Emp_ID	numeric(18,0)
	,@RC_ID	numeric(18,0)
	,@Apr_Date	Datetime
	,@Apr_Amount	numeric(18,2)
	,@Tax_Exemption_Amount	numeric(18,2)
	,@APr_Comments	nvarchar(max)
	,@APR_Status	tinyint
	,@RC_Apr_Effect_In_Salary	numeric(18,2)
	,@RC_Apr_Cheque_No	varchar(10)
	,@Payment_Mode	varchar(20)
	,@CreateBy	Int
	,@DateCreated	DateTime
	,@ModifyBy	Int
	,@ModifyDate	DateTime
	,@Trans_Type Char(1)
	,@Is_Manager tinyint
	,@Leave_From DateTime
	,@Leave_To datetime
	,@FY  varchar(255)
	,@Taxable int
	,@FileName varchar(255)
	,@S_emp_ID numeric(18,0) --Ripal 28Oct2013
	,@Payment_date Datetime
	,@Direct_Approval tinyint = 0 --Ripal 24Jun2014
	,@Final_Approver  Integer = 0	--Ankit 26062014
	,@Is_Fwd_Leave_Rej Integer = 0	--Ankit 26062014
	,@Rpt_Level tinyint = 0			--Ankit 26062014
	,@Quarter_ID tinyint = 0
	,@Quarter_Name Varchar(50) = ''
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
	,@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS  

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
-- Add By Mukti 11072016(end)	


IF @Trans_Type ='I'
BEGIN

	--Ripal 03Jan2014 Start ---
	If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And 
						@Payment_date >= Month_St_Date and @Payment_date <= Month_End_Date And ISNULL(@RC_Apr_Effect_In_Salary,0)=1)
		Begin
			Raiserror('@@This Months Salary Exists.So You Cant Add/Update This Record.@@',16,2)
			return -1
		End
	--Ripal 03Jan2014 End ---
	---Ripal 11July2014 Start
	Declare @St_date as DateTime
	Declare @End_Date as DateTime
	Declare @App_Date as Datetime
	select @App_Date = App_Date from T0100_RC_Application WITH (NOLOCK) where RC_APP_ID = @RC_APP_ID and Cmp_ID = @Cmp_ID
	if @RC_APP_ID = 0  --Ripal 07Nov2014
		Begin
			set @App_Date  = @Apr_Date
		End
	If month(@App_Date) >= 4  -- Added By Ripal 15July2014
	Begin
		set @St_date =  '01/April/'+cast(YEAR(@App_Date) as varchar(4)) 
		set @End_Date = '31/March/'+cast( (YEAR(@App_Date)+1) as varchar(4)) 
	End
	Else
	Begin
		set @St_date =  '01/April/'+cast( (YEAR(@App_Date)-1) as varchar(4)) 
		set @End_Date = '31/March/'+cast(YEAR(@App_Date) as varchar(4))
	End

	declare @Taxable_limit as decimal
	declare @Non_Taxable_limit as decimal
	declare @Taxable_Count as decimal   
	declare @Non_Taxable_Count as decimal	  
	set @Taxable_limit =0.0
	set @Non_Taxable_limit =0.0
	set @Taxable_Count =0
	set @Non_Taxable_Count =0
	
	select @Taxable_limit = Taxable_limit,@Non_Taxable_limit =Non_Taxable_limit
					from t0040_ReimClaim_Setting WITH (NOLOCK) where AD_ID = @RC_ID and cmp_ID=@Cmp_ID
				
	--Some Change by Ripal 11July 2014 Start
		select @Taxable_Count =COUNT(*) 
		From T0100_RC_Application A WITH (NOLOCK)
		Where  APP_Date BETWEEN @St_date and @End_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
		isnull(A.Tax_Exception,0) = 0 and RC_ID = @RC_ID							
			
		select @Non_Taxable_Count =COUNT(*) 
		From T0100_RC_Application A WITH (NOLOCK)
		Where  APP_Date BETWEEN @St_date and @End_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
		isnull(A.Tax_Exception,0) = 1 and RC_ID = @RC_ID
			
		if isnull(@Taxable,0) = 1
	     begin
			if isnull(@Non_Taxable_limit,0) <> 0
				begin				    			   			 					
					IF @Non_Taxable_limit <= @Non_Taxable_Count
						BEGIN							
							Raiserror('@@Tax free application is exceed in year.@@',16,2)				
							Return -1
						end
				End		
		end
		Else
		Begin
			if isnull(@Taxable_limit,0) <> 0
				begin
					IF   @Taxable_limit <= @Taxable_Count
						BEGIN					
							Raiserror('@@Taxable application is exceed in year@@',16,2)				
							Return -1				
						End
				End
		End
	--Some Change by Ripal 11July 2014 End
	---Ripal 11July2014 End
	
	--Ripal 07Nov2014 Start
	Declare @Monthly_Limit as int
    Declare @Monthly_LimitCount as int
	Declare @MnthSt_date as DateTime
	Declare @MnthEnd_Date as DateTime

	set @MnthSt_date = '01/'+ DATENAME(mm,@App_Date) +'/'+ cast(year(@App_Date) as varchar(10))
	set @MnthEnd_Date =Datediff(DD,1,DATEADD(mm, 1, @MnthSt_date))
	select @Monthly_Limit = Monthly_Limit from t0050_Ad_Master WITH (NOLOCK) where  Ad_ID = @RC_ID
	if @Monthly_Limit <> 0
		Begin
			select @Monthly_LimitCount = count(*)
				From T0100_RC_Application A WITH (NOLOCK)
				Where  APP_Date BETWEEN @MnthSt_date and @MnthEnd_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID 
					   AND APP_Status=1 AND RC_ID = @RC_ID
			IF @Monthly_Limit <= @Monthly_LimitCount
				BEGIN							
					Raiserror('@@Application limit is exceed in this month.@@',16,2)				
					Return -1
				end
		End
    --Ripal 07Nov2014 End
	
	--'' Ankit 26062014 --''
	declare @Tran_id as numeric(18,0)
	IF @Direct_Approval = 0
		Begin
		
			IF Exists(Select 1 From T0115_RC_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
			
			select @RC_APR_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Level_Approval WITH (NOLOCK)

					INSERT INTO T0115_RC_Level_Approval(Tran_ID,Cmp_ID,RC_APP_ID,Emp_ID,RC_ID,Apr_Date,Apr_Amount
						,Taxable_Exemption_amount,APr_Comments,APR_Status,RC_Apr_Effect_In_Salary,RC_Apr_Cheque_No,Payment_Mode
						,CreateBy,DateCreated,ModifyBy,ModifyDate,S_emp_ID,Payment_date,Rpt_Level,System_Date,Reim_Quar_ID,Quarter_Name)
					VALUES
						(@RC_APR_ID,@Cmp_ID,@RC_APP_ID,@Emp_ID,@RC_ID,@Apr_Date,@Apr_Amount
						,@Tax_Exemption_Amount,@APr_Comments,@APR_Status,@RC_Apr_Effect_In_Salary,@RC_Apr_Cheque_No,@Payment_Mode
						,@CreateBy,@DateCreated,@ModifyBy,@ModifyDate,@S_emp_ID,@Payment_date,@Rpt_Level,Getdate(),@Quarter_ID,@Quarter_Name)
			
			
		End
		
	IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
	--'' Ankit 26062014 --''
		Begin
			Set @RC_APR_ID  = 0 
			Select @RC_APR_ID = Isnull(max(RC_APR_ID),0) + 1  From T0120_RC_Approval WITH (NOLOCK)

				INSERT INTO T0120_RC_Approval(RC_APR_ID,Cmp_ID,RC_APP_ID,Emp_ID,RC_ID,Apr_Date
				,Apr_Amount,Taxable_Exemption_amount,APr_Comments,APR_Status,RC_Apr_Effect_In_Salary
				,RC_Apr_Cheque_No,Payment_Mode,CreateBy,DateCreated,ModifyBy,ModifyDate,S_emp_ID,
				Payment_date,Direct_Approval,Reim_Quar_ID,Quarter_Name)
									  VALUES(@RC_APR_ID,@Cmp_ID,@RC_APP_ID,@Emp_ID,@RC_ID,@Apr_Date
				,@Apr_Amount,@Tax_Exemption_Amount,@APr_Comments,@APR_Status,@RC_Apr_Effect_In_Salary
				,@RC_Apr_Cheque_No,@Payment_Mode,@CreateBy,@DateCreated,@ModifyBy,@ModifyDate,@S_emp_ID
				,@Payment_date,@Direct_Approval,@Quarter_ID,@Quarter_Name)
			
			IF @Is_Manager = 1
				BEGIN
				exec P0100_RC_Application  @RC_APP_ID output,@Cmp_ID,@Emp_ID,@RC_ID,@Apr_Date,@Apr_Amount,@APr_Comments,@APR_Status,@Leave_From ,@Leave_To,0,@FY,@Taxable,'I',@FileName,@RC_APR_ID,1,@S_emp_ID,@Tax_Exemption_Amount,@Quarter_ID,@Quarter_Name --Ripal 27Aug2014 @Tax_Exemption_Amount
				
				Update T0120_RC_Approval set RC_App_ID = 	@RC_APP_ID where RC_APR_ID =@RC_APR_ID and cmp_ID=@Cmp_ID
			end		
			Else
				Begin
				
				Update T0100_RC_Application set RC_apr_ID=@RC_APR_ID, APP_Status=@APR_Status,FY=@FY where RC_APP_ID=@RC_APP_ID and emp_iD=@emp_ID and cmp_ID=@cmp_ID
			end
			
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table = 'T0120_RC_Approval' ,@key_column='RC_APR_ID',@key_Values=@RC_APR_ID,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
			-- Add By Mukti 11072016(end)		
		End
END
ELSE IF @Trans_Type ='U'
BEGIN
	--Ripal 03Jan2014 Start ---
	If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And 
						@Payment_date >= Month_St_Date and @Payment_date <= Month_End_Date and Isnull(@RC_Apr_Effect_In_Salary,0)=1)
		Begin
			Raiserror('@@This Months Salary Exists.So You Cant Add/Update This Record.@@',16,2)
			return -1
		End
	--Ripal 03Jan2014 End ---

	-- Add By Mukti 11072016(start)
		exec P9999_Audit_get @table='T0120_RC_Approval' ,@key_column='RC_APR_ID',@key_Values=@RC_APR_ID,@String=@String_val output
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
	-- Add By Mukti 11072016(end)
			
   Update T0120_RC_Approval set  Apr_Date = @Apr_Date
			,Apr_Amount = @Apr_Amount
			,Taxable_Exemption_amount = @Tax_Exemption_Amount
			,APr_Comments = @APr_Comments
			,APR_Status = @APR_Status
			,RC_Apr_Effect_In_Salary = @RC_Apr_Effect_In_Salary
			,RC_Apr_Cheque_No  = @RC_Apr_Cheque_No
			,Payment_Mode = @Payment_Mode
			,CreateBy = @CreateBy
			,DateCreated = @DateCreated
			,ModifyBy = @ModifyBy
			,ModifyDate = @ModifyDate
			,Payment_date =@Payment_date
			,Reim_Quar_ID = @Quarter_ID
			,Quarter_Name = @Quarter_Name
	where RC_APR_ID=@RC_APR_ID and cmp_ID=@cmp_ID
	
	Update T0100_RC_Application set RC_apr_ID=@RC_APR_ID, APP_Status=@APR_Status,FileName=@FileName,FY=@FY where RC_APP_ID=@RC_APP_ID and emp_iD=@emp_ID and cmp_ID=@cmp_ID
	
	-- Add By Mukti 11072016(start)
		exec P9999_Audit_get @table = 'T0120_RC_Approval' ,@key_column='RC_APR_ID',@key_Values=@RC_APR_ID,@String=@String_val output
		set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
	-- Add By Mukti 11072016(end) 

END
ELSE IF @Trans_Type ='D'
BEGIN
	
	--''Ankit 26062014
	declare @Rm_emp_id as numeric(18,0)
	set @Rm_emp_id = 0
	set @Tran_id = 0
	
	Select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID,@Rpt_Level = Rpt_Level from T0115_RC_Level_Approval WITH (NOLOCK) where  RC_APP_ID=@RC_App_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_RC_Level_Approval WITH (NOLOCK) where RC_APP_ID=@RC_App_ID )
	
	If @Rm_emp_id = @S_Emp_ID 
		Begin		
			-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@Tran_id,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
			
			--Added by Ripal 22Aug2014 start
			Delete from T0110_RC_Reimbursement_Detail Where RC_APP_ID = @RC_APP_ID and 
							RC_Reim_ID not in (select RC_Reim_ID from T0115_RC_Reimbursement_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id) 
			Delete from T0115_RC_Reimbursement_Detail_Level Where RC_LevelTran_ID = @Tran_id
			--Added by Ripal 22Aug2014 End
			--Added by Ripal 25Aug2014 start
			Delete from T0110_RC_Dependant_Detail where RC_APP_ID = @RC_APP_ID And
							RC_Dependent_ID not in(select RC_Dependent_ID from T0115_RC_Dependant_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id)
			Delete from T0115_RC_Dependant_Detail_Level Where RC_LevelTran_ID = @Tran_id
			--Added by Ripal 25Aug2014 End
			--Added by Ripal 26Aug2014 start
			Delete from T0110_RC_LTA_Travel_Detail where RC_APP_ID = @RC_APP_ID And
							RC_Travel_ID not in(select RC_Travel_ID from T0115_RC_LTA_Travel_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id)
			Delete from T0115_RC_LTA_Travel_Detail_Level Where RC_LevelTran_ID = @Tran_id
			--Added by Ripal 26Aug2014 End
			Delete T0115_RC_Level_Approval where Tran_ID = @Tran_id and RC_APP_ID=@RC_App_ID
		End
	Else if @S_Emp_ID = 0  --When delete from Admin (Condition Added by Ripal 09July2014)
		Begin	
			-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@Tran_id,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)	
				
			--Added by Ripal 22Aug2014 Start	
			Delete from T0110_RC_Reimbursement_Detail Where RC_APP_ID = @RC_APP_ID and 
							RC_Reim_ID not in (select RC_Reim_ID from T0115_RC_Reimbursement_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id) 
			Delete from T0115_RC_Reimbursement_Detail_Level Where RC_LevelTran_ID in (select Tran_id from T0115_RC_Level_Approval WITH (NOLOCK) where RC_App_ID = @RC_App_ID)
			 --Added by Ripal 22Aug2014 End
			 --Added by Ripal 25Aug2014 start
			Delete from T0110_RC_Dependant_Detail where RC_APP_ID = @RC_APP_ID And
							RC_Dependent_ID not in(select RC_Dependent_ID from T0115_RC_Dependant_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id)
			Delete from T0115_RC_Dependant_Detail_Level Where RC_LevelTran_ID in (select Tran_id from T0115_RC_Level_Approval WITH (NOLOCK) where RC_App_ID = @RC_App_ID)
			--Added by Ripal 25Aug2014 End
			--Added by Ripal 26Aug2014 start			
			Delete from T0110_RC_LTA_Travel_Detail where RC_APP_ID = @RC_APP_ID And
							RC_Travel_ID not in(select RC_Travel_ID from T0115_RC_LTA_Travel_Detail_Level WITH (NOLOCK) Where RC_LevelTran_ID = @Tran_id)
			Delete from T0115_RC_LTA_Travel_Detail_Level Where RC_LevelTran_ID in (select Tran_id from T0115_RC_Level_Approval WITH (NOLOCK) where RC_App_ID = @RC_App_ID)
			--Added by Ripal 26Aug2014 End
			Delete T0115_RC_Level_Approval where RC_App_ID = @RC_App_ID
		End	 
	--''Ankit 26062014	
		
 IF @RC_apr_ID <> 0
  BEGIN		
		Declare @Payment_date1 as datetime
		Select @Payment_date1 = Payment_date , @Emp_ID = Emp_ID from T0120_RC_Approval WITH (NOLOCK) where RC_APR_ID=@RC_APR_ID and cmp_id=@Cmp_ID and isnull(APR_Status,0) =1 and isnull(RC_Apr_Effect_In_Salary,0) =1
		
		if Exists(select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where @Payment_date1 BETWEEN Month_St_Date and Month_End_Date  AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
			BEGIN
				Raiserror('Reim can''t be Deleted Salary Reference Exist',16,2)
				return -1
			END					
			IF  @RC_apr_ID > 0
					Begin 
						If @RC_app_ID <> Null Or @RC_app_ID <> 0
							Begin
							    if exists(select * from T0120_RC_Approval WITH (NOLOCK) where  RC_APR_ID = @RC_apr_ID and isnull(Direct_Approval,0) = 1)
									BEGIN
									-- Add By Mukti 11072016(start)
										exec P9999_Audit_get @table='T0120_RC_Approval' ,@key_column='RC_APR_ID',@key_Values=@RC_apr_ID,@String=@String_val output
										set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
									-- Add By Mukti 11072016(end)
		
											delete FROM T0110_RC_Reimbursement_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
											delete FROM T0110_RC_Dependant_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
											delete FROM T0110_RC_LTA_Travel_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
											Delete from T0210_monthly_Reim_Detail 
													where RC_APR_ID = @RC_apr_ID and cmp_id=@Cmp_ID  --Added By Ripal 04July2014
											delete FROM T0100_RC_Application where RC_APP_ID = @RC_App_ID  and cmp_ID=@cmp_ID	--Edit By Ripal 01Dec2013
											DELETE FROM T0120_RC_Approval where RC_APR_ID = @RC_apr_ID
									END
							    Else
									BEGIN
										-- Add By Mukti 11072016(start)
											exec P9999_Audit_get @table='T0120_RC_Approval' ,@key_column='RC_APR_ID',@key_Values=@RC_apr_ID,@String=@String_val output
											set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
										-- Add By Mukti 11072016(end)
									
										Delete from T0210_monthly_Reim_Detail 
													where RC_APR_ID = @RC_apr_ID and cmp_id=@Cmp_ID  --Added By Ripal 04July2014
										
										DELETE FROM T0120_RC_Approval where RC_APR_ID = @RC_apr_ID
				
										UPDATE  T0100_RC_Application
										SET     APP_Status = 0
										WHERE	RC_APP_ID = @RC_app_ID
										
										Update T0110_RC_Reimbursement_Detail ---Added By Ripal 22Aug2014
											Set	Apr_Amount = 0.0
										Where RC_APP_ID = @RC_app_ID
										
										UPDATE T0110_RC_Dependant_Detail ---Added By Ripal 25Aug2014
											Set Apr_Amount = 0.0
										Where RC_APP_ID = @RC_app_ID
										
										update T0110_RC_LTA_Travel_Detail  ---Added By Ripal 26Aug2014
											set Apr_Amount = 0.0
										Where  RC_APP_ID = @RC_app_ID
										
									END
							
							END		
					END				
	END
  ELSE
   BEGIN
		
		IF Exists(Select 1 From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_App_ID = @RC_APP_ID)	--Add Condition for Not Delete Reim-Claim application --''Ankit 
			Begin
				Set @Tran_id = 0
				Return -1
			End
		Else if @Tran_id <> 0 and @Rpt_Level = 1 --added By Ripal 09Jul2014
			Begin
				Return
			End
			--comment by chetan/nimeshbhai 10/11/2017
		--else if exists(SELECT 1 from T0100_RC_Application where RC_APP_ID = @RC_App_ID and cmp_ID=@cmp_ID and APP_Status = 0 and @S_emp_id <> 0)  --added By Ripal 09Jul2014
		--	Begin
		--		Raiserror('Some records can''t delete successfully.',16,2)
		--		return -1
		--	End
		
		if Exists(SELECT 1 from T0110_RC_Reimbursement_Detail WITH (NOLOCK) where RC_APP_ID = @RC_App_ID and Cmp_ID=@Cmp_ID)
			BEGIN
				delete FROM T0110_RC_Reimbursement_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
			end

		if Exists(SELECT 1 from T0110_RC_Dependant_Detail WITH (NOLOCK) where RC_APP_ID = @RC_App_ID and Cmp_ID=@Cmp_ID)
			BEGIN
				delete FROM T0110_RC_Dependant_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
			end

		if Exists(SELECT 1 from T0110_RC_LTA_Travel_Detail WITH (NOLOCK) where RC_APP_ID = @RC_App_ID and Cmp_ID=@Cmp_ID)
			BEGIN
				delete FROM T0110_RC_LTA_Travel_Detail where RC_APP_ID=@RC_App_ID and cmp_ID=@cmp_ID
			end

		if Exists(SELECT 1 from T0100_RC_Application WITH (NOLOCK) where RC_APP_ID = @RC_App_ID and cmp_ID=@cmp_ID) --Edit By Ripal 01Dec2013
			BEGIN	
				delete FROM T0100_RC_Application where RC_APP_ID = @RC_App_ID  and cmp_ID=@cmp_ID	--Edit By Ripal 01Dec2013
			End		
   END				
END
	exec P9999_Audit_Trail @CMP_ID,@Trans_Type,'Reimbursement Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN  
  
  
  

