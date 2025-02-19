



-- =============================================
-- Author:		Sneha
-- ALTER date: 10 Jan 2012
-- Description:	delete exit application
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Delete_ExitApplication]
	@cmp_id as numeric(18,0),
    @exit_id as numeric(18,0),
	@status as char(5)='H'  --Added by Jaina 28-02-2017
	--ronakb 081024
	,@User_Id NUMERIC(18, 0) = 0
	,@IP_Address VARCHAR(30) = ''
	--  @tran_type varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Declare @status char(1)
	Declare @emp_id as numeric(18,0) 
	Declare @Is_Pre as numeric(18,0)
	Declare @branchId as numeric(18,0)
	Declare @left as numeric(18,0)
	Declare @Application_date datetime
	---ronakb 081024
	DECLARE @OldValue AS VARCHAR(max)

	SET @OldValue = ''
	

	--Select @status = status From T0200_Emp_ExitApplication Where cmp_id = @cmp_id And exit_id = @exit_id  --comment by Jaina 28-02-2017
	
	Declare @Setting_value as numeric(18,0)  --Added By Jaina 14-07-2016
	Declare @Approval_id as varchar(250)  --Added By Jaina 14-07-2016
	
	--If @status <> 'A'
	--	Begin
	--		Delete From T0200_Emp_ExitApplication Where cmp_id = @cmp_id And exit_id = @exit_id
	--	End
	--Else
	--	Begin
	--		Select @emp_id = emp_id from T0200_Emp_ExitApplication Where cmp_id = @cmp_id And exit_id = @exit_id
	--		Delete From T0100_LEFT_EMP Where Emp_ID = @emp_id and Cmp_ID=@cmp_id
	--		UPDATE T0080_EMP_MASTER 
	--			SET EMP_LEFT  = 'N' , EMP_LEFT_DATE = null
	--			WHERE EMP_ID = @EMP_ID
	--		Delete From T0200_Emp_ExitApplication Where cmp_id = @cmp_id and exit_id = @exit_id
	--	End
	
	
	If @status = 'R'
		Begin
			--Added by Jaina 15-12-2018
			SELECT @Emp_id = emp_id, @Application_date = Application_date FROM T0200_Emp_ExitApplication WITH (NOLOCK) where exit_id=@exit_id and cmp_id=@cmp_id 			
			if exists (SELECT 1 FROM T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id=@Emp_id and cmp_id=@cmp_id AND Application_date > @Application_date)
			BEGIN
				RAISERROR ('@@Exit Application is already exists@@', 16, 2) 				
				return
			END
			Update T0200_Emp_ExitApplication Set status = 'P' Where cmp_id = @cmp_id and exit_id = @exit_id
		End
	Else If @status = 'P'
		Begin			
		    Select @branchId =  branch_id From T0200_Emp_ExitApplication WITH (NOLOCK) Where exit_id =@exit_id and cmp_id = @cmp_id
				If @branchId <> 0					
					Begin
						--Added By Jaina 14-07-2016 Start
						SELECT @Setting_value = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where Setting_Name = 'Exit Clearance Require' and Cmp_ID = @Cmp_id
						if @Setting_value = 1
						Begin
							Select @Is_Pre =  Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID = @cmp_id and Branch_ID = @branchId and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branchId)  --Modified By Ramiz on 15092014
							If @Is_Pre <> 1
								Begin
								
										Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
										Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
										Update T0200_Emp_ExitApplication Set status = 'H',interview_date=null,interview_time='',Clearance_ManagerID='' where @cmp_id = @cmp_id and exit_id=@exit_id
									
										--Added By Jaina 14-07-2016									
										DELETE ED FROM T0350_EXIT_CLEARANCE_APPROVAL_DETAIL ED INNER JOIN 
												T0300_EXIT_CLEARANCE_APPROVAL EA ON EA.APPROVAL_ID = ED.APPROVAL_ID
										WHERE EA.CMP_ID = @CMP_ID AND EA.EXIT_ID = @EXIT_ID
									
										DELETE FROM T0300_EXIT_CLEARANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
									
										DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID
								END
							Else
								Begin
								
										Update T0200_Emp_ExitApplication Set status = 'H',Clearance_ManagerID='' where @cmp_id = @cmp_id and exit_id=@exit_id
										
										--Added By Jaina 14-07-2016									
										DELETE ED FROM T0350_EXIT_CLEARANCE_APPROVAL_DETAIL ED INNER JOIN 
												T0300_EXIT_CLEARANCE_APPROVAL EA ON EA.APPROVAL_ID = ED.APPROVAL_ID
										WHERE EA.CMP_ID = @CMP_ID AND EA.EXIT_ID = @EXIT_ID
									
										DELETE FROM T0300_EXIT_CLEARANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
									
										DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID
								End
							--Added By Jaina 14-07-2016 End
					END
					ELSE
					BEGIN

								Select @Is_Pre =  Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID = @cmp_id and Branch_ID = @branchId and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branchId)  --Modified By Ramiz on 15092014
								If @Is_Pre <> 1
									Begin
										
										Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
										Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
										Update T0200_Emp_ExitApplication Set status = 'H',interview_date=null,interview_time='' where @cmp_id = @cmp_id and exit_id=@exit_id
									End
								Else
									Begin
										Update T0200_Emp_ExitApplication Set status = 'H' where @cmp_id = @cmp_id and exit_id=@exit_id
									End
							END
					End
			End
			
		Else If @status = 'H'
			Begin
				If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
					Begin
						Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
						Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
						
						if exists (SELECT 1 FROM T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Cmp_id=@Cmp_id and Exit_id =@exit_id)  --Added by Jaina 16-07-2018
						BEGIN
							DELETE FROM T0300_Emp_Exit_Approval_Level where Cmp_id=@Cmp_id and Exit_id =@exit_id
						END
						
						Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id 
					End
				Else
					If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
						Begin
							Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id					
						End
						
					if exists (SELECT 1 FROM T0300_Emp_Exit_Approval_Level WITH (NOLOCK) where Cmp_id=@Cmp_id and Exit_id =@exit_id)  --Added by Jaina 16-07-2018
						BEGIN
							DELETE FROM T0300_Emp_Exit_Approval_Level where Cmp_id=@Cmp_id and Exit_id =@exit_id
						END
						
						Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id 
						
			End
		Else If @status = 'A'
			Begin
				Select @emp_id = emp_id from T0200_Emp_ExitApplication WITH (NOLOCK) Where cmp_id = @cmp_id And exit_id = @exit_id
				If Exists(Select 1 From T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = @cmp_id and Emp_ID=@emp_id and Emp_Left = 'Y' )
					Begin
						RAISERROR ('@@Cannot Delete as Reference Exists,Employee already Left.', 16, 2) 
						Select @@Error
					End
				Else
					Begin
						Update T0200_Emp_ExitApplication Set status = 'P' Where cmp_id = @cmp_id and exit_id = @exit_id
					End
			End
		Else If @status = 'LR'  --Added by Jaina 23-04-2019
			BEGIN
				Update T0200_Emp_ExitApplication Set status = 'H',interview_date=null,interview_time='',Clearance_ManagerID='' where @cmp_id = @cmp_id and exit_id=@exit_id
				DELETE FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id  = @Exit_ID AND CMP_ID = @CMP_ID
			END	

		--ronakb081024
		EXEC P9999_Audit_Trail @Cmp_ID
			,'D'
			,'ExitApplication'
			,@OldValue
			,@exit_id
			,@User_Id
			,@IP_Address
   
END



