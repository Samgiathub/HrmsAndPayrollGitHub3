CREATE TABLE [dbo].[T0210_MONTHLY_Sal_POS_DETAIL] (
    [M_PS_Tran_ID]   INT             IDENTITY (1, 1) NOT NULL,
    [EMP_ID]         NUMERIC (10)    NULL,
    [AD_ID]          NUMERIC (10)    NULL,
    [Account]        NVARCHAR (50)   NULL,
    [Center_Code]    NVARCHAR (50)   NULL,
    [Segment_ID]     NUMERIC (5)     NULL,
    [Ammount]        NUMERIC (18, 2) NULL,
    [POst_req_ID]    INT             NULL,
    [Post__Date]     DATETIME        NULL,
    [Branch]         VARCHAR (50)    NULL,
    [Allowance_Name] VARCHAR (50)    NULL,
    [R_Post_Req_ID]  VARCHAR (10)    NULL
);

