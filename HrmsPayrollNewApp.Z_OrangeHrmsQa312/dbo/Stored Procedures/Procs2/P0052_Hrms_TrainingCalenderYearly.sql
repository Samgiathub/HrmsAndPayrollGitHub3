


-- =============================================
-- AUTHOR:		<AUTHOR,,GADRIWALA MUSLIM>
-- CREATE DATE: <ALTER DATE,,28102016>
-- DESCRIPTION:	<DESCRIPTION,,NEW CODE DEVELOPED AS PER NEW YEARLY CALENDAR FLOW>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_Hrms_TrainingCalenderYearly]
	  @Training_CalenderId			numeric(18,0) out
      ,@Cmp_Id						numeric(18,0)
      ,@Calender_Year				numeric(18,0)
      ,@Calender_Month				numeric(18,0)
      ,@Training_Id					numeric(18,0)
      ,@Branch_ID					varchar(max)
      ,@TransType					varchar(1)
      ,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015
      ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
	  -- @ROW_ID			NUMERIC(18,0) OUTPUT
	  --,@EVENT_ID		NUMERIC(18,0) 
   --   ,@CMP_ID			NUMERIC(18,0)
   --   ,@TRAINING_DATE	DATETIME
   --   ,@TRAINING_ID		NUMERIC(18,0)
   --   ,@Branch_ID		varchar(max)
   --   ,@TRANSTYPE		VARCHAR(1)
   --   ,@USER_ID			NUMERIC(18,0) = 0 
	  --,@IP_ADDRESS		VARCHAR(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
--Added By Mukti 19082015(start)
	declare @OldValue as varchar(max)
	declare @OldCalender_Year	varchar(20)
    declare @OldCalender_Month	varchar(20)
    declare @OldTraining_Id	varchar(20)
--Added By Mukti 19082015(end) 
	if upper(@TransType) = 'I'
		begin
			if exists (Select 1 from T0052_Hrms_TrainingCalenderYearly WITH (NOLOCK) where cmp_id = @Cmp_Id and Calender_Year = @Calender_Year and (Calender_Month = @Calender_Month) and Training_Id = @Training_Id)
				begin
					 set @Training_CalenderId = 0
					 Return 
				End
			Else
				Begin
					select @Training_CalenderId = isnull(MAX(Training_CalenderId),0)+1  from T0052_Hrms_TrainingCalenderYearly WITH (NOLOCK)
					Insert Into T0052_Hrms_TrainingCalenderYearly
					(
						 Training_CalenderId
						,Cmp_Id
						,Calender_Year
						,Calender_Month
						,Training_Id
						,Branch_ID
					)
					Values
					(
						 @Training_CalenderId
						,@Cmp_Id
						,@Calender_Year
						,@Calender_Month
						,@Training_Id
						,@Branch_ID
					)
		--Added By Mukti 19082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Training Calender Id:' + cast(Isnull(@Training_CalenderId,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Calender Year:' + cast(Isnull(@Calender_Year,0) as varchar(25)) + '#' + 
													'Calender Month:' + cast(Isnull(@Calender_Month,0) as varchar(25)) + '#' + 
													'Training_Id:' + cast(Isnull(@Training_Id,0) as varchar(25)) 
													
		--Added By Mukti 19082015(end)			
				End
		End
	Else if upper(@TransType) = 'U'
		begin
			if exists (Select 1 from T0052_Hrms_TrainingCalenderYearly WITH (NOLOCK) where cmp_id = @Cmp_Id and Calender_Year = @Calender_Year and (Calender_Month = @Calender_Month ) and Training_Id = @Training_Id and Training_CalenderId <> @Training_CalenderId)
				Begin	
					set @Training_CalenderId = 0
					Return
				End
			Else
				Begin
		--Added By Mukti 19082015(start)
					select  @OldCalender_Month = Calender_Month,@OldCalender_Year=Calender_Year
							,@OldTraining_Id  = Training_Id
					from T0052_Hrms_TrainingCalenderYearly 	WITH (NOLOCK) Where Training_CalenderId = @Training_CalenderId
		--Added By Mukti 19082015(end)	
			
					Update T0052_Hrms_TrainingCalenderYearly
					set	     Calender_Month = @Calender_Month
							,Training_Id  = @Training_Id
							,Branch_ID=@Branch_ID
					Where Training_CalenderId = @Training_CalenderId
					
		--Added By Mukti 19082015(start)
			    set @OldValue = 'Old Value' + '#'+ 'Training Calender Id:' + cast(Isnull(@Training_CalenderId,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Calender Year:' + cast(Isnull(@OldCalender_Year,0) as varchar(25)) + '#' + 
													'Calender Month:' + cast(Isnull(@OldCalender_Month,0) as varchar(25)) + '#' + 
													'Training_Id:' + cast(Isnull(@OldTraining_Id,0) as varchar(25)) + '#' + 
								'New Value' + '#'+ 'Training Calender Id:' + cast(Isnull(@Training_CalenderId,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Calender Year:' + cast(Isnull(@Calender_Year,0) as varchar(25)) + '#' + 
													'Calender Month:' + cast(Isnull(@Calender_Month,0) as varchar(25)) + '#' + 
													'Training_Id:' + cast(Isnull(@Training_Id,0) as varchar(25)) 
													
		--Added By Mukti 19082015(end)					
				End
		End
	Else if upper(@TransType) = 'D'
		Begin
		--Added By Mukti 19082015(start)
					select  @OldCalender_Month = Calender_Month,@OldCalender_Year=Calender_Year
							,@OldTraining_Id  = Training_Id
					from T0052_Hrms_TrainingCalenderYearly 	WITH (NOLOCK) Where Training_CalenderId = @Training_CalenderId
		--Added By Mukti 19082015(end)	
		
			Delete from T0052_Hrms_TrainingCalenderYearly where Training_CalenderId = @Training_CalenderId
			
		--Added By Mukti 19082015(start)
			    set @OldValue = 'Old Value' + '#'+ 'Training Calender Id:' + cast(Isnull(@Training_CalenderId,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'Calender Year:' + cast(Isnull(@OldCalender_Year,0) as varchar(25)) + '#' + 
													'Calender Month:' + cast(Isnull(@OldCalender_Month,0) as varchar(25)) + '#' + 
													'Training_Id:' + cast(Isnull(@OldTraining_Id,0) as varchar(25)) 
		--Added By Mukti 19082015(end)	
		End
	exec P9999_Audit_Trail @Cmp_ID,@TransType,'Training Calendar Year',@OldValue,@Training_CalenderId,@User_Id,@IP_Address
END

--DECLARE @OLDVALUE AS VARCHAR(MAX)
--DECLARE @OLDEVENT_ID AS VARCHAR(20)
--DECLARE @OLDTRAINING_DATE AS VARCHAR(25)
--DECLARE @OLDTRAINING_NAME	VARCHAR(20)

--IF ISNULL(@EVENT_ID,0)  > 0 
--	BEGIN
--			IF ISNULL(@TRAINING_ID,0) > 0 
--				BEGIN
--					SELECT @OLDTRAINING_NAME = TRAINING_NAME FROM T0040_HRMS_TRAINING_MASTER  WHERE TRAINING_ID = @TRAINING_ID
					
--					SET @OLDVALUE = 'NEW VALUE'
--								+ '#'+ 'TRAINING_DATE :' + CAST(ISNULL(@TRAINING_DATE,'')  AS VARCHAR(25))
--								+ '#'+ 'TRAINING_NAME :' + CAST(ISNULL(@OLDTRAINING_NAME,'')  AS VARCHAR(25))
					
--					SELECT @OLDTRAINING_DATE = TRAINING_DATE,
--						   @OLDEVENT_ID = EVENT_ID,
--						   @OLDTRAINING_NAME = (SELECT TRAINING_NAME FROM T0040_HRMS_TRAINING_MASTER TM WHERE TM.TRAINING_ID = TEC.TRAINING_ID) 
--					FROM T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY	TEC
--					WHERE EVENT_ID = @EVENT_ID	
					
--						SET @OLDVALUE = @OLDVALUE + '#' + 'OLD VALUE'
--								+ '#'+ 'TRAINING_DATE :' + ISNULL(@OLDTRAINING_DATE ,'')
--								+ '#'+ 'TRAINING_NAME :' + ISNULL(@OLDTRAINING_NAME,'')
								
--					UPDATE T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY 
--					SET TRAINING_DATE = @TRAINING_DATE,
--						TRAINING_ID = @TRAINING_ID,
--						Branch_ID = @Branch_ID
--					WHERE EVENT_ID = @EVENT_ID	
--				END
--			ELSE
--				BEGIN
--						SELECT @OLDTRAINING_DATE = TRAINING_DATE,
--						   @OLDEVENT_ID = EVENT_ID,
--						   @OLDTRAINING_NAME = (SELECT TRAINING_NAME FROM T0040_HRMS_TRAINING_MASTER TM WHERE TM.TRAINING_ID = TEC.TRAINING_ID) 
--						FROM T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY	TEC
--						WHERE EVENT_ID = @EVENT_ID	
					
--						SET @OLDVALUE = @OLDVALUE + '#' + 'OLD VALUE'
--								+ '#'+ 'TRAINING_DATE :' + ISNULL(@OLDTRAINING_DATE ,'')
--								+ '#'+ 'TRAINING_NAME :' + ISNULL(@OLDTRAINING_NAME,'')
								
--						DELETE FROM T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY 
--						WHERE EVENT_ID = @EVENT_ID
--				END			
--	END
--ELSE
--	BEGIN
--			IF @TRAINING_ID > 0 
--				BEGIN
--					SELECT @OLDTRAINING_NAME = TRAINING_NAME FROM T0040_HRMS_TRAINING_MASTER  WHERE TRAINING_ID = @TRAINING_ID
--					SET @OLDVALUE = 'NEW VALUE'
--								+ '#'+ 'TRAINING_DATE :' + CAST(ISNULL(@TRAINING_DATE,'')  AS VARCHAR(25))
--								+ '#'+ 'TRAINING_NAME :' + CAST(ISNULL(@OLDTRAINING_NAME,'')  AS VARCHAR(25))
					
--				IF NOT EXISTS(SELECT 1 FROM T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY WHERE TRAINING_DATE = @TRAINING_DATE AND CMP_ID = @CMP_ID)
--					BEGIN	
--					PRINT 'k'
--						SELECT @EVENT_ID = ISNULL(MAX(EVENT_ID),0) + 1 FROM T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY
					
--							INSERT INTO T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY(EVENT_ID,CMP_ID,TRAINING_DATE,TRAINING_ID,Branch_ID)
--							VALUES(@EVENT_ID,@CMP_ID,@TRAINING_DATE,@TRAINING_ID,@Branch_ID)
--					END
--				ELSE
--					BEGIN
--						UPDATE T0052_HRMS_TRAINING_EVENT_CALENDER_YEARLY
--							SET TRAINING_ID = @TRAINING_ID,
--							Branch_ID = @Branch_ID
--						WHERE TRAINING_DATE = @TRAINING_DATE AND CMP_ID = @CMP_ID
--					END
--				END
--	END
--	EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRANSTYPE,'TRAINING CALENDAR YEAR',@OLDVALUE,@EVENT_ID,@USER_ID,@IP_ADDRESS
--END

