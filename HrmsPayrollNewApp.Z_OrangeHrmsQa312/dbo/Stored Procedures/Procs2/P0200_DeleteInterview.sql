



-- =============================================
-- Author:		Sneha
-- ALTER date: 23/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_DeleteInterview]
	@cmp_id as numeric(18,0),
	@exit_id as numeric(18,0),
	@branch_id as numeric(18,0),
	@flag as tinyint = 0   --Added By Jaina 04-06-2016
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	Declare @date as varchar(50)
	Declare @pre as int
	Declare @Setting_value as numeric(18,0)  --Added By Jaina 04-06-2016
	Declare @Approval_id as varchar(250)  --Added By Jaina 04-06-2016
	
    -- Insert statements for procedure here
	--If Not Exists (Select 1 From T0200_Exit_Interview Where cmp_id= @cmp_id and exit_id=@exit_id)
	--	Begin
	--	--	Select @date=interview_date From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id	
	--		--	If @date = null
	--		If Not Exists(Select 1 from T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and interview_date<> null)
	--				Begin
	--					Update T0200_Emp_ExitApplication set status = 'H' Where cmp_id = @cmp_id and exit_id = @exit_id
	--				End
	--			Else
	--				Begin
						
	--				End
	--	End
	--Else
	--	Begin
	--		RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
	--		Select @@Error
	--	End
	IF @FLAG = 1  --ADDED BY JAINA 04-06-2016 (FOR CHANGE NOC STATUS)
		BEGIN
			--P Pending
			IF exists(SELECT exit_id FROM T0200_Emp_ExitApplication WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND EXIT_ID = @EXIT_ID AND status='A')
				BEGIN
					
					RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
					return
				END
			Else
			Begin
			
				UPDATE T0200_EMP_EXITAPPLICATION SET SUP_ACK = 'P' WHERE CMP_ID=@CMP_ID AND EXIT_ID = @EXIT_ID		
			End	
		END
	ELSE
	BEGIN
	
	If @cmp_id <>0
		Begin
			If @branch_id<>0
				Begin
					--- H - HOLD
					--Added By Jaina 04-04-2016 Start
					SELECT @Setting_value = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where Setting_Name = 'Exit Clearance Require' and Cmp_ID = @Cmp_id
					if @Setting_value = 1
					Begin
					
							Select @pre = Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where cmp_id=@cmp_id and Branch_Id = @branch_id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
							If @pre = 1
								Begin
									Update T0200_Emp_ExitApplication set status = 'H' Where cmp_id=@cmp_id and exit_id = @exit_id
									
									--Added By Jaina 04-06-2016									
									DELETE ED FROM T0350_EXIT_CLEARANCE_APPROVAL_DETAIL ED INNER JOIN 
											T0300_EXIT_CLEARANCE_APPROVAL EA ON EA.APPROVAL_ID = ED.APPROVAL_ID
									WHERE EA.CMP_ID = @CMP_ID AND EA.EXIT_ID = @EXIT_ID
								
									DELETE FROM T0300_EXIT_CLEARANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
								
									DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID
								
								End
							Else If @pre = 0
								Begin
									If Exists (Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id= @cmp_id and exit_id=@exit_id)
										Begin
											If Exists (Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id= @cmp_id and exit_id=@exit_id)
												Begin
													Delete From T0200_Exit_Feedback Where cmp_id = @cmp_id and exit_id=@exit_id
												End
											Delete From T0200_Exit_Interview Where cmp_id = @cmp_id and exit_id = @exit_id
										End
										Update T0200_Emp_ExitApplication Set status = 'H',interview_date=null,interview_time='' where cmp_id = @cmp_id and exit_id=@exit_id
								
										--Added By Jaina 04-06-2016									
									DELETE ED FROM T0350_EXIT_CLEARANCE_APPROVAL_DETAIL ED INNER JOIN 
											T0300_EXIT_CLEARANCE_APPROVAL EA ON EA.APPROVAL_ID = ED.APPROVAL_ID
									WHERE EA.CMP_ID = @CMP_ID AND EA.EXIT_ID = @EXIT_ID
								
									DELETE FROM T0300_EXIT_CLEARANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
								
									DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID
									
								End
						END
					Else
						Begin
							
							Select @pre = Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where cmp_id=@cmp_id and Branch_Id = @branch_id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
							If @pre = 1
							Begin
								Update T0200_Emp_ExitApplication set status = 'H' Where cmp_id=@cmp_id and exit_id = @exit_id
								
								if exists (SELECT 1 FROM T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Cmp_id=@Cmp_id and Exit_id =@exit_id)  --Added by Jaina 16-07-2018
								BEGIN
									DELETE FROM T0300_Emp_Exit_Approval_Level where Cmp_id=@Cmp_id and Exit_id =@exit_id
								END
								
							End
							Else If @pre = 0
							Begin
								If Exists (Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id= @cmp_id and exit_id=@exit_id)
									Begin
										If Exists (Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id= @cmp_id and exit_id=@exit_id)
										Begin
												Delete From T0200_Exit_Feedback Where cmp_id = @cmp_id and exit_id=@exit_id
										End
										Delete From T0200_Exit_Interview Where cmp_id = @cmp_id and exit_id = @exit_id
									End
									Update T0200_Emp_ExitApplication Set status = 'H',interview_date=null,interview_time='' where cmp_id = @cmp_id and exit_id=@exit_id
									
									DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID  --Added By Jaina 14-06-2016
									
							End
						End
			
	
			End
		End
	
	End
END




