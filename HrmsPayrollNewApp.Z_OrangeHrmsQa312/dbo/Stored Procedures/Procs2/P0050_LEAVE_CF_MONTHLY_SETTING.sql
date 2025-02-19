
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_MONTHLY_SETTING]
	 @Leave_Tran_ID numeric output
	,@Leave_ID numeric 
	,@For_Date datetime
	,@Cmp_ID numeric
	,@CF_M_Days numeric(18,2)
	,@CF_M_DaysAfterJoining numeric(18,2)
    ,@tran_type char(1)
    ,@Effective_Date datetime
    ,@Type_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF Day(@For_Date) > 1
		SET @For_Date  = DateAdd(D, (Day(@For_Date)-1) * -1, @For_Date)


	If @tran_type IN ('I', 'U')
		BEGIN
			SET @Leave_Tran_ID = 0
			
			SELECT	@Leave_Tran_ID = Leave_Tran_ID 
			From	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
			Where	Leave_ID =@LeavE_ID AND Month(For_Date) = Month(@for_Date) AND Cmp_ID =@Cmp_ID 
					AND Effective_Date=@Effective_Date AND Type_ID = @Type_ID
			
			IF IsNull(@Leave_Tran_ID,0) > 0
				BEGIN					
					UPDATE  T0050_LEAVE_CF_MONTHLY_SETTING
					SET		CF_M_Days = @CF_M_Days,
							CF_M_DaysAfterJoining = @CF_M_DaysAfterJoining
					WHERE	Leave_Tran_ID = @Leave_Tran_ID
				END
			ELSE
				BEGIN
					SELECT @Leave_Tran_ID = ISNULL(MAX(Leave_Tran_ID),0) + 1 	From T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
					
					INSERT INTO T0050_LEAVE_CF_MONTHLY_SETTING
										  (Leave_ID, For_Date, Cmp_Id, CF_M_Days, CF_M_DaysAfterJoining, Leave_Tran_ID, Effective_Date,Type_ID)
					VALUES     (@Leave_ID,@For_Date,@Cmp_Id,@CF_M_Days, @CF_M_DaysAfterJoining, @Leave_Tran_ID,@Effective_Date,@Type_ID)					
				END
		END
	--Else if @Tran_Type = 'U'
	--	begin
	--		SET @Leave_Tran_ID = 0
			
	--		SELECT	@Leave_Tran_ID = Leave_Tran_ID 
	--		From	T0050_LEAVE_CF_MONTHLY_SETTING 
	--		Where	Leave_ID =@LeavE_ID AND Month(For_Date) = Month(@for_Date) AND Cmp_ID =@Cmp_ID 
	--				AND Effective_Date=@Effective_Date AND Type_ID = @Type_ID
					
	--		if not exists(select Leave_ID From T0050_LEAVE_CF_MONTHLY_SETTING Where Leave_ID =@LeavE_ID and For_Date =@for_Date and Cmp_ID =@Cmp_ID and Effective_Date=@Effective_Date AND Type_ID = @Type_ID)
	--			begin
	--				select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 	From T0050_LEAVE_CF_MONTHLY_SETTING
	--				INSERT INTO T0050_LEAVE_CF_MONTHLY_SETTING
	--									  (Leave_ID, For_Date, Cmp_Id, CF_M_Days, Leave_Tran_ID,Effective_Date,Type_ID)
	--				VALUES     (@Leave_ID,@For_Date,@Cmp_Id,@CF_M_Days,@Leave_Tran_ID,@Effective_Date,@Type_ID)					

	--			end 
	--		else
	--			begin
	--				UPDATE    T0050_LEAVE_CF_MONTHLY_SETTING
	--				SET       CF_M_Days = @CF_M_Days
	--						 ,Effective_Date = @Effective_Date
	--				WHERE     For_Date = @For_Date and Leave_ID = @Leave_ID   AND Type_ID = @Type_ID
					
	--				set @Leave_Tran_ID = 1
	--			end 
		
	--	   end
	ELSE IF @Tran_Type = 'D'
		BEGIN
			DELETE FROM T0050_LEAVE_CF_MONTHLY_SETTING 	WHERE (Leave_ID = @Leave_ID)	
		END

	RETURN




