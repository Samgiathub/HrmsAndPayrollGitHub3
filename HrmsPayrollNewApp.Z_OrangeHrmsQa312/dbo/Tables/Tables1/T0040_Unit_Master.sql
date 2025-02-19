CREATE TABLE [dbo].[T0040_Unit_Master] (
    [Unit_ID]     NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]      NUMERIC (18) NULL,
    [Login_ID]    NUMERIC (18) NULL,
    [Unit_Name]   VARCHAR (50) NULL,
    [System_Date] DATETIME     NULL,
    CONSTRAINT [PK_T0040_Unit_Master] PRIMARY KEY CLUSTERED ([Unit_ID] ASC)
);

