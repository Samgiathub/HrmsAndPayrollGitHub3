


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_Hrms_Initiate_KPASetting]
	   @KPA_InitiateId			numeric(18,0) Output
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@KPA_StartDate			datetime
      ,@KPA_EndDate				datetime
      ,@Initiate_Status			int			= null
      ,@Year					int			= null
      ,@RM_Required				int
      ,@Hod_Id					numeric(18,0) = null
      ,@GH_Id					numeric(18,0) = null
      ,@Emp_ApprovedDate		datetime	  = null
      ,@Rm_ApprovedDate			datetime	  = null
      ,@HOD_ApprovedDate		datetime	  = null
      ,@GH_ApprovedDate			datetime	  = null
      ,@Emp_Comment				nvarchar(500)  = ''  --changed By Deepali -04-Apr-22- for unicode 
      ,@RM_Comment				nvarchar(500)  = '' --changed By Deepali -04-Apr-22- for unicode 
      ,@HOD_Comment				nvarchar(500)  = '' --changed By Deepali -04-Apr-22- for unicode 
      ,@GH_Comment				nvarchar(500)  = '' --changed By Deepali -04-Apr-22- for unicode 
      ,@Review_Type				varchar(10)
      ,@Send_to_RM				int
      ,@From_Month				varchar(25) = ''
      ,@To_Month				varchar(25) = ''
      ,@tran_type				char(1)
      ,@User_Id					numeric(18,0) = 0
	  ,@IP_Address				varchar(30)= '' 
	  ,@Period					varchar(10)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	IF @Year is NULL
		BEGIN
			SET @Year = DATEPART(YEAR,@KPA_StartDate)
		END
	IF @Hod_Id =0
		SET @Hod_Id = NULL
	IF 	@GH_Id = 0
		SET @GH_Id = NULL
	IF @Period='--Select--'
		SET @Period=''

	IF @tran_type = 'I'
		BEGIN
			--IF EXISTS(SELECT 1 from T0055_Hrms_Initiate_KPASetting where Emp_Id= @Emp_Id and Year = @Year )
			--	BEGIN
			--		SET @KPA_InitiateId = 0
			--		RETURN
			--	END
			
			SELECT @KPA_InitiateId = isnull(MAX(KPA_InitiateId),0)+1 FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK)
			INSERT INTO T0055_Hrms_Initiate_KPASetting
			(
				KPA_InitiateId
			   ,Cmp_Id
			   ,Emp_Id
			   ,KPA_StartDate
			   ,KPA_EndDate
			   ,Initiate_Status
			   ,Year
			   ,RM_Required
			   ,Hod_Id
			   ,GH_Id
			   ,Emp_ApprovedDate
			   ,Rm_ApprovedDate
			   ,HOD_ApprovedDate
			   ,GH_ApprovedDate
			   ,Emp_Comment
			   ,RM_Comment
			   ,HOD_Comment
			   ,GH_Comment
			   ,Review_Type
			   ,Send_to_RM
			   ,Duration_FromMonth
			   ,Duration_ToMonth
			   ,[Period]
			)VALUES
			(
				@KPA_InitiateId
			   ,@Cmp_Id
			   ,@Emp_Id
			   ,@KPA_StartDate
			   ,@KPA_EndDate
			   ,@Initiate_Status
			   ,@Year
			   ,@RM_Required
			   ,@Hod_Id
			   ,@GH_Id
			   ,@Emp_ApprovedDate
			   ,@Rm_ApprovedDate
			   ,@HOD_ApprovedDate
			   ,@GH_ApprovedDate
			   ,@Emp_Comment
			   ,@RM_Comment
			   ,@HOD_Comment
			   ,@GH_Comment
			   ,@Review_Type
			   ,@Send_to_RM
			   ,@From_Month
			   ,@To_Month
			   ,@Period
			)
		END
	ELSE IF @tran_type = 'U'
		BEGIN
			UPDATE T0055_Hrms_Initiate_KPASetting
			SET   KPA_EndDate			=  @KPA_EndDate
				  ,Initiate_Status		=  @Initiate_Status
				  ,Year					=  @Year
				  ,RM_Required			=  @RM_Required
				  ,Hod_Id				=  @Hod_Id
				  ,GH_Id				=  @GH_Id
				  ,Review_Type			=   @Review_Type
				  ,Send_to_RM=@Send_to_RM
				  ,[Period]=@Period
				  
				  --,Emp_ApprovedDate		=  @Emp_ApprovedDate
				  --,Rm_ApprovedDate		=  @Rm_ApprovedDate
				  --,HOD_ApprovedDate		=  @HOD_ApprovedDate
				  --,GH_ApprovedDate		=  @GH_ApprovedDate
			   --   ,Emp_Comment			=  @Emp_Comment
				  --,RM_Comment			=  @RM_Comment
				  --,HOD_Comment			=  @HOD_Comment
				  --,GH_Comment			=  @GH_Comment
			WHERE KPA_InitiateId   =   @KPA_InitiateId
		END
	ELSE IF @tran_type = 'D'
		BEGIN
			IF NOT EXISTS(SELECT 1 from T0060_Appraisal_EmployeeKPA WITH (NOLOCK) where Effective_Date = @KPA_StartDate and Emp_Id=@Emp_Id)	
				BEGIN		
					DELETE FROM T0055_Hrms_Initiate_KPASetting 
					WHERE KPA_InitiateId   =   @KPA_InitiateId
				END
			ELSE
				SET @KPA_InitiateId = 0
		END
END


