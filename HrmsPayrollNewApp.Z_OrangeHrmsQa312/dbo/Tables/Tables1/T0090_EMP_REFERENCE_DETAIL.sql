CREATE TABLE [dbo].[T0090_EMP_REFERENCE_DETAIL] (
    [Reference_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [R_Emp_ID]         NUMERIC (18)    NOT NULL,
    [For_Date]         DATETIME        NOT NULL,
    [Ref_Description]  VARCHAR (100)   NULL,
    [Amount]           NUMERIC (18, 2) NOT NULL,
    [Comments]         VARCHAR (100)   NULL,
    [Source_Type]      INT             CONSTRAINT [DF_T0090_EMP_REFERENCE_DETAIL_Source Type] DEFAULT ((2)) NOT NULL,
    [Source_Name]      INT             DEFAULT ((0)) NULL,
    [Contact_Person]   VARCHAR (100)   NULL,
    [Designation]      VARCHAR (50)    NULL,
    [City]             VARCHAR (50)    NULL,
    [Mobile]           VARCHAR (10)    NULL,
    [Description]      VARCHAR (MAX)   NULL,
    [Ref_Month]        NUMERIC (18)    NULL,
    [Ref_Year]         NUMERIC (18)    NULL,
    [Effect_In_Salary] TINYINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0090_EMP_REFERENCE_DETAIL] PRIMARY KEY CLUSTERED ([Reference_ID] ASC) WITH (FILLFACTOR = 80)
);

