CREATE TABLE [dbo].[T0065_EMP_REFERENCE_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT          NOT NULL,
    [Emp_Application_ID] INT             NOT NULL,
    [Reference_ID]       INT             NOT NULL,
    [Cmp_ID]             INT             NOT NULL,
    [R_Emp_ID]           INT             NOT NULL,
    [Ref_Description]    VARCHAR (100)   NULL,
    [Amount]             NUMERIC (18, 2) NOT NULL,
    [Comments]           VARCHAR (100)   NULL,
    [Source_Type]        INT             NOT NULL,
    [Source_Name]        INT             NULL,
    [Contact_Person]     VARCHAR (100)   NULL,
    [Designation]        VARCHAR (50)    NULL,
    [City]               VARCHAR (50)    NULL,
    [Mobile]             VARCHAR (10)    NULL,
    [Description]        VARCHAR (MAX)   NULL,
    [Ref_Month]          NUMERIC (18)    NULL,
    [Ref_Year]           NUMERIC (18)    NULL,
    [Approved_Emp_ID]    INT             NULL,
    [Approved_Date]      DATETIME        NULL,
    [Rpt_Level]          INT             NULL,
    CONSTRAINT [FK_T0065_EMP_REFERENCE_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

