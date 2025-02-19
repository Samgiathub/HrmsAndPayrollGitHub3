
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE[dbo].[P0110_RC_Dependent_Detail]
	@RC_Dependent_ID	numeric(18,0) output,
	@RC_APP_ID	numeric(18,0),
	@Cmp_ID numeric(18,0),	
	@RC_ID numeric(18,0),
	@Name varchar(255),
	@Relation varchar(255),
	@Age  varchar(255),	
	@Amount numeric(18,2),	
	@Tran_type char(1),
	@BillNo varchar(255),
	@BillDate DateTime,
	@PrescribeBy varchar(255),
	@Apr_Amount  numeric(18,2),  --Ripal 25Aug2014
	@S_emp_ID numeric(18,0) = 0, --Ripal 25Aug2014
	@Final_Approver  Integer = 0,	--Ripal 25Aug2014
	@Is_Fwd_Leave_Rej Integer = 0,	--Ripal 25Aug2014
	@Rpt_Level tinyint = 0,		--Ripal 25Aug2014
	@APR_Status tinyint = 0,  --Ripal 25Aug2014
	@Direct_App tinyint	= 0, --Ripal 27Aug2014
	--Ripal 12Nov2014 Start
	@AD_Exp_Master_ID numeric(18,0),
	@Exp_FromDate Datetime,
	@Exp_ToDate Datetime
	--Ripal 12Nov2014 End
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
	,@IP_Address varchar(30)= '' -- Add By Mukti 11072016	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Added By Ripal 25Aug2014
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
			if @S_emp_ID <> 0  OR @Direct_App = 0 --Added by Ripal for multi level	22Aug2014    
				Begin
						--commented by Mukti(21112016)start
						--Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
						--select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Dependant_Detail_Level
						--INSERT INTO T0115_RC_Dependant_Detail_Level
						--	   (Tran_ID,RC_LevelTran_ID,RC_Dependent_ID,Cmp_ID,Name,Relation,Age,BillNo,BillDate
						--	   ,PrescribeBy,Amount,Apr_Amount,CreatedBy,CreatedDate
						--	   ,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate)  --Ripal 12Nov2014
						-- VALUES
						--	   (@Tran_ID,@RC_LevelTran_ID,0,@Cmp_ID,@Name,@Relation,@Age,@BillNo,@BillDate
						--	   ,@PrescribeBy,@Amount,@Apr_Amount,@S_Emp_ID,Getdate()
						--	   ,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate)  --Ripal 12Nov2014
						--commented by Mukti(21112016)end
							 
						IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
						Begin
							select @RC_Dependent_ID = Isnull(max(RC_Dependent_ID),0) + 1 	From T0110_RC_Dependant_Detail WITH (NOLOCK)		
							INSERT into T0110_RC_Dependant_Detail
							(				
								RC_Dependent_ID,RC_APP_ID,Cmp_ID,RC_ID,Name,Age,Relation,BillNo,BillDate,Amount,PrescribeBy,Apr_Amount
								,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate  --Ripal 12Nov2014
							)
							values
							(
								@RC_Dependent_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Name,@Age,@Relation,@BillNo,@BillDate,@Amount,@PrescribeBy,@Apr_Amount
								,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate  --Ripal 12Nov2014
							)
							--Added by Mukti(21112016)start
							Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
							select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Dependant_Detail_Level WITH (NOLOCK)
							INSERT INTO T0115_RC_Dependant_Detail_Level
								   (Tran_ID,RC_LevelTran_ID,RC_Dependent_ID,Cmp_ID,Name,Relation,Age,BillNo,BillDate
								   ,PrescribeBy,Amount,Apr_Amount,CreatedBy,CreatedDate
								   ,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate)  --Ripal 12Nov2014
							 VALUES
								   (@Tran_ID,@RC_LevelTran_ID,@RC_Dependent_ID,@Cmp_ID,@Name,@Relation,@Age,@BillNo,@BillDate
								   ,@PrescribeBy,@Amount,@Apr_Amount,@S_Emp_ID,Getdate()
								   ,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate)  --Ripal 12Nov2014
							--Added by Mukti(21112016)end
						END		
				End
			Else
				Begin
					select @RC_Dependent_ID = Isnull(max(RC_Dependent_ID),0) + 1 	From T0110_RC_Dependant_Detail WITH (NOLOCK)		
					
					INSERT into T0110_RC_Dependant_Detail
					(				
						RC_Dependent_ID,RC_APP_ID,Cmp_ID,RC_ID,Name,Age,Relation,BillNo,BillDate,Amount,PrescribeBy,Apr_Amount
						,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate   --Ripal 12Nov2014
					)
					values
					(
						@RC_Dependent_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Name,@Age,@Relation,@BillNo,@BillDate,@Amount,@PrescribeBy,@Apr_Amount
						,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate --Ripal 12Nov2014				
					)					
				End	
		-- Add By Mukti 11072016(start)
			exec P9999_Audit_get @table = 'T0110_RC_Dependant_Detail' ,@key_column='RC_Dependent_ID',@key_Values=@RC_Dependent_ID,@String=@String_val output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
		-- Add By Mukti 11072016(end)
		End
	else if @Tran_type = 'U' 	
		begin
			--Added by Ripal for multi level
			--commented by Mukti(22112016)start
			--Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
			--select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Dependant_Detail_Level
			--INSERT INTO T0115_RC_Dependant_Detail_Level
			--	   (Tran_ID,RC_LevelTran_ID,RC_Dependent_ID,Cmp_ID,Name,Relation,Age,BillNo,BillDate
			--	   ,PrescribeBy,Amount,Apr_Amount,CreatedBy,CreatedDate
			--	   ,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate) --Ripal 12Nov2014
			-- VALUES
			--	   (@Tran_ID,@RC_LevelTran_ID,@RC_Dependent_ID,@Cmp_ID,@Name,@Relation,@Age,@BillNo,@BillDate
			--	   ,@PrescribeBy,@Amount,@Apr_Amount,@S_Emp_ID,Getdate()
			--	   ,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate)  --Ripal 12Nov2014
			--commented by Mukti(22112016)end
			
			IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
			Begin
				if @RC_Dependent_ID = 0
					Begin
							select @RC_Dependent_ID = Isnull(max(RC_Dependent_ID),0) + 1 	From T0110_RC_Dependant_Detail	WITH (NOLOCK)	
								INSERT into T0110_RC_Dependant_Detail
								(				
									RC_Dependent_ID,RC_APP_ID,Cmp_ID,RC_ID,Name,Age,Relation,BillNo,BillDate,Amount,PrescribeBy,Apr_Amount
									,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate  --Ripal 12Nov2014
								)
								values
								(
									@RC_Dependent_ID,@RC_APP_ID,@Cmp_ID,@RC_ID,@Name,@Age,@Relation,@BillNo,@BillDate,@Amount,@PrescribeBy,@Apr_Amount
									,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate  --Ripal 12Nov2014					
								)
					
						-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table = 'T0110_RC_Dependant_Detail' ,@key_column='RC_Dependent_ID',@key_Values=@RC_Dependent_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
				Else
					Begin
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0110_RC_Dependant_Detail' ,@key_column='RC_Dependent_ID',@key_Values=@RC_Dependent_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end)
			
						Update T0110_RC_Dependant_Detail								 												
						set	
							RC_ID = @RC_ID,
							Name = @Name,
							Age = @Age,		
							Relation = @Relation,
							BillNo = @BillNo,
							BillDate = @BillDate,
							Amount=@Amount,
							PrescribeBy = @PrescribeBy,
							Apr_Amount = @Apr_Amount
							,AD_Exp_Master_ID=@AD_Exp_Master_ID,Exp_FromDate=@Exp_FromDate,Exp_ToDate=@Exp_ToDate --Ripal 12Nov2014
						where RC_Dependent_ID =@RC_Dependent_ID
						
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table = 'T0110_RC_Dependant_Detail' ,@key_column='RC_Dependent_ID',@key_Values=@RC_Dependent_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end) 
					End
					
					--Added By Mukti(22112016)start
					Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
					select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_Dependant_Detail_Level WITH (NOLOCK)
					INSERT INTO T0115_RC_Dependant_Detail_Level
						   (Tran_ID,RC_LevelTran_ID,RC_Dependent_ID,Cmp_ID,Name,Relation,Age,BillNo,BillDate
						   ,PrescribeBy,Amount,Apr_Amount,CreatedBy,CreatedDate
						   ,AD_Exp_Master_ID,Exp_FromDate,Exp_ToDate) --Ripal 12Nov2014
					 VALUES
						   (@Tran_ID,@RC_LevelTran_ID,@RC_Dependent_ID,@Cmp_ID,@Name,@Relation,@Age,@BillNo,@BillDate
						   ,@PrescribeBy,@Amount,@Apr_Amount,@S_Emp_ID,Getdate()
						   ,@AD_Exp_Master_ID,@Exp_FromDate,@Exp_ToDate)
					--Added By Mukti(22112016)end
			END		
									
		end		
	Else if @Tran_type = 'D' 
		begin
			-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0110_RC_Dependant_Detail' ,@key_column='RC_Dependent_ID',@key_Values=@RC_Dependent_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
					
			delete FROM T0110_RC_Dependant_Detail where RC_Dependent_ID =@RC_Dependent_ID
			 and RC_APP_ID=@RC_APP_ID and cmp_ID=@cmp_ID	
				
		end
	
--Update T0110_RC_Dependant_Detail								 												
	--set			
	--			Relation = @Relation,
	--			Age = @Age,
	--			RC_ID =@RC_ID,
	--			Name = @Name,
	--			Amount=@Amount,
	--			BillNo = @BillNo,
	--			BillDate = @BillDate	    
	--where RC_Dependent_ID =@RC_Dependent_ID	and RC_APP_ID=@RC_APP_ID and cmp_ID=@cmp_ID
	
exec P9999_Audit_Trail @CMP_ID,@tran_type,'Reimbursement Dependant Details',@OldValue,@RC_Dependent_ID,@User_Id,@IP_Address
