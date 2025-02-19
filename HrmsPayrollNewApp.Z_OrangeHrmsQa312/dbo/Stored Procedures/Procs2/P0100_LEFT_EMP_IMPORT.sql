

CREATE PROCEDURE [dbo].[P0100_LEFT_EMP_IMPORT]
	  @Left_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Emp_Code varchar(40)
	 ,@Left_Date datetime
	 ,@Reg_Accept_Date datetime
	--,@Left_Reason varchar(250)
	 ,@Other_Reason varchar(250)
	 ,@New_Employer varchar(100)
	 ,@Is_Terminate tinyint
	 ,@tran_type char(1)
	 ,@Uniform_Return numeric(18,0)
	 ,@Exit_Interview numeric(18,0)
	 ,@Notice_period numeric(18,2)
	 ,@Is_Death tinyint
	 ,@Reg_Date datetime = NULL 
	 ,@RptManager_Code VARCHAR(50) = ''
	 ,@LeftReasonText Varchar(100) = ''
	 ,@GUID Varchar(2000) = '' --Added by nilesh patel on 16062016
	,@Left_Reason  varchar(250) = '' --Added By jimit 25122018
	,@Is_Retire tinyint  --Added by Jaina 19-08-2020
	,@Is_Absconded tinyint  --Added by Jaina 19-08-2020
AS

    SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	if isnull(@Reg_Date,'') = ''
		set  @Reg_Date = @Reg_Accept_Date
		
	declare @Emp_Id			as numeric(18,0)
	DECLARE @RptManager_ID	as numeric(18,0)
	Declare @Effect_Date	DATETIME	  --Ankit 11022015
	DECLARE @Row_ID			NUMERIC(18,0) --Ankit 11022015
	DECLARE	@Desig_ID		Numeric(18,0) --Ankit 11022015
	Declare @DOJ as Datetime
	declare @New_R_Emp_id as numeric 
	--Added By Jimit 25122018
	DECLARE @RES_ID AS INT
	SET @RES_ID = 0

	IF @Left_Reason <> ''
		BEGIN
			SELECT  @RES_ID = REs_Id from T0040_Reason_Master WITH (NOLOCK) where Reason_Name = @Left_Reason			
			If @RES_ID = 0
				BEGIN
					
					--Raiserror ('Left Reason Doesn''t exists',16,2)
					Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Left Reason Doesn''t exists',@EMP_CODE ,'Enter proper Employee Left Reason',GetDate(),'Employee Left',@GUID)			
					Return -1		
				END
		END

	--Ended

	
	SET @Row_ID = 0
	SET @Desig_ID = 0
	set @New_R_Emp_id = 0 -- Added by Gadriwala 20112013
	Set @DOJ = NULL
		
		if isnull(@Reg_Accept_Date,'') = ''
			set @Reg_Accept_Date = null
			
		SET @Emp_Id = 0
			
		select @Emp_Id = isnull(Emp_Id,0),@DOJ = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and Cmp_ID = @Cmp_ID
		
		if @Emp_Id is null
			Begin
				Set @Emp_Id = 0
			End
		
		if @Emp_Id = 0 
			Begin
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Employee Code Doesn''t exists',@EMP_CODE ,'Enter proper Employee Code',GetDate(),'Employee Left',@GUID)			
				Return -1	
			End 
		
		if @Left_Date is null
			Begin
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Left Date Doesn''t exists',@EMP_CODE ,'Enter proper Employee Left Date',GetDate(),'Employee Left',@GUID)			
				Return -1
			End
		
		if @Reg_Accept_Date is null
			Begin
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Resignation Accept Date Doesn''t exists',@EMP_CODE ,'Enter proper Employee Resignation Accept Date',GetDate(),'Employee Left',@GUID)			
				Return -1
			End
		
		if @Other_Reason = ''
			Begin
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Employee Left Reason Doesn''t exists',@EMP_CODE ,'Enter proper Employee Left Reason',GetDate(),'Employee Left',@GUID)			
				Return -1
			End
		
		if @DOJ IS NOT NULL
			Begin
				if @DOJ > @Left_Date
					Begin
						Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Employee Left Date should be greater than date of joning',@EMP_CODE ,'Employee Left Date should be greater than date of joning',GetDate(),'Employee Left',@GUID)			
						Return -1
					End
			End
		--Replace Reporting Manager
		IF @RptManager_Code = ''
			BEGIN
				SET @RptManager_ID = NULL
			END
		ELSE 
			BEGIN
				SELECT @RptManager_ID = ISNULL(Emp_Id,0) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE UPPER(Alpha_Emp_Code) = UPPER(@RptManager_Code) AND Cmp_ID = @Cmp_ID
				
				IF ISNULL(@RptManager_ID,0) = 0
					BEGIN
						Raiserror ('Reporting Manager Employee Code Doesn''t exists',16,2)
						Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Reporting Manager Employee Code Doesn''t exists',@EMP_CODE ,'Enter proper Employee Code',GetDate(),'Employee Left',@GUID)			
						Return -1
					END
			END
		-- Set Default Value of PF Reason -- 17-11-2018
		IF @LeftReasonText = ''
			Begin
				SET @LeftReasonText = 'CESSATION(SHORT SERVICE)'
			End
		-- Added Validation By Nilesh Patel on 17-11-2018 -- For PF Left Reason
		Set @LeftReasonText = Upper(@LeftReasonText)
		if ( @LeftReasonText != 'RETIREMENT' AND @LeftReasonText != 'DEATH IN SERVICE' AND @LeftReasonText != 'SUPERNNUATION' AND @LeftReasonText != 'PERMANENT DISABLEMENT' AND @LeftReasonText != 'CESSATION(SHORT SERVICE)' AND @LeftReasonText != 'DEATH AWAY FROM SERVICE' )
			Begin
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Employee Pf Left Reason Doesn''t exists',@EMP_CODE ,'Enter proper Employee PF Left Reason',GetDate(),'Employee Left',@GUID)			
				Return -1
			End	
		If @tran_type ='I' 
			begin
			
				if Not Exists ( select LE.Left_Id from T0100_LEFT_EMP LE WITH (NOLOCK) inner join T0080_EMP_MASTER EM WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID where LE.Emp_ID = @Emp_Id and EM.Emp_Left = 'Y')
					begin
							if exists (Select Left_ID  from T0100_LEFT_EMP WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID) 
								begin
									set @Left_ID=0
								end
							Else
								Begin
									Select @Left_ID = isnull(max(Left_ID),0) + 1  from T0100_LEFT_EMP WITH (NOLOCK)
									--PF LEFT REASON IS FIX THAT WHY ADDED STATIC CONDITION -- 17-11-2018
									Insert Into T0100_LEFT_EMP(Left_ID,Cmp_ID,Emp_ID,Left_Date,Left_Reason ,New_Employer,Reg_Accept_Date,Is_Terminate,Uniform_Return,Exit_Interview,Notice_Period,Is_Death,Reg_Date,Is_Retire,LeftReasonValue,LeftReasonText ,Res_Id,Is_Absconded)
									values(@Left_ID,@Cmp_ID,@Emp_ID,@Left_Date,@Other_Reason ,@New_Employer,@Reg_Accept_Date,@Is_Terminate,@Uniform_Return,@Exit_Interview,@Notice_Period,@Is_Death,@Reg_Date,@Is_Retire,(CASE WHEN @LEFTREASONTEXT = '' THEN '' ELSE (CASE WHEN @LEFTREASONTEXT = 'DEATH AWAY FROM SERVICE' THEN 'A' ELSE LEFT(@LEFTREASONTEXT, 1) END) END),@LeftReasonText,@RES_ID,@Is_Absconded)
									
									
									UPDATE T0080_EMP_MASTER 
									SET EMP_LEFT  = 'Y' , EMP_LEFT_DATE = @LEFT_DATE,is_for_mobile_Access=0
									WHERE EMP_ID = @EMP_ID
									
									--If Employee is Inactive , then we will make it Active , as it was showing InCorrect Count of Inactive Employee on Home Page ( Ramiz - 25/06/2018 )
									UPDATE T0011_LOGIN 
									SET Is_Active = 1
									WHERE EMP_ID = @EMP_ID AND Is_Active = 0
				
								End
							
							If isnull(@RptManager_ID,0) <> 0  
								begin
									-- Added by Gadriwala 20112013 - Start
										insert into T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY(Emp_id,Old_R_Emp_id,New_R_Emp_id,Cmp_id,Change_date,Comment)
									select emp_ID,R_Emp_ID,@RptManager_ID,Cmp_ID,GETDATE(),'Left' from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where  R_Emp_ID = @Emp_ID
									
									--Update T0090_EMP_REPORTING_DETAIL 
									--set  R_Emp_ID = @RptManager_ID where R_Emp_ID = @Emp_ID	
									-- Added by Gadriwala 20112013 - End
									
									-- Insert New reporting Manger Update Scheme Detail As selected Reporting Manager	--Ankit 11022015
									
									IF NOT EXISTS(select Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE R_Emp_ID = @RptManager_ID and Effect_Date = @Left_Date)
										BEGIN
										
											select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											
											INSERT INTO T0090_EMP_REPORTING_DETAIL
											SELECT @Row_ID + ROW_NUMBER() Over (order by Row_ID) as Row_ID,ERD.Emp_ID,@RptManager_ID, Cmp_ID, Reporting_To, Reporting_Method,@Left_Date
											FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												 WHERE Effect_Date<=@Left_Date
												 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
											WHERE ERD.R_Emp_ID = @Emp_ID
											ORDER BY ERD.Effect_Date
										END
										
										
										
									INSERT INTO T0051_Scheme_Detail_History		--Insert scheme detail Record For History
									SELECT @Cmp_ID, Scheme_Detail_Id,App_Emp_ID,@RptManager_ID ,getdate() As system_Date 
									FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Is_RM = 0 AND App_Emp_ID = @Emp_ID ORDER BY Scheme_Detail_Id
									
									SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN     
									   ( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)   
											WHERE Increment_Effective_date <= GETDATE() and Cmp_ID = @Cmp_ID And Emp_ID = @RptManager_ID GROUP BY emp_ID
										) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
									WHERE I.Emp_ID = @RptManager_ID 
															   
									UPDATE T0050_Scheme_Detail	--Update Reporting Manger
									SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = @Desig_ID 
									WHERE Is_RM = 0 AND App_Emp_ID = @Emp_ID
									
									
									UPDATE	T0080_EMP_MASTER 
									SET		Emp_Superior = @RptManager_ID
									WHERE   Emp_Superior = @Emp_ID
									-- Update Scheme Detail As selected Reporting Manager	--Ankit 11022015
								end
					end
				Else 
					Begin
							select @Left_ID = LE.Left_Id from T0100_LEFT_EMP LE WITH (NOLOCK) inner join T0080_EMP_MASTER EM WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID where LE.Emp_ID = @Emp_Id and EM.Emp_Left = 'Y'
							
							Update T0100_LEFT_EMP 
							Set 
								--Left_Reason = @Left_Reason ,
								Left_Reason = @Other_Reason,
								New_Employer= @New_Employer,
								Left_Date = @Left_Date,
								Reg_Accept_Date= @Reg_Accept_Date,
								Is_Terminate = @Is_Terminate,
								Uniform_Return=@Uniform_Return,
								Exit_Interview=@Exit_Interview,
								Notice_Period=@Notice_Period,
								Is_Death=@Is_Death,
								REs_Id = @RES_ID
							where Left_ID = @Left_ID  and Cmp_ID = @Cmp_ID 
							
							UPDATE T0080_EMP_MASTER 
							SET EMP_LEFT  = 'Y' , EMP_LEFT_DATE = @LEFT_DATE,is_for_mobile_Access=0
							WHERE EMP_ID = @EMP_ID
							
							--If Employee is Inactive , then we will make it Active , as it was showing InCorrect Count of Inactive Employee on Home Page ( Ramiz - 25/06/2018 )
							UPDATE T0011_LOGIN 
							SET Is_Active = 1
							WHERE EMP_ID = @EMP_ID AND Is_Active = 0
									
							-- Added by Gadriwala 20112013 - Start
							If isnull(@RptManager_ID,0) <> 0  
								BEGIN
									select @New_R_Emp_id = New_R_Emp_id from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY WITH (NOLOCK) where  Old_R_Emp_id = @Emp_ID
									
									UPDATE T0090_EMP_REPORTING_DETAIL 
									SET  R_Emp_ID = @RptManager_ID ,Effect_date = @Left_Date
									WHERE R_Emp_ID = @New_R_Emp_id
										
									Update T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY set New_R_Emp_id = @RptManager_ID, Change_date = GETDATE()  where Old_R_Emp_id = @Emp_ID
									
									SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN     
									   ( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)   
											WHERE Increment_Effective_date <= GETDATE() and Cmp_ID = @Cmp_ID And Emp_ID = @RptManager_ID GROUP BY emp_ID
										) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
									WHERE I.Emp_ID = @RptManager_ID 
															   
									UPDATE T0050_Scheme_Detail	--Update Reporting Manger
									SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = @Desig_ID 
									WHERE Is_RM = 0 AND App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Emp_ID)
									
									Update T0051_Scheme_Detail_History
									SET New_App_Emp_ID = @RptManager_ID , System_date = GETDATE()
									WHERE New_App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Emp_ID)
									
									UPDATE	T0080_EMP_MASTER 
									SET		Emp_Superior = @RptManager_ID
									WHERE   Emp_Superior = @Emp_ID
									
								END
							-- Added by Gadriwala 20112013 - End
					End
					
					
					
		End
		
	

	RETURN




