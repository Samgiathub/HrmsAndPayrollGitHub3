
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_JobDescription_Master]
	  @Job_Id				numeric(18,0)	OUTPUT	
      ,@Cmp_Id				numeric(18,0)
      ,@Effective_Date		datetime
      ,@Job_Code			varchar(50) =''
      ,@Branch_Id			varchar(max)
      ,@Grade_Id			varchar(max)
      ,@Desig_Id			varchar(max)
      ,@Dept_Id				varchar(max)
      ,@Qual_Id				varchar(max)
      ,@Exp_Min				int
      ,@Exp_Max				int
      ,@Tran_Type			char(1)
	  ,@User_Id				numeric(18,0)	
	  ,@IP_Address			varchar(100)
	  ,@Attach_Doc			varchar(2000)
	  ,@status				int
	  ,@Job_Title			varchar(200)
	  ,@Send_To_Superior	int	
	  ,@Document_ID			varchar(250)
	  ,@Experience_Type		int
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Tran_Type = 'I'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0050_JobDescription_Master WITH (NOLOCK) WHERE Job_Code=@Job_Code)
			BEGIN
				SET @Job_Id=0
				RETURN
			END

			select @Job_Id = isnull(max(Job_Id),0)+1 from T0050_JobDescription_Master WITH (NOLOCK)
			Insert into T0050_JobDescription_Master
			(
				   Job_Id
				  ,Cmp_Id
				  ,Effective_Date
				  ,Job_Code
				  ,Branch_Id
				  ,Grade_Id
				  ,Desig_Id
				  ,Dept_Id
				  ,Qual_Id
				  ,Exp_Min
				  ,Exp_Max
				  ,Create_Date
				  ,Create_By
				  ,Attach_Doc
				  ,[status]
				  ,Job_Title
				  ,Send_To_Superior
				  ,Document_ID
				  ,Experience_Type
			)
			VALUES
			(
				   @Job_Id
				  ,@Cmp_Id
				  ,@Effective_Date
				  ,@Job_Code
				  ,@Branch_Id
				  ,@Grade_Id
				  ,@Desig_Id
				  ,@Dept_Id
				  ,@Qual_Id
				  ,@Exp_Min
				  ,@Exp_Max
				  ,GETDATE()
				  ,@User_Id
				  ,@Attach_Doc
				  ,@status
				  ,@Job_Title
				  ,@Send_To_Superior
				  ,@Document_ID
				  ,@Experience_Type
			)
		END
	Else If @Tran_Type = 'U'
		BEGIN
			Update T0050_JobDescription_Master
			SET   
				  Effective_Date = @Effective_Date
				  ,Job_Code		 = @Job_Code
				  ,Branch_Id	 = @Branch_Id
				  ,Grade_Id		 = @Grade_Id
				  ,Desig_Id		 = @Desig_Id
				  ,Dept_Id		 = @Dept_Id
				  ,Qual_Id		 = @Qual_Id
				  ,Exp_Min		 = @Exp_Min
				  ,Exp_Max       = @Exp_Max
				  ,Attach_Doc    = @Attach_Doc
				  ,[status]		 = @status
				  ,Job_Title    = @Job_Title
				  ,Send_To_Superior=@Send_To_Superior
				  ,Document_ID = @Document_ID
				  ,Experience_Type = @Experience_Type
			WHERE Job_Id = @job_Id
		END
	Else If @Tran_Type = 'D'
		BEGIN
		
		--Added by Jaina 8-11-2016 Start
		IF EXISTS (SELECT 1 from T0050_HRMS_Recruitment_Request R WITH (NOLOCK) INNER JOIN T0050_JobDescription_Master J WITH (NOLOCK) ON R.JD_CodeId = J.Job_Id WHERE R.Cmp_id = @Cmp_Id AND J.Job_Id = @Job_Id)
		BEGIN
				RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
				RETURN 
		END
		IF EXISTS (SELECT * FROM  T0090_Emp_JD_Responsibilty J WITH (NOLOCK) INNER JOIN T0050_JobDescription_Master JD WITH (NOLOCK) ON JD.Job_Id = J.JDCode_Id where J.Cmp_Id=@Cmp_Id AND JD.Job_Id =@Job_Id)
		BEGIN
				RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
				RETURN 
		END
		--Added by Jaina 8-11-2016 End			
			Delete from T0055_JobResponsibility where Job_Id = @job_Id
			Delete from T0055_JobSkill where Job_Id = @job_Id
			Delete from T0050_JobDescription_Master where Job_Id = @job_Id
		END
END
