
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_SurveyMaster]
	   @Survey_ID			numeric(18,0) Output
      ,@Cmp_ID				numeric(18,0)
      ,@SurveyStart_Date	datetime
      ,@SurveyEnd_Date		datetime
      ,@Survey_Title		Nvarchar(100) --Changed by Deepali 16Jun2022
      ,@Survey_Purpose		nvarchar(500)  --Changed by Deepali 16Jun2022
      ,@Survey_Instruction	nvarchar(500)  --Changed by Deepali 16Jun2022
      ,@Survey_OpenTill		datetime
      ,@tran_type		 varchar(1) 
	  ,@User_Id		 numeric(18,0) = 0
	  ,@IP_Address	 varchar(30)= '' 
	  ,@Branch_ID			numeric(18,0) =0 --Mukti 03032015
      ,@Survey_EmpId		varchar(max)='' --Mukti 03032015
	  ,@Send_Email			bit = 0   --Mukti 03032015
	  ,@Desig_ID			Varchar(max)=''
	  ,@Start_Time			varchar(10)
	  ,@End_Time			varchar(10)
	  ,@Min_Passing_Criteria	INT =0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID = 0
		set @Branch_ID= null
	if @Survey_EmpId  = ''
		set @Survey_EmpId = null
	if @Desig_ID = ''
		set @Desig_ID= null
If Upper(@tran_type) ='I'
	Begin
		select @Survey_ID = isnull(max(Survey_ID),0) + 1 from T0050_SurveyMaster WITH (NOLOCK)
		Insert Into T0050_SurveyMaster
		(
			   Survey_ID
			  ,Cmp_ID
			  ,SurveyStart_Date
			  ,SurveyEnd_Date
			  ,Survey_Title
			  ,Survey_Purpose
			  ,Survey_Instruction
			  ,Survey_OpenTill
			  ,Survey_CreatedBy
			  ,Branch_ID
			  ,Survey_EmpId
			  ,Survey_UpdateDate
			  ,Desig_ID
			  ,Start_Time
			  ,End_Time
			  ,Min_Passing_Criteria
		)
		Values
		(
			   @Survey_ID
			  ,@Cmp_ID
			  ,@SurveyStart_Date
			  ,@SurveyEnd_Date
			  ,@Survey_Title
			  ,@Survey_Purpose
			  ,@Survey_Instruction
			  ,@Survey_OpenTill
			  ,@User_Id
			  ,@Branch_ID
			  ,@Survey_EmpId
			  ,getdate()
			  ,@Desig_ID
			  ,@Start_Time
			  ,@End_Time
			  ,@Min_Passing_Criteria
		)
	End
Else If  Upper(@tran_type) ='U' 
	Begin
	--select @Start_Time,@End_Time
			UPDATE    T0050_SurveyMaster
			SET        SurveyStart_Date		=	@SurveyStart_Date
					  ,SurveyEnd_Date		=	@SurveyEnd_Date
					  ,Survey_Title			=	@Survey_Title
					  ,Survey_Purpose		=	@Survey_Purpose
					  ,Survey_Instruction	=	@Survey_Instruction
					  ,Survey_OpenTill		=	@Survey_OpenTill	
					  ,Branch_ID			=	@Branch_ID
					  ,Survey_EmpId			=	@Survey_EmpId	
					  ,Survey_UpdateDate    =	GETDATE()	
					  ,Desig_ID				=	@Desig_ID		
					  ,Start_Time			=	@Start_Time
					  ,End_Time				=	@End_Time
					  ,Min_Passing_Criteria	=@Min_Passing_Criteria
			WHERE Survey_ID = @Survey_ID and cmp_Id=@Cmp_ID
			
		
			--if @Send_Email = 1
			--	begin
			--		--EXECUTE msdb.dbo.sp_start_job @job_name = 'Survey_Mail'
			--	end
		
	End
Else If  Upper(@tran_type) ='D'
	Begin	
		Delete from T0060_SurveyEmployee_Response where Survey_ID = @Survey_ID
		Delete from T0052_SurveyTemplate where Survey_ID = @Survey_ID
		Delete from  T0050_SurveyMaster where Survey_ID = @Survey_ID
	End
exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Survey','',@Survey_ID,@User_Id,@IP_Address
END

