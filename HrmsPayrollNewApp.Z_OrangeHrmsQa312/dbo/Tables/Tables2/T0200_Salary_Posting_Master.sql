CREATE TABLE [dbo].[T0200_Salary_Posting_Master] (
    [Sal_Pos_MID]     NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Doc_No]          NVARCHAR (50) NULL,
    [Doc_Date]        DATETIME      NULL,
    [Doc_Type]        NVARCHAR (50) NULL,
    [Com_Code]        NVARCHAR (50) NULL,
    [Pos_Date]        DATETIME      NULL,
    [Currency_Type]   NVARCHAR (50) NULL,
    [Req_Status_M]    INT           NULL,
    [Login_ID]        NUMERIC (18)  NULL,
    [System_Date]     DATETIME      NULL,
    [Process_type]    VARCHAR (20)  NULL,
    [Post_Req_ID]     INT           NULL,
    [Emp_Cnt]         INT           NULL,
    [GL_Ac_Cnt]       INT           NULL,
    [Cost_Center_CNt] INT           NULL,
    [R_Post_Req_ID]   VARCHAR (10)  NULL,
    CONSTRAINT [PK_T0200_Salary_Posting_Master] PRIMARY KEY CLUSTERED ([Sal_Pos_MID] ASC) WITH (FILLFACTOR = 95)
);

