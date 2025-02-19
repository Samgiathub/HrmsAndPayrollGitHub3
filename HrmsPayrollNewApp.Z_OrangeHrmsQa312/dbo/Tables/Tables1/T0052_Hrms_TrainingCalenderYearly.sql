CREATE TABLE [dbo].[T0052_Hrms_TrainingCalenderYearly] (
    [Training_CalenderId] NUMERIC (18)  NOT NULL,
    [Cmp_Id]              NUMERIC (18)  NULL,
    [Calender_Year]       NUMERIC (18)  NULL,
    [Calender_Month]      NUMERIC (18)  NULL,
    [Training_Id]         NUMERIC (18)  NULL,
    [Branch_ID]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0052_Hrms_TrainingCalenderYearly] PRIMARY KEY CLUSTERED ([Training_CalenderId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_Hrms_TrainingCalenderYearly_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_Hrms_TrainingCalenderYearly_T0040_Hrms_Training_master] FOREIGN KEY ([Training_Id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id])
);

