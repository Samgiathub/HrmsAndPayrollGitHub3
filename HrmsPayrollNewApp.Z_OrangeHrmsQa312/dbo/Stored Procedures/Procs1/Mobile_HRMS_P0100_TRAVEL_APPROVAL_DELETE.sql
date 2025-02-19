-- exec [dbo].[Mobile_HRMS_P0100_TRAVEL_APPLICATION_DELETE] 246,187,28201,21776,'D',''
Create PROCEDURE [dbo].[Mobile_HRMS_P0100_TRAVEL_APPROVAL_DELETE]
	 @Travel_Application_ID	NUMERIC(18,0)	
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@Login_ID				NUMERIC(18,0)
	,@Type				CHAR(1) 
	,@Result				VARCHAR(70)OUTPUT

AS
BEGIN	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
		DECLARE @Create_Date As Datetime
		DECLARE @Modify_Date As Datetime
		DECLARE @App_Code As Numeric(18,0)
		DECLARE @Application_Code Varchar(20)
		SET @Create_Date = GETDATE()
		SET @Modify_Date = GETDATE()
	
		--IF @S_Emp_ID = 0
			--Set @S_Emp_ID = NULL
	
		DECLARE @OldValue as  varchar(max)
		DECLARE @String_val as varchar(max)
		SET @String_val=''
		SET @OldValue =''

		DECLARE @SchemeId as numeric(18,0) = 0
		DECLARE @ReportLevel as numeric(18,0) = 0

		SELECT @SchemeId = Scheme_ID 
		FROM T0095_EMP_SCHEME S
		INNER JOIN (
			SELECT max(Effective_Date) as EffDate,Tran_ID 
			FROM T0095_EMP_SCHEME S1 
			WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
			group by Tran_id
		) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

		SELECT @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID

		SET @ReportLevel = @ReportLevel + 1

		--SELECT @S_Emp_ID = Emp_Superior from T0080_EMP_MASTER where emp_id = @Emp_ID and Cmp_ID = @Cmp_ID

	
		
 IF UPPER(@Type) = 'D'
			BEGIN
			
				exec P9999_Audit_get @table='T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
				--set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				Declare @TravelApp int,@TravelApp_lvl int
				set @TravelApp=(select Count(*)as TravelApp from T0120_TRAVEL_APPROVAL where Travel_Application_ID=@Travel_Application_ID and Cmp_ID=@Cmp_ID and Approval_Status='P')
				set @TravelApp_lvl=(select Count(*)as TravelApp_lvl from T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID=@Travel_Application_ID and Cmp_ID=@Cmp_ID)
				--select @TravelApp,@TravelApp_lvl
				if (isnull(@TravelApp,0)=0 and isnull(@TravelApp_lvl,0)=0 )
				begin
					
								
				DELETE FROM dbo.T0110_TRAVEL_ADVANCE_DETAIL where Travel_App_ID = @Travel_Application_ID and Cmp_ID=@Cmp_ID
				DELETE FROM dbo.T0110_TRAVEL_APPLICATION_DETAIL where  Travel_App_ID = @Travel_Application_ID and Cmp_ID=@Cmp_ID
				DELETE FROM dbo.T0110_Travel_Application_Other_Detail where  Travel_App_ID = @Travel_Application_ID and Cmp_ID=@Cmp_ID    
				DELETE FROM dbo.T0100_TRAVEL_APPLICATION where Travel_Application_ID= @Travel_Application_ID and Cmp_ID=@Cmp_ID
				DELETE FROM DBO.T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE Travel_APP_ID= @Travel_Application_ID and Cmp_ID=@Cmp_ID
				Delete from T0080_Travel_HycScheme where AppId = @Travel_Application_ID-- and Cmp_ID=@Cmp_ID


					IF @Travel_Application_ID >0
					BEGIN
							SET @Result = 'Data Deleted Successfully'
							SELECT @Result
					END
			end
			--else
			--begin
			--SET @Result = 'Refrence Exist'
			--				SELECT @Result
			--end
			END
	
		

		--EXEC P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1

		--EXEC Mobile_HRMS_P0110_TRAVEL_APPLICATION_DETAIL @Travel_App_Detail_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Travel_App_ID=@Travel_Application_ID,
		--@Instruct_Emp_ID=@Emp_ID,@Tran_Type=@Tran_Type,@User_Id=@User_Id,@TravelTypeId=@TravelTypeId,
		--@Travel_Details= @Travel_Details
		
		--EXEC Mobile_HRMS_TRAVEL_Other_APPLICATION_DETAIL @Travel_App_Other_Detail_Id = 0,@Tran_Type = @Tran_Type,
		--@Travel_App_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Travel_Other_Details = @Travel_Other_Details

		--EXEC Mobile_HRMS_TRAVEL_ADVANCE_DETAIL @Cmp_ID=@Cmp_ID,@Travel_App_ID = @Travel_Application_ID,@Tran_Type=@Tran_Type,	
		--@Travel_Adv_Details = @Travel_Adv_Details

		

END


