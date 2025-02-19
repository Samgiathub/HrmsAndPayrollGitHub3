CREATE TABLE [dbo].[T0050_Sales_Assigned_Detail] (
    [SAD_Tran_ID]      NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Target_Tran_ID]   NUMERIC (18)    NOT NULL,
    [Week_Tran_ID]     NUMERIC (18)    NOT NULL,
    [Assigned_Target]  NUMERIC (18, 2) NULL,
    [Achieved_Target]  NUMERIC (18, 2) NULL,
    [Achieved_Percent] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0050_Sales_Assigned_Detail] PRIMARY KEY CLUSTERED ([SAD_Tran_ID] ASC),
    CONSTRAINT [FK_T0050_Sales_Assigned_Detail_T0040_Sales_Assigned_Target] FOREIGN KEY ([Target_Tran_ID]) REFERENCES [dbo].[T0040_Sales_Assigned_Target] ([Target_Tran_ID]),
    CONSTRAINT [FK_T0050_Sales_Assigned_Detail_T0040_Sales_Week_Master] FOREIGN KEY ([Week_Tran_ID]) REFERENCES [dbo].[T0040_Sales_Week_Master] ([Week_Tran_ID])
);

