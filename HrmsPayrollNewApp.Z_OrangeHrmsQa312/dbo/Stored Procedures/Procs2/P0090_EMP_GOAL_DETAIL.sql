




------------------------------------------------------------------------------------------------------------------------
-- Date Created: Nilay 05-oct-2009
-- Primary page: T0090_Emp_Goal_Details
------------------------------------------------------------------------------------------------------------------------
---exec P0090_EMP_GOAL_DETAIL  0,26,1,'01-jan-2009','10-jan-2009','31-dec-2009',530,520,1,'I'
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0090_EMP_GOAL_DETAIL]
                 @Emp_Goal_ID numeric(18,0) output
				,@Cmp_ID numeric(18,0)
				,@Goal_ID numeric(18,0)
				,@For_Date DateTime
				,@Start_Date Datetime
				,@End_Date DateTime
				,@Emp_ID Numeric(18,0)
				,@Login_ID numeric(18,0)
				,@Goal_Status numeric(1,0)
				,@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	   if @emp_id = 0 
		 set @emp_id = null
	   if @goal_id = 0 
		 set @goal_id = null
	  if @Login_ID = 0 
	    set @Login_ID = null
	  if @Start_Date = ''  
	    SET @Start_Date  = NULL 
      if @End_Date = ''  
		SET @End_Date  = NULL 
  
		if @tran_type ='I' 
		   begin
		 	select @Emp_Goal_ID = isnull(max(Emp_Goal_ID),0) from T0090_Emp_Goal_Details WITH (NOLOCK)
					if @Emp_Goal_ID is null or @Emp_Goal_ID = 0
						set @Emp_Goal_ID =1
					else
						set @Emp_Goal_ID = @Emp_Goal_ID + 1			
			Insert into T0090_Emp_goal_Details
				(Emp_Goal_ID,Cmp_ID,Goal_ID,For_Date,Start_Date,End_Date,Emp_ID,Login_ID,Goal_Status)
			Values 
				(@Emp_Goal_ID,@Cmp_ID,@Goal_ID,@For_Date,@Start_Date,@End_Date,@Emp_ID,@Login_ID,@Goal_Status)
		  End	
					
	else if @tran_type ='U' 
		begin
					
				Update T0090_Emp_Goal_Details
				 set Emp_Goal_ID = @Emp_Goal_ID,
				     Cmp_ID=@Cmp_ID,
				     For_date=@For_date,
				     Start_Date=@Start_Date,
				     End_Date=@End_date,
				     Emp_ID=@Emp_ID,
				     Login_ID=@Login_ID,
				     Goal_Status=@Goal_Status			
				where Emp_Goal_ID=@Emp_Goal_ID
					
		end
	else if @tran_type ='d'
			Begin	
	 			delete  from T0090_Emp_Goal_Details where Emp_Goal_ID = @Emp_Goal_ID
			End
	RETURN




