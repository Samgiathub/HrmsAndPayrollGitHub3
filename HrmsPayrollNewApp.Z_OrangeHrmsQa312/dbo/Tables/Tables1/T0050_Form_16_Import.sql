CREATE TABLE [dbo].[T0050_Form_16_Import] (
    [Form_ID]        NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Emp_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [Alpha_Emp_Code] VARCHAR (50)   NULL,
    [Financial_Year] VARCHAR (10)   NULL,
    [Report_PartA]   NVARCHAR (500) NULL,
    [Report_PartB]   NVARCHAR (500) NULL,
    [Uploaded_By]    VARCHAR (50)   NULL,
    [Uploaded_On]    DATETIME       NULL,
    CONSTRAINT [PK_T0050_Form_16_Import] PRIMARY KEY CLUSTERED ([Form_ID] ASC)
);

