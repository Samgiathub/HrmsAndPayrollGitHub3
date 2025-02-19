CREATE TABLE [dbo].[T0040_Sales_Assigned_Target] (
    [Target_Tran_ID] NUMERIC (18)  NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Branch_ID]      NUMERIC (18)  NOT NULL,
    [Sales_Code]     VARCHAR (100) NULL,
    [Route_ID]       NUMERIC (18)  NULL,
    [Target_Month]   INT           NULL,
    [Target_Year]    INT           NULL,
    CONSTRAINT [PK_T0040_Sales_Assigned_Target] PRIMARY KEY CLUSTERED ([Target_Tran_ID] ASC)
);

