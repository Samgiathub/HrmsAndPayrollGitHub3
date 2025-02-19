CREATE TABLE [dbo].[T0040_Bonus_Deduction_Type_Master] (
    [BDType_ID]    NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]       NUMERIC (18)  NULL,
    [Branch_ID]    NUMERIC (18)  NULL,
    [BD_Type_Code] NVARCHAR (50) NULL,
    [BD_Type_Name] NVARCHAR (50) NULL,
    [Created_By]   INT           NULL,
    [Created_Date] DATETIME      NULL,
    CONSTRAINT [PK_T0040_Bonus_Deduction_Type_Master] PRIMARY KEY CLUSTERED ([BDType_ID] ASC) WITH (FILLFACTOR = 95)
);

