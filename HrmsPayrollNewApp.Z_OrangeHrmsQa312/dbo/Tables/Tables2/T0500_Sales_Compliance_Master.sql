CREATE TABLE [dbo].[T0500_Sales_Compliance_Master] (
    [Comp_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NULL,
    [Comp_Name]   VARCHAR (250) NULL,
    [UserID]      NUMERIC (18)  NULL,
    [Modify_Date] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Comp_ID] ASC)
);

