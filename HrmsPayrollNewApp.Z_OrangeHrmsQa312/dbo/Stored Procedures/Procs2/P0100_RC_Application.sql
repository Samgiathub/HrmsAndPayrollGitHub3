

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_RC_Application]
 @RC_APP_ID	numeric(18,0) output
,@Cmp_ID	numeric(18,0)
,@Emp_ID	numeric(18,0)
,@RC_ID	numeric(18,0)
,@APP_Date	DateTime
,@APP_Amount	numeric(18,2)
,@APP_Comments	nvarchar(max)
,@APP_Status	tinyint
,@Leave_From_Date	Datetime
,@Leave_To_Date	Datetime
,@Days	numeric(5,2)
,@FY	varchar(255) =''
,@Taxable as tinyint
,@tran_type varchar(1) =''
,@FileName varchar(255) =''
,@Rc_Apr_ID numeric(18,0) = 0
,@Is_Manager_Record tinyint
,@S_Emp_ID numeric(18,0)
,@Taxable_amount numeric(18,2) =0
,@Quarter_ID tinyint =0
,@Quarter_Name varchar(50) = ''
,@Submit_Flag tinyint=0 --Added by Sumit for dfraft 09072015
,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
,@IP_Address varchar(30)= '' -- Add By Mukti 11072016	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	declare @System_Date as varchar(11)
	set @System_Date=cast(getdate() as varchar(11))
	if @Leave_From_Date=''
		set @Leave_From_Date=null
	if @Leave_to_Date=''
		set @Leave_to_Date=null
		
	if @Rc_Apr_ID = 0
	 set @Rc_Apr_ID =NULL 

      Declare @J As Varchar(10)
	  Set @J= Cast(@Days As Varchar(10))
 

		
		If substring(@j,CharIndex('.',@j,1)+1, 2) > 0
		Begin
			--If Decimal Leave 4.5,1.5 etc
			Set @Leave_to_Date = DATEADD(day, @Days, @Leave_From_Date)	
		End
		Else
		Begin
		   --If Not Decimal Leave	1,2,4,5 etc
			Set @Leave_to_Date = DATEADD(day, @Days-1, @Leave_From_Date)	
		End
			
		Declare @St_date as DateTime
		Declare @End_Date as DateTime
	
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
	
	--Ripal 07Nov2014 Start
	Declare @MnthSt_date as DateTime
	Declare @MnthEnd_Date as DateTime

	set @MnthSt_date = '01/'+ DATENAME(mm,@App_Date) +'/'+ cast(year(@App_Date) as varchar(10))
	set @MnthEnd_Date =Datediff(DD,1,DATEADD(mm, 1, @MnthSt_date))
    --Ripal 07Nov2014 End 
  
  Declare @RC_Def_ID as Varchar(255)
  declare @Taxable_limit as decimal
  declare @Non_Taxable_limit as decimal
  declare @Block_App_limit as decimal
  declare @Taxable_Count as decimal   
  declare @Non_Taxable_Count as decimal
  declare @Block_App_Count as decimal
  Declare @Monthly_Limit as int --Ripal 07Nov2014
  Declare @Monthly_LimitCount as int --Ripal 07Nov2014
  
  set @Taxable_limit =0.0
  set @Non_Taxable_limit =0.0
  set @Taxable_Count =0
  set @Non_Taxable_Count =0  
  set @Block_App_Count =0
  set @Block_App_limit =0
  
  -- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
 -- Add By Mukti 11072016(end)	
 
		If @tran_type  = 'I' 
			Begin
			
				select @RC_Def_ID = AD_DEF_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_ID=@RC_ID and CMP_ID=@Cmp_ID
				select @Taxable_limit = Taxable_limit,@Non_Taxable_limit =Non_Taxable_limit,@Block_App_limit =Num_LTA_Block  
					from t0040_ReimClaim_Setting WITH (NOLOCK) where AD_ID = @RC_ID and cmp_ID=@Cmp_ID
				
				--Some Change by Ripal 11July 2014 Start
 				select @Taxable_Count =COUNT(1) 
				From T0100_RC_Application A WITH (NOLOCK)
				Where  APP_Date BETWEEN @St_date and @End_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
				isnull(A.Tax_Exception,0) = 0 and RC_ID = @RC_ID
				
								
					
				select @Non_Taxable_Count =COUNT(1) 
				From T0100_RC_Application A WITH (NOLOCK)
				Where  APP_Date BETWEEN @St_date and @End_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID AND APP_Status=1 AND 
				isnull(A.Tax_Exception,0) = 1 and RC_ID = @RC_ID
				
				--Added by Ripal 07Nov2014 start
				select @Monthly_Limit = Monthly_Limit from t0050_Ad_Master WITH (NOLOCK) where  Ad_ID = @RC_ID
				if @Monthly_Limit <> 0
					Begin
						select @Monthly_LimitCount = count(1)
							From T0100_RC_Application A WITH (NOLOCK)
							Where  APP_Date BETWEEN @MnthSt_date and @MnthEnd_Date AND A.Cmp_ID=@cmp_ID and A.Emp_ID=@emp_ID 
								   AND APP_Status=1 AND RC_ID = @RC_ID
						IF @Monthly_Limit <= @Monthly_LimitCount
							BEGIN							
								Raiserror('@@Application limit is exceed in month.@@',16,2)				
								Return -1
							end
					End
				--Added by Ripal 07Nov2014 End
			
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
									
				--Added By Ripal 06Jan2014 start
				if Exists(select 1 from T0100_RC_Application WITH (NOLOCK) where APP_Date = @APP_Date and cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and RC_ID = @RC_ID)
				Begin
					Raiserror('@@Reim-Claim application is already exists for this date and Reim Type.@@',16,2)				
					Return 
				End
				
				--Added By Jimit 09032018
		if @Is_Manager_Record <> 1
			BEGIN	
				if exists(select 1 from T0050_AD_MASTER WITH (NOLOCK) where AD_ID = @RC_ID and CMP_ID = @Cmp_ID and IsNull(Negative_Balance,0) =0)
                  Begin
						 declare @Reim_Closing as Numeric(18,2)                           
                           
                         create table #Reim_Closing
                           (
								Reim_Tran_ID  Numeric,
								Emp_Id numeric,
								ad_Name varchar(50),
								Reim_opening numeric(18,2),
								Reim_credit numeric(18,2),
								Reim_Debit  numeric(18,2),
								Reim_closing numeric(18,2),
								for_date datetime                            
                           )                    
                    
                   exec SP_REIM_CLOSING_AS_ON_DATE @CMP_ID	= @Cmp_Id,@EMP_ID = @Emp_Id,@FOR_DATE = @app_date,@RC_ID = @Rc_Id,@Return_Type = 1
                   
                   select @Reim_Closing = ISNULL(Reim_closing,0) from #Reim_Closing where Emp_Id = @Emp_ID
                   
                   if (@Taxable_amount > @Reim_Closing)
                       begin 
							 Raiserror('@@Negetive Balance is not allow.@@',16,2)				
					         Return 
                       End                  
                  End
                ENd 
                 --Ended
	
			select @RC_APP_ID = Isnull(max(RC_APP_ID),0) + 1  From T0100_RC_Application WITH (NOLOCK)
				
			Insert into T0100_RC_Application(			
			    RC_APP_ID,
				Cmp_ID,
				Emp_ID,
				RC_ID,
				APP_Date,
				APP_Amount,
				APP_Comments,
				APP_Status,
				Leave_From_Date,
				Leave_To_Date,
				Days,
				FY, Tax_Exception, FileName, RC_apr_ID,Is_Manager_Record,S_emp_ID, Taxable_amount,Submit_Flag,Reim_Quar_ID,Quarter_Name)
			 VALUES
			 (
				@RC_APP_ID,
				@Cmp_ID,
				@Emp_ID,
				@RC_ID,
				@APP_Date,
				@APP_Amount,
				@APP_Comments,
				@APP_Status,
				@Leave_From_Date,
				@Leave_To_Date,
				@Days,
				@FY,
				@Taxable,@FileName,@Rc_Apr_ID,@Is_Manager_Record,@S_Emp_ID,@Taxable_amount,@Submit_Flag,@Quarter_ID,@Quarter_Name
			 )	

		-- Add By Mukti 11072016(start)
			exec P9999_Audit_get @table = 'T0100_RC_Application' ,@key_column='RC_APP_ID',@key_Values=@RC_APP_ID,@String=@String_val output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
		-- Add By Mukti 11072016(end)	
				End
	Else if @tran_type = 'U' 
		begin
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table='T0100_RC_Application' ,@key_column='RC_APP_ID',@key_Values=@RC_APP_ID,@String=@String_val output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
			
			Update  T0100_RC_Application 
			set RC_ID = @RC_ID,
				APP_Date = @APP_Date,
				APP_Amount = @APP_Amount,
				APP_Comments = @APP_Comments,
				APP_Status = @APP_Status,
				Leave_From_Date= @Leave_From_Date,
				Leave_To_Date = @Leave_To_Date,
				Days = @Days,
				FY = @FY,
				FileName =@FileName,
				RC_apr_ID = @Rc_Apr_ID,
				Tax_Exception=@Taxable,
				Is_Manager_Record= @Is_Manager_Record,
				S_emp_ID = @S_Emp_ID,
				Taxable_amount = @Taxable_amount,
				Submit_Flag=@Submit_Flag,
				Reim_Quar_ID = @Quarter_ID,
				Quarter_Name = @Quarter_Name
			where RC_APP_ID  = @RC_APP_ID	
			
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table = 'T0100_RC_Application' ,@key_column='RC_APP_ID',@key_Values=@RC_APP_ID,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end) 

		end
	Else if @tran_type = 'D' 
		begin
		
				if Exists(SELECT 1 from T0120_RC_Approval WITH (NOLOCK) where   RC_APP_ID  = @RC_APP_ID and cmp_ID=@Cmp_ID)
					begin
							Raiserror('cant delete records.',16,2)				
							Return 
					end
				else IF Exists(Select 1 From T0115_RC_Level_Approval WITH (NOLOCK) Where RC_App_ID = @RC_APP_ID)	--Added by Ripal 09July2014
					Begin
						Raiserror('cant delete records.',16,2)				
						Return 
					End
				else
					begin
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0100_RC_Application' ,@key_column='RC_APP_ID',@key_Values=@RC_APP_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end)
						delete FROM T0110_RC_Reimbursement_Detail where  RC_APP_ID  = @RC_APP_ID				
						delete from T0110_RC_Dependant_Detail where RC_APP_ID  = @RC_APP_ID				
						Delete From T0110_RC_LTA_Travel_Detail where RC_APP_ID  = @RC_APP_ID
						Delete From T0100_RC_Application where RC_APP_ID  = @RC_APP_ID
					end
		end
	exec P9999_Audit_Trail @CMP_ID,@tran_type,'Reimbursement Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN



