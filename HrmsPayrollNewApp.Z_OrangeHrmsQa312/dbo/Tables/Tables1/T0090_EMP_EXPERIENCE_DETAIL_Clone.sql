CREATE TABLE [dbo].[T0090_EMP_EXPERIENCE_DETAIL_Clone] (
    [Emp_ID]         NUMERIC (18)    NOT NULL,
    [Row_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [Employer_Name]  VARCHAR (100)   NOT NULL,
    [Desig_Name]     VARCHAR (100)   NOT NULL,
    [St_Date]        DATETIME        NOT NULL,
    [End_Date]       DATETIME        NOT NULL,
    [System_Date]    DATETIME        NOT NULL,
    [Login_Id]       NUMERIC (18)    NOT NULL,
    [CTC_Amount]     NUMERIC (18)    NULL,
    [Gross_Salary]   NUMERIC (18)    NULL,
    [Exp_Remarks]    NVARCHAR (500)  NULL,
    [Emp_Branch]     VARCHAR (100)   NULL,
    [Emp_Location]   VARCHAR (100)   NULL,
    [Manager_Name]   VARCHAR (100)   NULL,
    [Contact_number] NVARCHAR (50)   NULL,
    [EmpExp]         NUMERIC (18, 2) NULL,
    [IndustryType]   VARCHAR (150)   NULL,
    [attach_doc]     NVARCHAR (MAX)  NULL
);

