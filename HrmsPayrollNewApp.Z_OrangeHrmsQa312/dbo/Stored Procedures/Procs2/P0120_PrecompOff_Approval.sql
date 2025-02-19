

-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <19/05/2015>
-- Description:	<Add PreCompOff Application>
-- =============================================
CREATE PROCEDURE [dbo].[P0120_PrecompOff_Approval]
@PreCompOff_Apr_ID numeric(18,0) output,
@PreCompOff_App_ID numeric(18,0),
@cmp_ID numeric(18,0),
@Emp_ID numeric(18,0),
@SEmp_ID numeric(18,0),
@From_Date datetime,
@To_Date datetime,
@Period numeric(18,2),
@Remarks nvarchar(250),
@Apr_Status char(1),
@Ess_Flag	tinyint,
@Trans_Type char(1),
@User_Id numeric(18,0) = 0, -- Add By Mukti 05072016
@IP_Address varchar(30)= '' -- Add By Mukti 05072016
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	---- Cross Company Manager Approved then Employee Cmp ID must be save in table - Ankit 01082016
	SELECT @cmp_ID = Cmp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID
	
		
	Create table #Exists_Application
	(
		App_Id  numeric(18,0),
		Emp_Id  numeric(18,0),
		cmp_id numeric(18,0),
		For_date datetime
	)	
	
	Declare @cur_App_ID numeric(18,0)
	Declare @Cur_emp_Id numeric(18,0)
	Declare @Cur_cmp_ID numeric(18,0)
	Declare @Cur_From_date datetime
	Declare @Cur_To_date datetime
  
	-- Add By Mukti 05072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
	-- Add By Mukti 05072016(end)	
	
		    Declare CurApplication cursor for 
				select PreCompOff_App_ID,Emp_ID,cmp_ID,From_Date,To_Date from T0110_PrecompOff_Application WITH (NOLOCK)
				 where Cmp_ID = @cmp_ID and Emp_ID =@Emp_ID			
			Open CurApplication
				Fetch next from CurApplication into @Cur_App_ID ,@Cur_Emp_ID,@Cur_cmp_ID,@Cur_From_Date,@Cur_to_Date
			 while @@FETCH_STATUS = 0
			    begin
			    	
			    		exec getAllDaysBetweenTwoDate @cur_From_Date,@Cur_To_date
			    		
			    		Insert into #Exists_Application
			    			select @cur_App_ID,@Cur_emp_Id,@Cur_cmp_ID,test1 from test1
			    	 		 
			    			 
				 Fetch next from CurApplication into @Cur_App_ID ,@Cur_Emp_ID,@Cur_cmp_ID,@Cur_From_Date,@Cur_to_Date
				end
			close CurApplication
			deallocate curApplication


			if exists ( select 1 from #Exists_Application  where For_date >=@from_date and For_date <=@To_Date and Emp_Id = @Emp_ID and cmp_id = @cmp_ID and App_Id <> @PreCompOff_App_ID)
			 begin
				Raiserror('@@Duplicates dates, Already Exists application for these dates@@',18,2)
							return -1		
			 end


	IF @Trans_Type = 'I'
		begin 
			If @Ess_Flag = 0 AND @PreCompOff_App_ID = 0	--Direct Approval From Admin Panel --Ankit 14032016
				BEGIN
					DECLARE @PreCompOff_App_date DATETIME
					
					SET @PreCompOff_App_ID = 0
					SET @PreCompOff_App_date = CONVERT(DATETIME,CONVERT(VARCHAR(15),GETDATE(),111))
					
					EXEC P0110_PrecompOff_Application @PreCompOff_App_ID OUTPUT,@PreCompOff_App_date,@cmp_ID,@Emp_ID,@SEmp_ID,@From_Date,@To_Date,@Period,'Admin - Direct Approval','A','I',1
					
				END
				
			select @PreCompOff_Apr_ID = isnull(max(precompOff_Apr_ID),0) + 1 from [T0120_PreCompOff_Approval] WITH (NOLOCK) 
			
			
			Insert into [T0120_PreCompOff_Approval]
			(
				PreCompOff_Apr_ID,
				PreCompOff_App_ID,
				cmp_ID,
				Emp_ID,
				S_Emp_ID,
				From_Date,
				To_Date,
				Period,
				Remarks,
				Approval_Status
			)
			values
			(
				@PreCompOff_Apr_ID,
				@PreCompOff_App_ID,
				@cmp_ID,
				@Emp_ID,
				@SEmp_ID,
				@From_Date,
				@To_Date,
				@Period,
				@Remarks,
				@Apr_Status
			)
			
			
			Update T0110_PrecompOff_Application set App_Status = @Apr_Status where  PreCompOff_App_ID = @PreCompOff_App_ID and cmp_ID = @cmp_ID
			
		-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0120_PreCompOff_Approval' ,@key_column='PreCompOff_Apr_ID',@key_Values=@PreCompOff_Apr_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	 
		end
	else if @Trans_Type = 'U'
		begin
				
				IF exists(select 1 from [T0110_PrecompOff_Application] WITH (NOLOCK) where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID)
					begin
					 -- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table='T0120_PreCompOff_Approval' ,@key_column='PreCompOff_Apr_ID',@key_Values=@PreCompOff_Apr_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					 -- Add By Mukti 05072016(end)
	   
						update T0120_PreCompOff_Approval
						set  EMP_ID =  @Emp_ID, 
							 S_Emp_ID =@SEmp_ID, 
							 From_Date = @From_Date, 
							 To_Date = @To_Date, 
							 Period  = @Period ,
							 Remarks = @Remarks,
							 Approval_Status = @Apr_Status
						 where PreCompOff_Apr_ID = @PreCompOff_Apr_ID and cmp_ID = @Cmp_ID	 
						 
						 Update T0110_PrecompOff_Application set App_Status = @Apr_Status where  PreCompOff_App_ID = @PreCompOff_App_ID and cmp_ID = @cmp_ID
						 
					-- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table = 'T0120_PreCompOff_Approval' ,@key_column='PreCompOff_Apr_ID',@key_Values=@PreCompOff_Apr_ID,@String=@String output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					-- Add By Mukti 05072016(end)  
					end
				else
					begin
						Raiserror('@@can''t update Pre comp-Off Approval, It''s not Exists @@',18,2)
							return -1	
					end
					
		end
	else if @Trans_Type = 'D'
		begin
			
			IF exists( select 1 from T0120_CompOff_Approval WITH (NOLOCK) where  Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Emp_ID = @emp_ID and Cmp_ID = @cmp_ID)
				begin
						Raiserror('@@can''t Delete Pre comp-Off Approval, Reference Exists @@',18,2)
							return -1
				end
			IF exists(select 1 from [T0120_PreCompOff_Approval] WITH (NOLOCK) where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID)
				begin
					 -- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table='T0120_PreCompOff_Approval' ,@key_column='PreCompOff_Apr_ID',@key_Values=@PreCompOff_Apr_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					 -- Add By Mukti 05072016(end)
					 
					delete from [T0120_PreCompOff_Approval] where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID
					If @Ess_Flag = 1
						delete from T0115_PreCompOff_Approval_Level where PreCompOff_App_ID  = @PreCompOff_App_ID and Final_Approval = 1 and cmp_ID = @cmp_ID
					 else
						delete from T0115_PreCompOff_Approval_Level where PreCompOff_App_ID  = @PreCompOff_App_ID and cmp_ID = @cmp_ID
						
					Update T0110_PrecompOff_Application set App_Status = 'P' where  PreCompOff_App_ID = @PreCompOff_App_ID and cmp_ID = @cmp_ID
					
				end
			else
				begin
							Raiserror('@@can''t Delete Pre comp-Off Approval, It''s not Exists @@',18,2)
							return -1
				end		
		 	--ELSE IF EXISTS (SELECT 1 FROM T0115_PreCompOff_Approval_Level WHERE PreCompOff_App_ID  = @PreCompOff_App_ID)	--'' Unable to Rollback - Ankit 02082016
		 	 IF EXISTS (SELECT 1 FROM T0115_PreCompOff_Approval_Level WITH (NOLOCK) WHERE PreCompOff_App_ID  = @PreCompOff_App_ID)	--'' changed by jimit 24112016 
				BEGIN 
				
				
					DECLARE @MaxTranID NUMERIC
					SET @MaxTranID = 0
					
					SELECT @MaxTranID = Tran_ID  FROM T0115_PreCompOff_Approval_Level WITH (NOLOCK)
					WHERE  PreCompOff_App_ID = @PreCompOff_App_ID AND Rpt_Level IN (SELECT MAX(Rpt_Level) FROM T0115_PreCompOff_Approval_Level WITH (NOLOCK) WHERE PreCompOff_App_ID=@PreCompOff_App_ID )
			
			
			
					DELETE FROM T0115_PreCompOff_Approval_Level
					WHERE PreCompOff_App_ID  = @PreCompOff_App_ID 
					AND cmp_ID = @cmp_ID AND Tran_ID = @MaxTranID
					And S_Emp_ID = @SEmp_ID    --added by jimit 24112016 need to rollback only from respective RM
					
					UPDATE T0110_PrecompOff_Application SET App_Status = 'P' WHERE  PreCompOff_App_ID = @PreCompOff_App_ID AND cmp_ID = @cmp_ID
					
				END
					
		end
  exec P9999_Audit_Trail @CMP_ID,@Trans_Type,'Pre Comp-off Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
END

