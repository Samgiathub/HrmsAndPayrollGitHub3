



-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <19/05/2015>
-- Description:	<Add PreCompOff Application>
-- =============================================
CREATE PROCEDURE [dbo].[P0110_PrecompOff_Application]
@PreCompOff_App_ID numeric(18,0) output,
@PreCompOff_App_date datetime,
@cmp_ID numeric(18,0),
@Emp_ID numeric(18,0),
@SEmp_ID numeric(18,0),
@From_Date datetime,
@To_Date datetime,
@Period numeric(18,2),
@Remarks nvarchar(250),
@App_Status char(1),
@Tran_Type char(1),
@Direct_Approval	Numeric = 0, --Ankit 14032016	/* SP Execute Direct From Pre-Compoff Approval */
@User_Id numeric(18,0) = 0, -- Add By Mukti 05072016
@IP_Address varchar(30)= '' -- Add By Mukti 05072016
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	       set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  --added by mansi 091221  
			
		DECLARE @Today_Date DATETIME
		SET @Today_Date = Convert(Datetime,CONVERT(VARCHAR(15),getdate(),111))
		
		 -- Add By Mukti 05072016(start)
			declare @OldValue as  varchar(max)
			Declare @String as varchar(max)
			set @String=''
			set @OldValue =''
		 -- Add By Mukti 05072016(end)	
 
		IF @Direct_Approval = 0
			BEGIN
				IF @From_Date < @Today_Date OR @To_Date < @Today_Date
					BEGIN
						Raiserror('@@ Pre-Compoff Previous Date Application are not allowed. @@',18,2)
						RETURN -1	
					END
			END
			
	Create table #Exists_Application
	(
		App_Id  numeric(18,0),
		Emp_Id  numeric(18,0),
		cmp_id numeric(18,0),
		For_date datetime
	)		
				
		  --  Insert into #Exists_Application(App_Id,Emp_Id,cmp_id,For_date)
	Declare @cur_App_ID numeric(18,0)
	Declare @Cur_emp_Id numeric(18,0)
	Declare @Cur_cmp_ID numeric(18,0)
	Declare @Cur_From_date datetime
	Declare @Cur_To_date datetime
		    
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
			
		  			
			
	IF @Tran_Type = 'I'
		begin 
		
			IF not exists( select 1 from T0095_EMP_SCHEME WITH (NOLOCK) where Type = 'Pre-CompOff' and Emp_ID = @Emp_ID and cmp_ID = @cmp_ID) AND @Direct_Approval = 0
			begin
				Raiserror('@@Pre-CompOff scheme is not assigned, So you can not apply for Pre-Compoff @@',18,2)
				return -1	
			end
				
			select @PreCompOff_App_ID = isnull(max(precompOff_App_ID),0) + 1 from [T0110_PrecompOff_Application] WITH (NOLOCK)
			
			
			if exists ( select 1 from #Exists_Application  where For_date >=@from_date and For_date <=@To_Date and Emp_Id = @Emp_ID and cmp_id = @cmp_ID)
			 begin
				Raiserror('@@Duplicates dates, Already Exists application for these dates@@',18,2)
							return -1		
			 end
			 
			 
			Insert into [T0110_PrecompOff_Application]
			(
				PreCompOff_App_ID,
				PreCompOff_App_date,
				cmp_ID,
				Emp_ID,
				S_Emp_ID,
				From_Date,
				To_Date,
				Period,
				Remarks,
				App_Status
			)
			values
			(
				@PreCompOff_App_ID,
				@PreCompOff_App_date,
				@cmp_ID,
				@Emp_ID,
				@SEmp_ID,
				@From_Date,
				@To_Date,
				@Period,
				@Remarks,
				@App_Status
			)
			
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0110_PrecompOff_Application' ,@key_column='PreCompOff_App_ID',@key_Values=@PreCompOff_App_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			-- Add By Mukti 05072016(end)	
		end
	else if @Tran_Type = 'U'
		begin
				
				if exists ( select 1 from #Exists_Application  where For_date >=@from_date and For_date <=@To_Date and Emp_Id = @Emp_ID and cmp_id = @cmp_ID and App_Id <> @PreCompOff_App_ID)
				 begin
					Raiserror('@@Duplicates dates, Already Exists application for these dates@@',18,2)
								return -1		
				 end
					
				IF exists(select 1 from [T0110_PrecompOff_Application] WITH (NOLOCK) where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID)
					begin
					 -- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table='T0110_PrecompOff_Application' ,@key_column='PreCompOff_App_ID',@key_Values=@PreCompOff_App_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					 -- Add By Mukti 05072016(end)
					 
						update [T0110_PrecompOff_Application]
						set  EMP_ID =  @Emp_ID, 
							 S_Emp_ID =@SEmp_ID, 
							 From_Date = @From_Date, 
							 To_Date = @To_Date, 
							 Period  = @Period ,
							 Remarks = @Remarks,
							 PreCompOff_App_date = @PreCompOff_App_date,
							 App_Status = @App_Status
						 where PreCompOff_App_ID = @PreCompOff_App_ID and cmp_ID = @Cmp_ID	 
						 
					 -- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table = 'T0110_PrecompOff_Application' ,@key_column='PreCompOff_App_ID',@key_Values=@PreCompOff_App_ID,@String=@String output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					 -- Add By Mukti 05072016(end)     
					end
				else
					begin
						Raiserror('@@can''t update Pre comp-Off Application, It''s not Exists @@',18,2)
							return -1	
					end
					
		end
	else if @Tran_Type = 'D'
		begin
		
			IF exists( select 1 from T0120_CompOff_Approval WITH (NOLOCK) where  Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Emp_ID = @emp_ID and Cmp_ID = @cmp_ID)
				begin
						Raiserror('@@can''t Delete Pre comp-Off Application, Reference Exists @@',18,2)
							return -1
				end
			IF exists(select 1 from [T0110_PrecompOff_Application] WITH (NOLOCK) where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID)
				begin
					If exists(select 1 from [T0115_PreCompOff_Approval_Level] WITH (NOLOCK) where PreCompOff_App_ID = @PreCompOff_App_ID and cmp_ID = @cmp_ID)
						begin
							Raiserror('@@can''t delete Pre comp-Off Application, Reference Exists @@',18,2)
							return -1	
						end
						
					-- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table='T0110_PrecompOff_Application' ,@key_column='PreCompOff_App_ID',@key_Values=@PreCompOff_App_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					-- Add By Mukti 05072016(end)
					 	
					delete from [T0110_PrecompOff_Application] where  PreCompOff_App_ID = @PreCompOff_App_ID  and cmp_ID = @cmp_ID
				end	
			else
				begin
							Raiserror('@@can''t Delete Pre comp-Off Application, It''s not Exists @@',18,2)
							return -1
				end			
		end
   exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Pre Comp-off Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
END

