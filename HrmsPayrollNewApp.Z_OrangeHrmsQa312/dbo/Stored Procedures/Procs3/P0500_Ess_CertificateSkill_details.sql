
CREATE PROCEDURE [dbo].[P0500_Ess_CertificateSkill_details]
@Certi_Detail_Id numeric(18,0) OUTPUT,
@Certi_Id numeric(18,0),
@Cmp_Id numeric,
@Emp_Id numeric (18,0),
@Skill_Level nvarchar(50) ,
@Exp_Years numeric(18,0),
@Is_TrainingAttended numeric(18,0),
@Training_Certi_Attachment nvarchar(100),
@Is_ExamAttended numeric(18,0),
@Exam_Certi_Attachment nvarchar(100),
@Descriptions nvarchar(MAX),
@Created_By numeric,

@TransId Char = ''

AS
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TransId = 'I'
		Begin 
					--IF Exists(Select Certi_Detail_Id  from T0500_Certificateskill_Details WITH (NOLOCK) Where Certi_Detail_Id = @Certi_Detail_Id)  
					--Begin  
					--	set @Certi_Detail_Id= 0  
					--Return   
					--End  
				
					--select @Certi_Detail_Id = isnull(max(Certi_Detail_Id),0) + 1  from T0500_Certificateskill_Details WITH (NOLOCK)
					Select @Certi_Detail_Id = isnull(max(Certi_Detail_Id),0) + 1 from T0500_Ess_Certificateskill_Details WITH (NOLOCK)

					INSERT INTO T0500_Ess_Certificateskill_Details
					(Certi_Detail_Id,Certi_Id,Emp_Id,Cmp_id,Skill_Level,Exp_Years,Is_TrainingAttended,Training_Certi_Attachment,Is_ExamAttended,Exam_Certi_Attachment,Descriptions,Created_By,Created_Date)
					VALUES(@Certi_Detail_Id,@Certi_Id,@Emp_Id,@Cmp_Id,@Skill_Level,@Exp_Years,@Is_TrainingAttended,@Training_Certi_Attachment,@Is_ExamAttended,@Exam_Certi_Attachment,@Descriptions,@Created_By,GETDATE())
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF not Exists(Select Certi_Detail_Id  from T0500_Ess_Certificateskill_Details WITH (NOLOCK) Where Certi_Detail_Id = @Certi_Detail_Id)  
					Begin  
						set @Certi_Detail_Id = 0  
					Return   
					End  
					
					UPDATE    T0500_Ess_Certificateskill_Details SET 
					Cmp_id = @Cmp_Id,
					Certi_Id = @Certi_Id,
					Emp_Id= @Emp_Id,
					
					Skill_Level = @Skill_Level,
					Exp_Years = @Exp_Years,
					Is_TrainingAttended = @Is_TrainingAttended,
					Training_Certi_Attachment= @Training_Certi_Attachment,
					Is_ExamAttended = @Is_ExamAttended,
					Exam_Certi_Attachment= @Is_ExamAttended,
					Descriptions= @Descriptions,
					 Created_By = @Created_By
					WHERE     Certi_Detail_Id = @Certi_Detail_Id

		end	

	Else if @TransId = 'D'  
		Begin
		
			select ISNULL(Certi_Detail_Id,0)  From dbo.T0500_Ess_Certificateskill_Details WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Certi_Detail_Id = @Certi_Detail_Id	
		
			DELETE FROM T0500_Ess_Certificateskill_Details 	WHERE  Certi_Detail_Id = @Certi_Detail_Id
			
		end

	RETURN	

	End