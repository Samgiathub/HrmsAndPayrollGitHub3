CREATE TABLE [dbo].[T0030_Hrms_Training_Type] (
    [Training_Type_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_Id]                 NUMERIC (18)  NOT NULL,
    [Training_TypeName]      VARCHAR (100) NOT NULL,
    [Type_OJT]               TINYINT       NULL,
    [Type_Induction]         TINYINT       NULL,
    [Induction_Traning_Dept] TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0030_Hrms_Training_Type] PRIMARY KEY CLUSTERED ([Training_Type_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0030_Hrms_Training_Type_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

