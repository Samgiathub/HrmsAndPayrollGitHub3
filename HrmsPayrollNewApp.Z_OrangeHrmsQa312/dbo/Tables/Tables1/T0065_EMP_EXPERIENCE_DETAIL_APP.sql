CREATE TABLE [dbo].[T0065_EMP_EXPERIENCE_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT          NOT NULL,
    [Emp_Application_ID] INT             NOT NULL,
    [Row_ID]             INT             NOT NULL,
    [Cmp_ID]             INT             NOT NULL,
    [Employer_Name]      VARCHAR (100)   NOT NULL,
    [Desig_Name]         VARCHAR (100)   NOT NULL,
    [St_Date]            DATETIME        NOT NULL,
    [End_Date]           DATETIME        NOT NULL,
    [CTC_Amount]         NUMERIC (18)    NULL,
    [Gross_Salary]       NUMERIC (18)    NULL,
    [Exp_Remarks]        NVARCHAR (500)  NULL,
    [Emp_Branch]         VARCHAR (100)   NULL,
    [Emp_Location]       VARCHAR (100)   NULL,
    [Manager_Name]       VARCHAR (100)   NULL,
    [Contact_number]     NVARCHAR (50)   NULL,
    [EmpExp]             NUMERIC (18, 2) NULL,
    [IndustryType]       VARCHAR (150)   NULL,
    [Approved_Emp_ID]    INT             NULL,
    [Approved_Date]      DATETIME        NULL,
    [Rpt_Level]          INT             NULL,
    CONSTRAINT [FK_T0065_EMP_EXPERIENCE_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

