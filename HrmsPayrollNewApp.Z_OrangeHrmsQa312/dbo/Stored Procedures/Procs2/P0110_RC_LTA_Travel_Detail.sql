
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE[dbo].[P0110_RC_LTA_Travel_Detail]

	@RC_Travel_ID	numeric(18,0) output,
	@Cmp_ID	numeric(18,0),
	@RC_APP_ID	numeric(18,0),
	@Emp_ID	numeric(18,2),
	@RC_ID numeric(18,2),
	@Travel_Date	Datetime,
	@From_Place	varchar(255),
	@To_Place	varchar(255),
	@Mode_Of_Travel	varchar(255),
	@Fare	numeric(18,2),
	@File_Name	varchar(255),
	@RC_Apr_ID  numeric, 
	@Tax_Exception	Tinyint = 0,
	@Block_Period	varchar(255),
	@Remarks	nvarchar(max),
	@Abroad_Travel	Tinyint = 0,
	@tran_type char(1),
	@Current_Year   int,
	@From_date   DateTime,
	@To_date   DateTime,
	@Bill_No   varchar(50) = '',
	@Bill_Date Datetime = NULL,
	@Apr_Amount  numeric(18,2),  --Ripal 26Aug2014
	@S_emp_ID numeric(18,0) = 0, --Ripal 26Aug2014
	@Final_Approver  Integer = 0,	--Ripal 26Aug2014
	@Is_Fwd_Leave_Rej Integer = 0,	--Ripal 26Aug2014
	@Rpt_Level tinyint = 0,		--Ripal 26Aug2014
	@APR_Status tinyint = 0,  --Ripal 26Aug2014
	@Direct_App tinyint = 0,  --Ripal 27Aug2014
	@AD_Exp_Master_ID numeric(18,0) --Ripal 12Nov2014
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
	,@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added By Ripal 25Aug2014
	Declare @RC_LevelTran_ID as numeric(18,0)
	Declare @Tran_ID as numeric(18,0)
	
Declare @St_date as DateTime
Declare @End_Date as DateTime
	
  set @St_date =  '01/Jan/'+cast(@Current_Year as varchar(4)) 
  set @End_Date = '31/Dec/'+cast(@Current_Year as varchar(4)) 
  print @St_date
  print @End_Date
  
  Declare @RC_Def_ID as Varchar(255)
  declare @Taxable_limit as decimal
  declare @Non_Taxable_limit as decimal
  declare @Block_App_limit as decimal
  declare @Taxable_Count as decimal   
  declare @Non_Taxable_Count as decimal
  declare @Block_App_Count as decimal  
  set @Taxable_limit =0.0
  set @Non_Taxable_limit =0.0
  set @Taxable_Count =0
  set @Non_Taxable_Count =0  
  set @Block_App_Count =0
  set @Block_App_limit =0
  select @RC_Def_ID = AD_DEF_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_ID=@RC_ID and CMP_ID=@Cmp_ID
  select @Taxable_limit = Taxable_limit,@Non_Taxable_limit =Non_Taxable_limit,@Block_App_limit =Num_LTA_Block  from t0040_ReimClaim_Setting WITH (NOLOCK)
  where AD_ID = @RC_ID and cmp_ID=@Cmp_ID
  
  Declare @Temp_Table table
  (
     row_id  int identity,
     Block_Year varchar(255)
  )
  Insert INTO @Temp_Table
  SELECT Data FROM dbo.Split(@Block_Period,'-')
  
  Update @Temp_Table set Block_Year = '01/Jan/'+cast(Block_Year as varchar(4)) where row_id=1
  Update @Temp_Table set Block_Year = '31/Dec/'+cast(Block_Year as varchar(4)) where row_id=2
  
  Declare @St_Block_Year as Datetime
  Declare @End_Block_Year as Datetime
  
  select @St_Block_Year = Block_Year from @Temp_Table where row_ID=1
  select @End_Block_Year = Block_Year from @Temp_Table where row_ID=2
  
--Ripal 12Nov2014 Start
if @AD_Exp_Master_ID = 0
	Begin
		set @AD_Exp_Master_ID = null
	End
--Ripal 12Nov2014 End

-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
 -- Add By Mukti 11072016(end)
 		
	If @tran_type  = 'I' 
		Begin
				IF @RC_Def_ID = 8
				BEGIN								
					select @Block_App_Count =COUNT(*) 
					From T0100_RC_Application A WITH (NOLOCK) inner join T0050_AD_MASTER AM WITH (NOLOCK) on A.RC_ID = AM.AD_ID  					
					Where  APP_Date BETWEEN @St_Block_Year and @End_Block_Year AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=0 AND 
					isnull(A.Tax_Exception,0) = 1  and AM.AD_DEF_ID = 8
										
				end				
				if isnull(@Block_App_limit,0) <> 0
				begin
					IF @Block_App_limit < @Block_App_Count
					BEGIN
						Raiserror('@@Reim-Claim application is exceed in block year@@',16,2)				
						Return 
					end
			    end
			    
			    if @S_emp_ID <> 0 OR @Direct_App = 0 --Added by Ripal for multi level	26Aug2014    
					Begin
						Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
						select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_LTA_Travel_Detail_Level WITH (NOLOCK)
						INSERT INTO T0115_RC_LTA_Travel_Detail_Level
							   (Tran_ID,RC_LevelTran_ID,RC_Travel_ID,Cmp_ID,Travel_Date,From_Place,To_Place,Mode_Of_Travel,Fare,File_Name
							   ,Tax_Exception,Block_Period,Abroad_Travel,Remarks,Current_Year,From_Date,To_Date,Bill_No,Bill_Date
							   ,Apr_Amount,CreatedBy,CreatedDate
							   ,AD_Exp_Master_ID)
						 VALUES
							   (@Tran_ID,@RC_LevelTran_ID,0,@Cmp_ID,@Travel_Date,@From_Place,@To_Place,@Mode_Of_Travel,@Fare,@File_Name
							   ,@Tax_Exception,@Block_Period,@Abroad_Travel,@Remarks,@Current_Year,@From_Date,@To_Date,@Bill_No,@Bill_Date
							   ,@Apr_Amount,@S_Emp_ID,Getdate()
							   ,@AD_Exp_Master_ID)
						
						IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
						Begin
							select @RC_Travel_ID = Isnull(max(RC_Travel_ID),0) + 1 	From T0110_RC_LTA_Travel_Detail	WITH (NOLOCK)							
							insert into T0110_RC_LTA_Travel_Detail
							(				
								RC_Travel_ID,Cmp_ID,RC_APP_ID,RC_ID,Travel_Date,From_Place,To_Place,Mode_Of_Travel,Fare,File_Name,Emp_ID,
								Tax_Exception,Block_Period,Remarks,Abroad_Travel,Current_Year,From_date,To_date,Bill_No,Bill_Date,Apr_Amount--Ripal 27Nov2013
								,AD_Exp_Master_ID)
							VALUES
							(
								@RC_Travel_ID,@Cmp_ID,@RC_APP_ID,@RC_ID,@Travel_Date,@From_Place,@To_Place,@Mode_Of_Travel,@Fare,@File_Name,@Emp_ID,
								@Tax_Exception,@Block_Period,@Remarks,@Abroad_Travel,@Current_Year,@From_date,@To_date,@Bill_No,@Bill_Date,@Apr_Amount
								,@AD_Exp_Master_ID
							)
							-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
							-- Add By Mukti 11072016(end)
						END
					End
				Else
					Begin			
						select @RC_Travel_ID = Isnull(max(RC_Travel_ID),0) + 1 	From T0110_RC_LTA_Travel_Detail	WITH (NOLOCK)							
						insert into T0110_RC_LTA_Travel_Detail
						(				
							RC_Travel_ID,Cmp_ID,RC_APP_ID,RC_ID,Travel_Date,From_Place,To_Place,Mode_Of_Travel,Fare,File_Name,Emp_ID,
							Tax_Exception,Block_Period,Remarks,Abroad_Travel,Current_Year,From_date,To_date,Bill_No,Bill_Date,Apr_Amount
							,AD_Exp_Master_ID)--Ripal 27Nov2013
						VALUES
						(
							@RC_Travel_ID,@Cmp_ID,@RC_APP_ID,@RC_ID,@Travel_Date,@From_Place,@To_Place,@Mode_Of_Travel,@Fare,@File_Name,@Emp_ID,
							@Tax_Exception,@Block_Period,@Remarks,@Abroad_Travel,@Current_Year,@From_date,@To_date,@Bill_No,@Bill_Date,@Apr_Amount
							,@AD_Exp_Master_ID
						)
						-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
		end	
	else if @tran_type = 'U' 
	
		begin
		
			--Added by Ripal for multi level 
			Select @RC_LevelTran_ID = Tran_ID From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_APP_ID=@RC_APP_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level 
			select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From T0115_RC_LTA_Travel_Detail_Level WITH (NOLOCK)
			INSERT INTO T0115_RC_LTA_Travel_Detail_Level
				   (Tran_ID,RC_LevelTran_ID,RC_Travel_ID,Cmp_ID,Travel_Date,From_Place,To_Place,Mode_Of_Travel,Fare,File_Name
				   ,Tax_Exception,Block_Period,Abroad_Travel,Remarks,Current_Year,From_Date,To_Date,Bill_No,Bill_Date
				   ,Apr_Amount,CreatedBy,CreatedDate
				   ,AD_Exp_Master_ID)
			 VALUES
				   (@Tran_ID,@RC_LevelTran_ID,@RC_Travel_ID,@Cmp_ID,@Travel_Date,@From_Place,@To_Place,@Mode_Of_Travel,@Fare,@File_Name
				   ,@Tax_Exception,@Block_Period,@Abroad_Travel,@Remarks,@Current_Year,@From_Date,@To_Date,@Bill_No,@Bill_Date
				   ,@Apr_Amount,@S_Emp_ID,Getdate()
				   ,@AD_Exp_Master_ID)
			
			IF ( @Final_Approver = 1 ) OR ((@Is_Fwd_Leave_Rej = 0) And (@APR_Status = 2))
			Begin
				if @RC_Travel_ID = 0
					Begin
						select @RC_Travel_ID = Isnull(max(RC_Travel_ID),0) + 1 	From T0110_RC_LTA_Travel_Detail	WITH (NOLOCK)							
						insert into T0110_RC_LTA_Travel_Detail
						(				
							RC_Travel_ID,Cmp_ID,RC_APP_ID,RC_ID,Travel_Date,From_Place,To_Place,Mode_Of_Travel,Fare,File_Name,Emp_ID,
							Tax_Exception,Block_Period,Remarks,Abroad_Travel,Current_Year,From_date,To_date,Bill_No,Bill_Date,Apr_Amount--Ripal 27Nov2013
							,AD_Exp_Master_ID)
						VALUES
						(
							@RC_Travel_ID,@Cmp_ID,@RC_APP_ID,@RC_ID,@Travel_Date,@From_Place,@To_Place,@Mode_Of_Travel,@Fare,@File_Name,@Emp_ID,
							@Tax_Exception,@Block_Period,@Remarks,@Abroad_Travel,@Current_Year,@From_date,@To_date,@Bill_No,@Bill_Date,@Apr_Amount
							,@AD_Exp_Master_ID
						)
						
						-- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
				Else
					Begin
						-- Add By Mukti 11072016(start)
							exec P9999_Audit_get @table='T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
							set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
						-- Add By Mukti 11072016(end)
					
						UPDATE T0110_RC_LTA_Travel_Detail
						   SET RC_ID = @RC_ID,Travel_Date = @Travel_Date,From_Place = @From_Place,
							   To_Place = @To_Place,Mode_Of_Travel = @Mode_Of_Travel,Fare = @Fare,
							   File_Name = @File_Name,Tax_Exception =  @Tax_Exception,Block_Period = @Block_Period,
							   Abroad_Travel = @Abroad_Travel,Remarks = @Remarks,Current_Year = @Current_Year,
							   From_Date = @From_Date,To_Date = @To_Date,Bill_No = @Bill_No,
							   Bill_Date = @Bill_Date,Apr_Amount = @Apr_Amount
							   ,AD_Exp_Master_ID = @AD_Exp_Master_ID
						 WHERE RC_Travel_ID = @RC_Travel_ID
						 
						 -- Add By Mukti 11072016(start)
								exec P9999_Audit_get @table = 'T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						-- Add By Mukti 11072016(end)
					End
			END	
					
		end
		
	Else if @tran_type = 'D' 
		begin
		
		   if Exists(SELECT 1 from T0100_RC_Application WITH (NOLOCK) where RC_APP_ID = @RC_APP_ID and cmp_ID=@Cmp_ID)
		   begin
				delete FROM T0100_RC_Application where RC_APP_ID = @RC_APP_ID and cmp_ID=@Cmp_ID
		   end	
			
		   if Exists(SELECT 1 from T0110_RC_LTA_Travel_Detail WITH (NOLOCK) where RC_Travel_ID = @RC_Travel_ID and cmp_ID=@Cmp_ID)
		   begin
				-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0110_RC_LTA_Travel_Detail' ,@key_column='RC_Travel_ID',@key_Values=@RC_Travel_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 11072016(end)
		   
				delete FROM T0110_RC_LTA_Travel_Detail where RC_Travel_ID = @RC_Travel_ID and cmp_ID=@Cmp_ID
		   end		
		
exec P9999_Audit_Trail @CMP_ID,@tran_type,'Reimbursement LTA Details ',@OldValue,@Emp_ID,@User_Id,@IP_Address,1				
end
	



