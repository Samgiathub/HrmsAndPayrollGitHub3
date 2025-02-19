CREATE TABLE [dbo].[T0040_Training_Induction_Master] (
    [Training_Induction_ID] NUMERIC (18)  NOT NULL,
    [Cmp_ID]                NUMERIC (18)  NOT NULL,
    [Dept_ID]               NUMERIC (18)  NOT NULL,
    [Training_id]           NUMERIC (18)  NOT NULL,
    [Contact_Person_ID]     VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_Training_Induction_Master] PRIMARY KEY CLUSTERED ([Training_Induction_ID] ASC),
    CONSTRAINT [FK_T0040_Training_Induction_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Training_Induction_Master_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([Dept_ID]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id]),
    CONSTRAINT [FK_T0040_Training_Induction_Master_T0040_Hrms_Training_master] FOREIGN KEY ([Training_id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id])
);

