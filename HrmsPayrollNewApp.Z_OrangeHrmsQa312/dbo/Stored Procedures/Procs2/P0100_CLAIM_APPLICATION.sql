
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0100_CLAIM_APPLICATION]
		 @Claim_App_ID	numeric(18, 0) OUTPUT
		,@Claim_ID	numeric(18, 0)
		,@Cmp_ID	numeric(18, 0)
		,@Emp_ID	numeric(18, 0)
		,@Claim_App_Date	datetime
		,@Claim_App_Code	varchar(20)	output
		,@Claim_App_Amount	numeric(18, 0)
		,@Claim_App_Status char(1)
		,@Claim_App_Description	varchar(250)
		,@Claim_App_Docs varchar(max)
		,@tran_type  Varchar(1) 
		,@S_Emp_ID	numeric(18, 0)=null
		,@Submit_Flag tinyint =0
		,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
		,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
		,@Is_Mobile_Entry tinyint = 0 -- Add By Deepal 1272020 From Mobile 1 else Payroll default 0
		,@IsTermsCondition bit = null
		,@TermsCondition varchar(max) = null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  --if @Claim_App_Docs =''
    --set  @Claim_App_Docs = null
    if @S_Emp_ID=0
    set @S_Emp_ID=null
    
    -- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 08072016(end)

		IF @tran_type ='I' or @tran_type ='F'  
			BEGIN
			
			--declare @Emp_Code as numeric
			--declare @str_Emp_Code as varchar(20)
		
		select @Claim_App_ID = Isnull(max(Claim_App_ID),0) + 1 From dbo.T0100_CLAIM_APPLICATION  WITH (NOLOCK)
		
				/*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID
				
				SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code) 
			
				select @Claim_App_Code =   cast(isnull(max(substring(Claim_App_Code,8,len(Claim_App_Code))),0) + 1 as varchar)  
						from dbo.T0100_CLAIM_APPLICATION  where Emp_ID = @Emp_ID
						
					
				If charindex(':',@Claim_App_Code) > 0 
					Begin
						Select @Claim_App_Code = right(@Claim_App_Code,len(@Claim_App_Code) - charindex(':',@Claim_App_Code))
					End
						if @Claim_App_Code is not null
							begin
								while len(@Claim_App_Code) <> 4
										begin
												set @Claim_App_Code = '0' + @Claim_App_Code
											end
										set @Claim_App_Code = 'CA'+ @str_Emp_Code +':'+ @Claim_App_Code  
							end
						else
						Begin
							SET @Claim_App_Code = 'CA' + @str_Emp_Code + ':' + '0001' 
						End
				*/
			
			/* IF Exists Condition added by Mihir 06102011*/
			--if exists(select 1 from T0040_CLAIM_MASTER where Claim_ID = @Claim_ID and isnull(Claim_For,0) <> 1)
			--	begin

			If exists(select Emp_ID From dbo.T0100_CLAIM_APPLICATION CA WITH (NOLOCK)
					  INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CA.Claim_ID = CM.Claim_ID
					  where CA.Cmp_ID = @Cmp_ID and CA.Emp_ID = @Emp_ID and CA.Claim_ID = @Claim_ID and CA.Claim_App_Status = 'P' and 
					  CA.Claim_App_Date = @Claim_App_Date and isnull(Claim_For,0) <> 1 and CM.Claim_ID = @Claim_ID AND Claim_Limit_Type <> 0)
			BEGIN
			
					Set @Claim_App_Code = 0
					RAISERROR('Claim Request already Exist',16,2)
					RETURN 
				--end				
			END
			ELSE
			BEGIN
			set @Claim_App_Code = cast(@Claim_App_ID as varchar(20))	

				--print @Claim_App_ID
				--print @Cmp_ID
				--print @Claim_ID
				--print @Emp_ID
				--print @Claim_App_Date
				--print @Claim_App_Code
				--print @Claim_App_Amount
				--print @Claim_App_Description
				--print @Claim_App_Docs
				--print @Claim_App_Status
				--print @S_Emp_ID
				--print @Submit_Flag
				--print @User_Id
				--print getdate()
				--print @Is_Mobile_Entry
				--print @IsTermsCondition
				--print @TermsCondition

			INSERT INTO dbo.T0100_CLAIM_APPLICATION
						(Claim_App_ID
							,Cmp_ID
							,Claim_ID
							,Emp_ID
							,Claim_App_Date
							,Claim_App_Code
							,Claim_App_Amount
							,Claim_App_Description
							,Claim_App_Doc
							,Claim_App_Status
							,S_Emp_ID
							,Submit_Flag
							,Transaction_By
							,Transaction_Date
							,Is_Mobile_Entry
							,Terms_isAccepted
							,Claim_TermsCondition
							)
						VALUES      
						(@Claim_App_ID
							,@Cmp_ID
							,@Claim_ID
							,@Emp_ID
							,@Claim_App_Date
							,@Claim_App_Code
							,@Claim_App_Amount
							,@Claim_App_Description
							,@Claim_App_Docs
							,@Claim_App_Status
							,@S_Emp_ID
							,@Submit_Flag
							,@User_Id
							,getdate()
							,@Is_Mobile_Entry
							,@IsTermsCondition
							,@TermsCondition
							)
							
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0100_CLAIM_APPLICATION' ,@key_column='Claim_App_ID',@key_Values=@Claim_App_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)		
					
			END 
	END
	else if @tran_type ='U' or @tran_type ='F'  
				begin
				
				if exists	(	select Claim_App_ID 
									from T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)
									where Cmp_ID=@Cmp_ID and Claim_App_ID=@Claim_App_ID and Emp_ID=@Emp_ID 
								)
					begin
					
						RAISERROR (N'Claim Approval - Reference Exist.', 16, 2); 
						RETURN
					
					end
				
				-- Add By Mukti 05072016(start)
					exec P9999_Audit_get @table='T0100_CLAIM_APPLICATION' ,@key_column='Claim_App_ID',@key_Values=@Claim_App_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				-- Add By Mukti 05072016(end)
			
				DELETE FROM T0110_CLAIM_APPLICATION_DETAIL WHERE CMP_ID = @CMP_ID AND CLAIM_APP_ID = @CLAIM_APP_ID
				
				if @Claim_App_Docs = ''				
					begin 
						UPDATE    dbo.T0100_CLAIM_APPLICATION
						SET		 Claim_ID =@Claim_ID
								,Claim_App_Date=@Claim_App_Date
								,Claim_App_Amount=@Claim_App_Amount
								,Claim_App_Description=@Claim_App_Description
								,Claim_App_Status =@Claim_App_Status 
								,S_Emp_ID=@S_Emp_ID
								,Submit_Flag=@Submit_Flag
								,Transaction_By = @User_Id
								,Transaction_Date = getdate()								
							where Claim_App_ID = @Claim_App_ID
					END
				ELSE
					BEGIN
						UPDATE    dbo.T0100_CLAIM_APPLICATION
						SET		 Claim_ID =@Claim_ID
								,Claim_App_Date=@Claim_App_Date
								,Claim_App_Amount=@Claim_App_Amount
								,Claim_App_Description=@Claim_App_Description
								,Claim_App_Doc=@Claim_App_Docs
								,Claim_App_Status =@Claim_App_Status 
								,S_Emp_ID=@S_Emp_ID
								,Submit_Flag=@Submit_Flag
								,Transaction_By = @User_Id
								,Transaction_Date = getdate() 
							   where Claim_App_ID = @Claim_App_ID
					end
				
				
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0100_CLAIM_APPLICATION' ,@key_column='Claim_App_ID',@key_Values=@Claim_App_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)    
			End
	else if @tran_type ='D'
	begin
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table='T0100_CLAIM_APPLICATION' ,@key_column='Claim_App_ID',@key_Values=@Claim_App_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add By Mukti 05072016(end)
	delete from dbo.T0110_CLAIM_APPLICATION_DETAIL where Claim_App_ID=@Claim_App_ID
	DELETE FROM dbo.T0100_CLAIM_APPLICATION where Claim_App_ID = @Claim_App_ID
	
	end
			
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN




