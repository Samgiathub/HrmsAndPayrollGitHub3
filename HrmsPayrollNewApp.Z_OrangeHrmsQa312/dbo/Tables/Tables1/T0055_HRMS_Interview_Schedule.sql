CREATE TABLE [dbo].[T0055_HRMS_Interview_Schedule] (
    [Interview_Schedule_Id]       NUMERIC (18)    NOT NULL,
    [Interview_Process_Detail_Id] NUMERIC (18)    NULL,
    [Rec_Post_Id]                 NUMERIC (18)    NOT NULL,
    [Cmp_Id]                      NUMERIC (18)    NOT NULL,
    [S_Emp_Id]                    NUMERIC (18)    NULL,
    [S_Emp_Id2]                   NUMERIC (18)    NULL,
    [S_Emp_Id3]                   NUMERIC (18)    NULL,
    [S_Emp_ID4]                   NUMERIC (18)    NULL,
    [From_Date]                   DATETIME        NULL,
    [To_Date]                     DATETIME        NULL,
    [From_Time]                   VARCHAR (50)    NULL,
    [To_Time]                     VARCHAR (50)    NULL,
    [Resume_Id]                   NUMERIC (18)    NOT NULL,
    [Rating]                      NUMERIC (18, 2) NULL,
    [Rating2]                     NUMERIC (18, 2) NULL,
    [Rating3]                     NUMERIC (18, 2) NULL,
    [Rating4]                     NUMERIC (18, 2) NULL,
    [Schedule_Date]               DATETIME        NULL,
    [Schedule_Time]               NVARCHAR (50)   NULL,
    [Process_Dis_No]              NUMERIC (18)    NULL,
    [Status]                      NUMERIC (18)    NOT NULL,
    [Comments]                    VARCHAR (1000)  NULL,
    [Comments2]                   VARCHAR (1000)  NULL,
    [Comments3]                   VARCHAR (1000)  NULL,
    [Comments4]                   VARCHAR (1000)  NULL,
    [System_Date]                 DATETIME        NULL,
    [BypassInterview]             INT             CONSTRAINT [DF_T0055_HRMS_Interview_Schedule_BypassInterview] DEFAULT ((0)) NULL,
    [HR_DOC_ID]                   NUMERIC (18)    NULL,
    [Paid_Travel_Amount]          NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0055_HRMS_Interview_Schedule] PRIMARY KEY CLUSTERED ([Interview_Schedule_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_Id]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_T0055_HRMS_Interview_Schedule] FOREIGN KEY ([Interview_Schedule_Id]) REFERENCES [dbo].[T0055_HRMS_Interview_Schedule] ([Interview_Schedule_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_T0055_Interview_Process_Detail] FOREIGN KEY ([Interview_Process_Detail_Id]) REFERENCES [dbo].[T0055_Interview_Process_Detail] ([Interview_Process_detail_ID]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_T0055_Resume_Master] FOREIGN KEY ([Resume_Id]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id])
);


GO





CREATE TRIGGER [DBO].[TRI_T0055_HRMS_Interview_Schedule_deleted]
ON [dbo].[T0055_HRMS_Interview_Schedule]
FOR Delete
AS
	Declare @Resume_Id as numeric
	DEclare @Status as numeric
	
	select @resume_ID = resume_Id, @Status = status from deleted	
	
	update T0055_Resume_Master set Resume_Status = 0 where resume_Id = @resume_Id




