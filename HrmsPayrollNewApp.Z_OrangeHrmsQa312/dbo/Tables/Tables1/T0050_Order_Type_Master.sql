CREATE TABLE [dbo].[T0050_Order_Type_Master] (
    [Order_Type_Id]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]          NUMERIC (18)  NOT NULL,
    [Order_Type_Name] VARCHAR (MAX) NOT NULL,
    [Remarks]         VARCHAR (MAX) NULL,
    [Modify_Date]     DATETIME      CONSTRAINT [DF_T0050_Order_Type_Master_Modify_Date] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_T0050_Order_Type_Master] PRIMARY KEY CLUSTERED ([Order_Type_Id] ASC) WITH (FILLFACTOR = 80)
);

