CREATE TABLE [dbo].[T0110_IT_Emp_Details] (
    [Tran_ID]          NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NULL,
    [Emp_ID]           NUMERIC (18)    NULL,
    [Financial_Year]   VARCHAR (50)    NULL,
    [IT_ID]            NUMERIC (18)    NULL,
    [Date]             DATETIME        NULL,
    [System_Date]      DATETIME        NULL,
    [Change_Date]      DATETIME        NULL,
    [Amount]           NUMERIC (18, 2) NULL,
    [Detail_1]         VARCHAR (MAX)   NULL,
    [Detail_2]         VARCHAR (MAX)   NULL,
    [Detail_3]         VARCHAR (MAX)   NULL,
    [Comments]         VARCHAR (MAX)   NULL,
    [FileName]         VARCHAR (200)   NULL,
    [Child_1]          NUMERIC (4)     NULL,
    [Child_2]          NUMERIC (4)     NULL,
    [Medical80DDBType] TINYINT         NULL,
    [field_name]       VARCHAR (200)   NULL,
    [Is_Compare_Flag]  VARCHAR (50)    NULL,
    [BankName]         VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0110_IT_Emp_Details] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

