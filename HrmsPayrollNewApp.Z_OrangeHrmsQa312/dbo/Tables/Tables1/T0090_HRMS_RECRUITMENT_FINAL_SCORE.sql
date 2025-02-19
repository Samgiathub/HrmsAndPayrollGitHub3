CREATE TABLE [dbo].[T0090_HRMS_RECRUITMENT_FINAL_SCORE] (
    [Trans_ID]     NUMERIC (18)    NOT NULL,
    [Resume_ID]    NUMERIC (18)    NOT NULL,
    [Cmp_ID]       NUMERIC (18)    NULL,
    [Rec_Job_Code] VARCHAR (50)    NULL,
    [Process_ID]   NUMERIC (18)    NULL,
    [Rec_Post_ID]  NUMERIC (18)    NULL,
    [Actual_Rate]  NUMERIC (18, 2) NULL,
    [Given_Rate]   NUMERIC (18, 2) NULL,
    [Notes]        VARCHAR (1000)  NULL,
    [Status]       NUMERIC (18)    NULL,
    CONSTRAINT [FK_T0090_HRMS_RECRUITMENT_FINAL_SCORE_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_HRMS_RECRUITMENT_FINAL_SCORE_T0040_HRMS_R_PROCESS_MASTER] FOREIGN KEY ([Process_ID]) REFERENCES [dbo].[T0040_HRMS_R_PROCESS_MASTER] ([Process_ID]),
    CONSTRAINT [FK_T0090_HRMS_RECRUITMENT_FINAL_SCORE_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_ID]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id]),
    CONSTRAINT [FK_T0090_HRMS_RECRUITMENT_FINAL_SCORE_T0055_Resume_Master] FOREIGN KEY ([Resume_ID]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id])
);


GO





CREATE TRIGGER TRI_T0090_HRMS_RECRUITMENT_FINAL_SCORE
ON dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE
FOR Insert,UPDATE
AS
	--CREATED BY : FALAK 06-AUG-2010
	Declare @Resume_Id as numeric
	DEclare @Status as numeric
	
	select @resume_ID = resume_Id, @Status = status from inserted	
	
	if @Resume_Id > 0 
		begin 
			update T0055_Resume_Master set Resume_Status = @Status where resume_Id = @resume_Id
		
			--Update T0055_HRMS_Interview_Schedule set Status = @Status where resume_Id = @Resume_Id
		end
	-- added by falak on 15-Jun-2010
	--if Update(interview_schedule_ID)
	--begin
	--	update T0055_Resume_Master set resume_Status = 1 where resume_id = @Resume_Id
	--end




