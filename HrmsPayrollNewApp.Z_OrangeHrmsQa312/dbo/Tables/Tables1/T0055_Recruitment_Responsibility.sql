CREATE TABLE [dbo].[T0055_Recruitment_Responsibility] (
    [Rec_Resp_Id]    NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Rec_Req_ID]     NUMERIC (18)  NOT NULL,
    [Responsibility] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0055_Recruitment_Responsibility] PRIMARY KEY CLUSTERED ([Rec_Resp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_Recruitment_Responsibility_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_Recruitment_Responsibility_T0050_HRMS_Recruitment_Request] FOREIGN KEY ([Rec_Req_ID]) REFERENCES [dbo].[T0050_HRMS_Recruitment_Request] ([Rec_Req_ID])
);

