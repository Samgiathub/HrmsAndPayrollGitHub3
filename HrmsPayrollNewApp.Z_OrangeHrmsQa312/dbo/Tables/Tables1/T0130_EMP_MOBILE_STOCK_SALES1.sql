CREATE TABLE [dbo].[T0130_EMP_MOBILE_STOCK_SALES1] (
    [Stock_Tran_ID]    NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18) NOT NULL,
    [Mobile_Cat_ID]    NUMERIC (18) NOT NULL,
    [Emp_ID]           NUMERIC (18) NOT NULL,
    [Store_ID]         NUMERIC (18) NOT NULL,
    [For_Date]         DATETIME     NOT NULL,
    [Mobile_Cat_Sale]  NUMERIC (18) NULL,
    [Mobile_Cat_Stock] NUMERIC (18) NULL,
    [Mobile_Remark_ID] NUMERIC (18) NULL,
    [System_Date]      DATETIME     NULL,
    [Login_ID]         NUMERIC (18) NULL,
    [ParentID]         NUMERIC (18) NULL
);

