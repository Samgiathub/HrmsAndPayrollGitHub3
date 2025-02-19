CREATE TABLE [dbo].[T0045_HRMS_R_PROCESS_TEMPLATE] (
    [Process_Q_ID]    NUMERIC (18)   NOT NULL,
    [Cmp_ID]          NUMERIC (18)   NOT NULL,
    [Process_ID]      NUMERIC (18)   NOT NULL,
    [QUE_Detail]      VARCHAR (500)  NULL,
    [IS_Title]        INT            NULL,
    [Is_Description]  INT            NULL,
    [Is_Raiting]      INT            NULL,
    [is_dynamic]      INT            NULL,
    [Dis_No]          INT            NULL,
    [Question_Type]   INT            NULL,
    [Question_Option] VARCHAR (1500) NULL,
    CONSTRAINT [PK_T0045_HRMS_R_PROCESS_TEMPLATE] PRIMARY KEY CLUSTERED ([Process_Q_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0045_HRMS_R_PROCESS_TEMPLATE_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0045_HRMS_R_PROCESS_TEMPLATE_T0040_HRMS_R_PROCESS_MASTER] FOREIGN KEY ([Process_ID]) REFERENCES [dbo].[T0040_HRMS_R_PROCESS_MASTER] ([Process_ID])
);

