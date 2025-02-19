


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <22/05/2015>
-- Description:	<Add PreCompOff Application>
-- =============================================
CREATE PROCEDURE [dbo].[P0120_PrecompOff_Approval_Level]
@Tran_ID numeric(18,0) output,
@PreCompOff_App_ID numeric(18,0),
@PrecompOff_App_Date datetime,
@PreCompOff_Apr_Date datetime,
@cmp_ID numeric(18,0),
@Emp_ID numeric(18,0),
@SEmp_ID numeric(18,0),
@From_Date datetime,
@To_Date datetime,
@Period numeric(18,2),
@Remarks nvarchar(250),
@Apr_Status char(1),
@RPT_Level tinyint,
@Final_Approval tinyint,
@Is_FWD_REJECT tinyint,
@Trans_Type char(1)
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
			select @Tran_ID = isnull(max(Tran_ID),0) + 1 from [dbo].[T0115_PrecompOff_Approval_Level]
			Insert into T0115_PrecompOff_Approval_Level
			(
				Tran_ID,
				PreCompOff_App_ID,
				PrecompOff_App_Date,
				PreCompOff_Apr_Date,
				cmp_ID,
				Emp_ID,
				S_Emp_ID,
				From_Date,
				To_Date,
				Period,
				Remarks,
				Approval_Status,
				RPT_Level,
				Final_Approval,
				Is_FWD_REject
			)
			values
			(
				@Tran_ID,
				@PreCompOff_App_ID,
				@PrecompOff_App_Date,
				@PreCompOff_Apr_Date,
				@cmp_ID,
				@Emp_ID,
				@SEmp_ID,
				@From_Date,
				@To_Date,
				@Period,
				@Remarks,
				@Apr_Status,
				@RPT_Level,
				@Final_Approval,
				@Is_FWD_REJECT
			)
		end
	else if @Trans_Type = 'U'
		begin
				IF exists(select 1 from T0115_PrecompOff_Approval_Level WITH (NOLOCK) where  Tran_ID = @Tran_ID  and cmp_ID = @cmp_ID)
					begin
						update T0115_PrecompOff_Approval_Level
						set  EMP_ID =  @Emp_ID, 
							 S_Emp_ID =@SEmp_ID, 
							 From_Date = @From_Date, 
							 To_Date = @To_Date, 
							 Period  = @Period ,
							 Remarks = @Remarks,
							 Approval_Status = @Apr_Status,
							 RPT_Level=  @RPT_Level,
							 Final_Approval = @Final_Approval,
							 PrecompOff_App_Date = @PreCompOff_App_Date,
							 PreCompOff_Apr_Date = @PreCompOff_Apr_Date,
							 Is_Fwd_Reject = @Is_FWD_REJECT
						 where Tran_ID = @Tran_ID and cmp_ID = @Cmp_ID	 
					end
				else
					begin
						Raiserror('@@can''t update Pre comp-Off Approval, It''s not Exists @@',18,2)
							return -1	
					end
					
		end
	else if @Trans_Type = 'D'
		begin
					
			if exists(select 1 from T0115_PreCompOff_Approval_Level WITH (NOLOCK) where RPT_Level = @RPT_Level + 1 and cmp_ID = @cmp_ID and Emp_ID = @Emp_ID and PreCompOff_App_ID = @PreCompOff_App_ID)
				begin
						Raiserror('@@can''t Delete Pre comp-Off Approval, Reference Exists @@',18,2)
							return -1
				end
			IF exists(select 1 from T0115_PrecompOff_Approval_Level WITH (NOLOCK) where  Tran_ID = @Tran_ID  and cmp_ID = @cmp_ID)
				begin
					delete from T0115_PrecompOff_Approval_Level where  Tran_ID = @Tran_ID  and cmp_ID = @cmp_ID
				end	
			else
				begin
							Raiserror('@@can''t Delete Pre comp-Off Approval, It''s not Exists @@',18,2)
							return -1
				end			
		end
  
  
END

