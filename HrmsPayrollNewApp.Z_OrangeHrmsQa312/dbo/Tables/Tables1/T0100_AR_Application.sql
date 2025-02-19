CREATE TABLE [dbo].[T0100_AR_Application] (
    [AR_App_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [Grd_ID]           NUMERIC (18)    NOT NULL,
    [For_Date]         DATETIME        NOT NULL,
    [Eligibile_Amount] NUMERIC (18, 2) NULL,
    [Total_Amount]     NUMERIC (18, 2) NULL,
    [App_Status]       NUMERIC (18)    NULL,
    [CreatedBy]        NUMERIC (18)    NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [Modifiedby]       NUMERIC (18)    NULL,
    [DateModified]     DATETIME        NULL,
    CONSTRAINT [PK_T0100_AR_Application] PRIMARY KEY CLUSTERED ([AR_App_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_AR_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_AR_Application_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID]),
    CONSTRAINT [FK_T0100_AR_Application_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

