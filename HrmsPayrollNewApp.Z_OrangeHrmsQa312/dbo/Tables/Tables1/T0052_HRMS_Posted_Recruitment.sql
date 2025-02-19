CREATE TABLE [dbo].[T0052_HRMS_Posted_Recruitment] (
    [Rec_Post_Id]      NUMERIC (18)    NOT NULL,
    [Cmp_id]           NUMERIC (18)    NOT NULL,
    [Rec_Req_ID]       NUMERIC (18)    NOT NULL,
    [Rec_Post_Code]    VARCHAR (50)    NOT NULL,
    [Rec_Post_date]    DATETIME        NOT NULL,
    [Rec_Start_date]   DATETIME        NOT NULL,
    [Rec_End_date]     DATETIME        NULL,
    [Qual_Detail]      NVARCHAR (1000) NOT NULL,
    [Experience_year]  NUMERIC (18, 2) NOT NULL,
    [Location]         VARCHAR (1000)  NULL,
    [Experience]       NVARCHAR (1000) NOT NULL,
    [Email_id]         VARCHAR (50)    NOT NULL,
    [Job_title]        VARCHAR (50)    NOT NULL,
    [Posted_status]    TINYINT         NOT NULL,
    [Login_id]         NUMERIC (18)    NULL,
    [S_Emp_id]         NUMERIC (18)    NULL,
    [System_Date]      DATETIME        NULL,
    [Other_Detail]     NVARCHAR (1000) NULL,
    [Position]         VARCHAR (500)   NULL,
    [Venue_address]    NVARCHAR (250)  NULL,
    [Publish_ToEmp]    INT             NULL,
    [Publish_FromDate] DATETIME        NULL,
    [Publish_ToDate]   DATETIME        NULL,
    [Consultant_ID]    INT             NULL,
    [Exp_Min]          FLOAT (53)      NULL,
    CONSTRAINT [PK_T0052_HRMS_Posted_Recruitment_1] PRIMARY KEY CLUSTERED ([Rec_Post_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_Posted_Recruitment_T0010_COMPANY_MASTER1] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_HRMS_Posted_Recruitment_T0050_Recruitement_Request1] FOREIGN KEY ([Rec_Req_ID]) REFERENCES [dbo].[T0050_HRMS_Recruitment_Request] ([Rec_Req_ID]),
    CONSTRAINT [FK_T0052_HRMS_Posted_Recruitment_T0080_EMP_MASTER] FOREIGN KEY ([Login_id]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0052_HRMS_Posted_Recruitment_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO



CREATE TRIGGER [DBO].[Tri_T0052_HRMS_Posted_Recruitment]
ON [dbo].[T0052_HRMS_Posted_Recruitment]
FOR  INSERT,UPDATE
AS
	Declare @Rec_Req_ID numeric 
	Declare @Rec_Post_ID	numeric 
	Declare @Approval_Status	varchar(1)
	

			--Comment by Ripal 27Jun2014 (here On changing status of Post detail status of recruitment request
				-- is change that should not happen)
	
			--select @Approval_Status = Posted_Status, @Rec_Req_ID = isnull(Rec_Req_ID,0) from inserted 
			
			
			--if isnull(@Rec_Req_ID,0) > 0	
			--	begin
			--		Update T0050_HRMS_Recruitment_Request 
			--		set App_Status = @Approval_Status
			--		where Rec_Req_Id = @Rec_Req_ID
			--	end




