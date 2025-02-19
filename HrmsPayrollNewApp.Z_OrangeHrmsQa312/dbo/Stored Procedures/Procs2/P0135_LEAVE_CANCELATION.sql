




CREATE PROCEDURE [dbo].[P0135_LEAVE_CANCELATION]
	@LV_Can_Tran_ID	    Numeric output
	,@Cmp_ID	        numeric
	,@Emp_ID	        numeric
	,@Leave_Approval_ID	numeric
	,@Leave_ID	        Numeric
	,@Leave_Period	    Numeric(5,1)
	,@For_Date	        Datetime
	,@In_Time	        Datetime
	,@Out_Time	        Datetime
	,@LV_Can_Period	    Numeric(5,1)
	,@LV_Can_Status	    Numeric
	,@LV_Can_Comments	varchar(250)
	,@tran_type	        varchar(1)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


		If @LV_Can_Status = 0 
			set @LV_Can_Period = 0
			
		if @Tran_type ='I' 
			begin
			if exists (Select LV_Can_Tran_ID  from T0135_LEAVE_CANCELATION WITH (NOLOCK) Where Emp_ID=@Emp_ID and Cmp_ID = @Cmp_ID and For_Date = @For_Date) 
				begin
					Select @LV_Can_Tran_ID = LV_Can_Tran_ID  from T0135_LEAVE_CANCELATION WITH (NOLOCK) Where Emp_ID=@Emp_ID and Cmp_ID = @Cmp_ID and For_Date = @For_Date
					/*UPDATE  T0135_LEAVE_CANCELATION
					SET              
								Leave_Period=@Leave_Period,
								LV_Can_Day =@LV_Can_Period,
								LV_Can_Status =@LV_Can_Status,
								LV_Can_Comments=@LV_Can_Comments
								 where LV_Can_Tran_ID = @LV_Can_Tran_ID  and For_Date=@For_Date and Emp_ID=@Emp_ID
					*/
					Delete T0135_LEAVE_CANCELATION Where Cmp_ID = @Cmp_ID And LV_Can_Tran_ID = @LV_Can_Tran_ID
					Select @LV_Can_Tran_ID = isnull(max(LV_Can_Tran_ID),0) + 1  from T0135_LEAVE_CANCELATION WITH (NOLOCK)
					INSERT INTO T0135_LEAVE_CANCELATION
					(LV_Can_Tran_ID
					,Cmp_ID
					,Emp_ID
					,Leave_Approval_ID
					,Leave_ID
					,Leave_Period
					,For_Date
					,In_Time
					,Out_Time
					,LV_Can_Day
					,LV_Can_Status
					,LV_Can_Comments)
					VALUES   
					(@LV_Can_Tran_ID
						,@Cmp_ID
						,@Emp_ID
						,@Leave_Approval_ID
						,@Leave_ID
						,@LV_Can_Period
						,@For_Date
						,@In_Time
						,@Out_Time
						,@LV_Can_Period
						,@LV_Can_Status
						,@LV_Can_Comments
						)			 
				end
			else
				begin
				
					Select @LV_Can_Tran_ID = isnull(max(LV_Can_Tran_ID),0) + 1  from T0135_LEAVE_CANCELATION WITH (NOLOCK)
					INSERT INTO T0135_LEAVE_CANCELATION
					(LV_Can_Tran_ID
					,Cmp_ID
					,Emp_ID
					,Leave_Approval_ID
					,Leave_ID
					,Leave_Period
					,For_Date
					,In_Time
					,Out_Time
					,LV_Can_Day
					,LV_Can_Status
					,LV_Can_Comments)
					VALUES   
					(@LV_Can_Tran_ID
						,@Cmp_ID
						,@Emp_ID
						,@Leave_Approval_ID
						,@Leave_ID
						,@LV_Can_Period
						,@For_Date
						,@In_Time
						,@Out_Time
						,@LV_Can_Period
						,@LV_Can_Status
						,@LV_Can_Comments
						)
					end
				end 
		else if @tran_type ='D'
		
			DELETE FROM T0135_LEAVE_CANCELATION where LV_Can_Tran_ID = @LV_Can_Tran_ID
	



