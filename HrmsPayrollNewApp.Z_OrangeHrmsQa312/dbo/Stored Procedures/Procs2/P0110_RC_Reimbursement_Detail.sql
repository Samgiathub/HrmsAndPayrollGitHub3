

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0110_RC_Reimbursement_Detail]
	@RC_Reim_ID	numeric(18,0) output,
	@RC_APP_ID  numeric(18,0),
	@Cmp_ID	numeric(18,0),
	@RC_ID numeric(18,0),
	@Emp_ID	numeric(18,0),
	@Bill_Date	Datetime,
	@Bill_No	varchar(255),
	@Amount  numeric(18,2),
	@Description	nvarchar(max),
	@Comments	nvarchar(max),
	@Tran_type  char(1),
	@Apr_Amount  numeric(18,2),  --Ripal 21Aug2014
	@S_emp_ID numeric(18,0) = 0, --Ripal 21Aug2014
	@Final_Approver  Integer = 0,	--Ripal 21Aug2014
	@Is_Fwd_Leave_Rej Integer = 0,	--Ripal 21Aug2014
	@Rpt_Level tinyint = 0,		--Ripal 21Aug2014
	@APR_Status tinyint = 0,  --Ripal 21Aug2014
	@Direct_App tinyint	= 0, --Ripal 27Aug2014
	--Ripal 12Nov2014 Start
	@AD_Exp_Master_ID numeric(18,0) = null,
    @Exp_FromDate datetime = null,
    @Exp_ToDate datetime = null
	--Ripal 12Nov2014 End
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
	,@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Added By Ripal 21Aug2014
	Declare @RC_LevelTran_ID as numeric(18,0)
	Declare @Tran_ID as numeric(18,0)
	
	--Ripal 12Nov2014 Start
	if @AD_Exp_Master_ID = 0
		Begin
			set @AD_Exp_Master_ID = null
		End
	if @Exp_FromDate = '1900-01-01 00:00:00.000'
		Begin
			set @Exp_FromDate = null
		End
	if @Exp_ToDate = '1900-01-01 00:00:00.000'
		Begin
			set @Exp_ToDate = null
		End
	--Ripal 12Nov2014 End
	
	-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	-- Add By Mukti 11072016(end)
							
	If @Tran_type  = 'I' 
		Begin
				if @S_emp_ID <> 0 OR @Direct_App = 0 --Added by Ripal for multi level	22Aug2014    
					Begin
						
						Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
						select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Reimbursement_Detail_Level WITH (NOLOCK)
						INSERT INTO T0115_RC_Reimbursement_Detail_Level
							   (Tran_ID,RC_LevelTran_ID,RC_Reim_ID,Cmp_ID,Bill_Date,Bill_No,Amount,Apr_Amount,
								Description,Comments,CreatedBy,CreatedDate
								,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate)  --Ripal 12Nov2014
						 VALUES
							   (@Tran_ID,@RC_LevelTran_ID,0,@Cmp_ID,@Bill_Date,@Bill_No,@Amount,@Apr_Amount,
								@Description,@Comments,@S_Emp_ID,Getdate()
								,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate) --Ripal 12Nov2014
								
						IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
						Begin
							select @RC_Reim_ID = Isnull(max(RC_Reim_ID),0) + 1 	From T0110_RC_Reimbursement_Detail	WITH (NOLOCK)
							INSERT into T0110_RC_Reimbursement_Detail
							(				
								RC_Reim_ID,RC_APP_ID,Cmp_ID,RC_ID,Emp_ID,Bill_Date,Bill_No,amount,Apr_Amount,Description,Comments
								,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate --Ripal 12Nov2014
							)
							values
							(
								@RC_Reim_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Emp_ID,@Bill_Date,@Bill_No,@Amount,@Apr_Amount,@Description,@Comments
								,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate  --Ripal 12Nov2014
							)
							
							-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
							-- Add By Mukti 11072016(end)		
						END		
					End
				Else
					Begin
						select @RC_Reim_ID = Isnull(max(RC_Reim_ID),0) + 1 	From T0110_RC_Reimbursement_Detail	WITH (NOLOCK)
						INSERT into T0110_RC_Reimbursement_Detail
						(				
							RC_Reim_ID,RC_APP_ID,Cmp_ID,RC_ID,Emp_ID,Bill_Date,Bill_No,amount,Description,Comments,Apr_Amount
							,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate  --Ripal 12Nov2014
						)
						values
						(
							@RC_Reim_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Emp_ID,@Bill_Date,@Bill_No,@Amount,@Description,@Comments,@Apr_Amount
							,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate  --Ripal 12Nov2014
						)
						
						-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)		
					END
		End
	else if @Tran_type = 'U' 	
		begin			
			--Added by Ripal for multi level	    
			
			Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
			select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Reimbursement_Detail_Level WITH (NOLOCK)

			INSERT INTO T0115_RC_Reimbursement_Detail_Level
				   (Tran_ID,RC_LevelTran_ID,RC_Reim_ID,Cmp_ID,Bill_Date,Bill_No,Amount,Apr_Amount,
					Description,Comments,CreatedBy,CreatedDate
					,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate)  --Ripal 12Nov2014
			 VALUES
				   (@Tran_ID,@RC_LevelTran_ID,@RC_Reim_ID,@Cmp_ID,@Bill_Date,@Bill_No,@Amount,@Apr_Amount,
					@Description,@Comments,@S_Emp_ID,Getdate()
					,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate)  --Ripal 12Nov2014
			
			IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
			Begin
				if @RC_Reim_ID = 0
					Begin
						select @RC_Reim_ID = Isnull(max(RC_Reim_ID),0) + 1 	From T0110_RC_Reimbursement_Detail	WITH (NOLOCK)
						INSERT into T0110_RC_Reimbursement_Detail
						(				
							RC_Reim_ID,RC_APP_ID,Cmp_ID,RC_ID,Emp_ID,Bill_Date,Bill_No,amount,Apr_Amount,Description,Comments
							,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate  --Ripal 12Nov2014
						)
						values
						(
							@RC_Reim_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Emp_ID,@Bill_Date,@Bill_No,@Amount,@Apr_Amount,@Description,@Comments
							,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate   --Ripal 12Nov2014
						)
						
						-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
				Else
					Begin
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end)
			
						Update T0110_RC_Reimbursement_Detail set 
								Bill_Date =@Bill_Date ,
								Bill_No = @Bill_No,
								Amount = @Amount,
								Apr_Amount = @Apr_Amount,
								Description = @Description,
								Comments = @Comments,
								RC_ID =@RC_ID
								,AD_Exp_Master_ID=@AD_Exp_Master_ID,Exp_FromDate=@Exp_FromDate,Exp_ToDate=@Exp_ToDate  --Ripal 12Nov2014
						where RC_Reim_ID =@RC_Reim_ID
						
						-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
			END		
									
		end		
	Else if @Tran_type = 'D' 
		begin		
			-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0110_RC_Reimbursement_Detail' ,@key_column='RC_Reim_ID',@key_Values=@RC_Reim_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
			
			delete FROM T0110_RC_Reimbursement_Detail where RC_Reim_ID =@RC_Reim_ID					
		end
		
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Reimbursement Details',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
	
--Update T0110_RC_Reimbursement_Detail								 												
--		set 
--		Bill_Date =@Bill_Date ,
--		Bill_No = @Bill_No,
--		Description = @Description,
--		Comments = @Comments,
--		RC_ID =@RC_ID				    
--where RC_Reim_ID =@RC_Reim_ID
