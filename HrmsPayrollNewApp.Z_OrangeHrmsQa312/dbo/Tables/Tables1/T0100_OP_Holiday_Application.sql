CREATE TABLE [dbo].[T0100_OP_Holiday_Application] (
    [Op_Holiday_App_ID]  NUMERIC (18)   NOT NULL,
    [Cmp_ID]             NUMERIC (18)   NOT NULL,
    [Emp_ID]             NUMERIC (18)   NOT NULL,
    [HDay_ID]            NUMERIC (18)   NOT NULL,
    [Op_Holiday_Date]    DATETIME       NOT NULL,
    [Op_Holiday_Status]  CHAR (1)       NOT NULL,
    [Op_Holiday_Comment] VARCHAR (4000) NULL,
    [Created_By]         NUMERIC (18)   NOT NULL,
    [Date_Created]       DATETIME       NOT NULL,
    [Modify_By]          NUMERIC (18)   NULL,
    [Date_Modified]      DATETIME       NULL,
    CONSTRAINT [PK_T0100_OP_Holiday_Application] PRIMARY KEY CLUSTERED ([Op_Holiday_App_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_OP_Holiday_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_OP_Holiday_Application_T0040_HOLIDAY_MASTER] FOREIGN KEY ([HDay_ID]) REFERENCES [dbo].[T0040_HOLIDAY_MASTER] ([Hday_ID]),
    CONSTRAINT [FK_T0100_OP_Holiday_Application_T0040_HOLIDAY_MASTER1] FOREIGN KEY ([HDay_ID]) REFERENCES [dbo].[T0040_HOLIDAY_MASTER] ([Hday_ID]),
    CONSTRAINT [FK_T0100_OP_Holiday_Application_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

