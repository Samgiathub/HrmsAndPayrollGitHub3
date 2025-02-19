CREATE TABLE [dbo].[T0040_HRMS_General_Setting] (
    [Gen_ID]      NUMERIC (18)    NOT NULL,
    [Rec_Post_ID] NUMERIC (18)    NULL,
    [Rec_Req_ID]  NUMERIC (18)    NULL,
    [Process_ID]  NUMERIC (18)    NOT NULL,
    [For_Date]    DATETIME        NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NOT NULL,
    [Login_ID]    NUMERIC (18)    NOT NULL,
    [Actual_Rate] NUMERIC (18, 2) NULL,
    [Min_Rate]    NUMERIC (18, 2) NULL,
    [Max_Rate]    NUMERIC (18, 2) NULL,
    [Sys_Date]    DATETIME        NULL,
    CONSTRAINT [PK_T0040_HRMS_General_Setting] PRIMARY KEY CLUSTERED ([Gen_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_HRMS_General_Setting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_HRMS_General_Setting_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0040_HRMS_General_Setting_T0040_HRMS_R_PROCESS_MASTER] FOREIGN KEY ([Process_ID]) REFERENCES [dbo].[T0040_HRMS_R_PROCESS_MASTER] ([Process_ID]),
    CONSTRAINT [FK_T0040_HRMS_General_Setting_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_ID]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id])
);

