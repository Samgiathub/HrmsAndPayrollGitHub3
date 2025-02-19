CREATE TABLE [dbo].[T0055_Interview_Process_Detail] (
    [Interview_Process_detail_ID] NUMERIC (18) NOT NULL,
    [Cmp_ID]                      NUMERIC (18) NOT NULL,
    [Rec_Post_ID]                 NUMERIC (18) NOT NULL,
    [Process_ID]                  NUMERIC (18) NULL,
    [S_Emp_ID]                    NUMERIC (18) NULL,
    [S_Emp_Id2]                   NUMERIC (18) NULL,
    [S_Emp_Id3]                   NUMERIC (18) NULL,
    [S_Emp_ID4]                   NUMERIC (18) NULL,
    [From_Date]                   DATETIME     NULL,
    [To_Date]                     DATETIME     NULL,
    [From_Time]                   VARCHAR (50) NULL,
    [To_Time]                     VARCHAR (50) NULL,
    [Dis_No]                      NUMERIC (18) NULL,
    [System_Date]                 DATETIME     NULL,
    CONSTRAINT [PK_T0055_Interview_Process_Detail] PRIMARY KEY CLUSTERED ([Interview_Process_detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_Interview_Process_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_Interview_Process_Detail_T0040_HRMS_R_PROCESS_MASTER] FOREIGN KEY ([Process_ID]) REFERENCES [dbo].[T0040_HRMS_R_PROCESS_MASTER] ([Process_ID]),
    CONSTRAINT [FK_T0055_Interview_Process_Detail_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_ID]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id])
);

