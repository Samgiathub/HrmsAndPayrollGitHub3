CREATE TABLE [dbo].[T0050_HRMS_RangeDept_Allocation] (
    [RangeDept_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NULL,
    [Range_ID]         NUMERIC (18)    NULL,
    [Range_Type]       INT             NULL,
    [Dept_ID]          NUMERIC (18)    NULL,
    [Percent_Allocate] NUMERIC (18, 2) NULL,
    [Effective_Date]   DATETIME        NULL,
    CONSTRAINT [PK_T0050_HRMS_RangeDept_Allocation] PRIMARY KEY CLUSTERED ([RangeDept_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_HRMS_RangeDept_Allocation_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_HRMS_RangeDept_Allocation_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([Dept_ID]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id])
);

