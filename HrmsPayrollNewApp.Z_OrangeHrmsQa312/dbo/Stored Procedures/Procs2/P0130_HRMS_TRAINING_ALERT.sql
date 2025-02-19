


CREATE PROCEDURE [dbo].[P0130_HRMS_TRAINING_ALERT]
  @Tran_alert_ID	numeric(18,0) output
 ,@Training_Apr_ID  numeric(18,0)
 ,@Dept_ID          numeric(18,0)
 ,@Emp_ID			numeric(18,0)
 ,@Comments			varchar(500)
 ,@alerts_Start_Days numeric(18,0)
 ,@alerts_Days		numeric(18,0)
 ,@cmp_id			numeric(18,0)
 ,@tran_type 		char(1)
 ,@User_Id numeric(18,0) = 0 -- added By Mukti 18082015
 ,@IP_Address varchar(30)= '' -- added By Mukti 18082015           
           
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

 --Added By Mukti 18082015(start)
	declare @OldValue			varchar(max)
    declare @OldComments		varchar(500)
    declare @Oldalerts_Start_Days varchar(15)
    declare @Oldalerts_Days		varchar(15)
 --Added By Mukti 18082015(end)
 
IF @Training_Apr_ID=0
	SET @Training_Apr_ID = NULL
IF @Dept_ID = 0
	SET @Dept_ID = null
IF @Emp_ID =0 
	SET @Emp_ID = NULL
IF @cmp_id = NULL
   SET @cmp_id = 0

	--Comment By Ripal 09July2014
	--if exists (Select Tran_alert_ID  from dbo.T0130_HRMS_TRAINING_ALERT Where cmp_id=@CMP_ID AND Tran_alert_ID=@Tran_alert_ID AND Emp_ID=Emp_ID)
	--begin
	-- set @tran_type= 'U'
	--end
	--else
	--begin
	--set @tran_type= 'I'
	--end	
	  
	if Upper(@tran_type) ='I' 
		begin

			if exists (Select Tran_alert_ID  from dbo.T0130_HRMS_TRAINING_ALERT WITH (NOLOCK) Where cmp_id=@CMP_ID AND Training_Apr_ID=@Training_Apr_ID AND Emp_ID=@Emp_ID) --Emp_ID to @Emp_ID change by Ripal 09July2014
				begin
					--Added By Mukti 18082015(start)			
					select  @oldComments=Comments
						,@Oldalerts_Start_Days=alerts_Start_Days
						,@Oldalerts_Days=alerts_Days
					 from T0130_HRMS_TRAINING_ALERT WITH (NOLOCK) where Tran_alert_ID = @Tran_alert_ID  
					--Added By Mukti 18082015(end)
				
					Select @Tran_alert_ID = Tran_alert_ID  from dbo.T0130_HRMS_TRAINING_ALERT WITH (NOLOCK) Where cmp_id=@CMP_ID AND Training_Apr_ID=@Training_Apr_ID AND Emp_ID=@Emp_ID  --Emp_ID to @Emp_ID change by Ripal 09July2014
					
					Update dbo.T0130_HRMS_TRAINING_ALERT  --Added by Ripal 18July2014
						Set	 Comments=@Comments
							,alerts_Start_Days=@alerts_Start_Days
							,alerts_Days=@alerts_Days
					where Tran_alert_ID = @Tran_alert_ID
						
			--Added By Mukti 18082015(start)
		    set @OldValue = 'Old Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@OldComments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@Oldalerts_Start_Days,'') as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@Oldalerts_Days,'') as varchar(10)) + '#' +
							'New Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@Comments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@alerts_Start_Days,0) as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@alerts_Days,0) as varchar(10))
				
				exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Training Alert Setting',@OldValue,@Tran_alert_ID,@User_Id,@IP_Address 		
			--Added By Mukti 18082015(end) 
					RETURN
					
				end
					select @Tran_alert_ID = isnull(max(Tran_alert_ID),0) + 1 from dbo.T0130_HRMS_TRAINING_ALERT WITH (NOLOCK)
						
					insert into dbo.T0130_HRMS_TRAINING_ALERT(
												Tran_alert_ID
												,Training_Apr_ID
												,Dept_ID
												,Emp_ID
												,Comments
												,alerts_Start_Days
												,alerts_Days
												,cmp_id

										) 
											
								values(         @Tran_alert_ID
												,@Training_Apr_ID
												,@Dept_ID
												,@Emp_ID
												,@Comments
												,@alerts_Start_Days
												,@alerts_Days
												,@cmp_id									
										)
		--Added By Mukti 18082015(start)
		    set @OldValue = 'New Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@Comments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@alerts_Start_Days,0) as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@alerts_Days,0) as varchar(10))
											   
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Training Alert Setting',@OldValue,@Tran_alert_ID,@User_Id,@IP_Address 		
		--Added By Mukti 18082015(end)    
				end 
	else if upper(@tran_type) ='U' 
		begin		
		--Added By Mukti 18082015(start)			
				select  @oldComments=Comments
					,@Oldalerts_Start_Days=alerts_Start_Days
					,@Oldalerts_Days=alerts_Days
				 from T0130_HRMS_TRAINING_ALERT WITH (NOLOCK) where Tran_alert_ID = @Tran_alert_ID  
		--Added By Mukti 18082015(end)			
				Update dbo.T0130_HRMS_TRAINING_ALERT 
				Set Comments=@Comments
						,alerts_Start_Days=@alerts_Start_Days
						,alerts_Days=@alerts_Days
				where Tran_alert_ID = @Tran_alert_ID  
				
		--Added By Mukti 18082015(start)
		    set @OldValue = 'Old Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@OldComments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@Oldalerts_Start_Days,'') as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@Oldalerts_Days,'') as varchar(10)) + '#' +
							'New Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@Comments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@alerts_Start_Days,0) as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@alerts_Days,0) as varchar(10))
		--Added By Mukti 18082015(end) 
		 
		 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Training Alert Setting',@OldValue,@Tran_alert_ID,@User_Id,@IP_Address 		
		end	
	else if upper(@tran_type) ='D'
		Begin
			--Added By Mukti 18082015(start)			
				select  @oldComments=Comments
					,@Oldalerts_Start_Days=alerts_Start_Days
					,@Oldalerts_Days=alerts_Days
				 from T0130_HRMS_TRAINING_ALERT WITH (NOLOCK) where Tran_alert_ID = @Tran_alert_ID  
			--Added By Mukti 18082015(end)
			
			delete  from dbo.T0130_HRMS_TRAINING_ALERT where Tran_alert_ID=@Tran_alert_ID 
			
			--Added By Mukti 18082015(start)
		    set @OldValue = 'Old Value' + '#'+ 'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
											   'Dept ID :' + cast(Isnull(@Dept_ID,0) as varchar(10)) + '#' + 
											   'Emp_ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
											   'Comments :' + cast(Isnull(@OldComments,'') as varchar(500)) + '#' + 
											   'Alerts Start Days :' + cast(Isnull(@Oldalerts_Start_Days,'') as varchar(10)) + '#' + 
											   'Alerts Days :' + cast(Isnull(@Oldalerts_Days,'') as varchar(10))

	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Training Alert Setting',@OldValue,@Tran_alert_ID,@User_Id,@IP_Address 		
			--Added By Mukti 18082015(end)
		end
			
			
			
	RETURN




