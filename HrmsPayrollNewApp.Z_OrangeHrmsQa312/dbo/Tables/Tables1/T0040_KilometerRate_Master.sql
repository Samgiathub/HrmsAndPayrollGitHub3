CREATE TABLE [dbo].[T0040_KilometerRate_Master] (
    [KR_Id]          NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Effective_Date] DATETIME        NULL,
    [Emp_Category]   NVARCHAR (50)   NULL,
    [Vehicle_Type]   NVARCHAR (50)   NULL,
    [RatePer_Km]     NUMERIC (16, 2) NULL,
    [Created_By]     INT             NULL,
    [Created_Date]   DATETIME        NULL,
    CONSTRAINT [PK_T0040_KilometerRate_Master] PRIMARY KEY CLUSTERED ([KR_Id] ASC) WITH (FILLFACTOR = 95)
);

