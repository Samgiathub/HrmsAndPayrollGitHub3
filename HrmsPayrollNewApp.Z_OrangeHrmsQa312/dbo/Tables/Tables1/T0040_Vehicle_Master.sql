CREATE TABLE [dbo].[T0040_Vehicle_Master] (
    [Vehicle_ID]       NUMERIC (18) NOT NULL,
    [Vehicle_Name]     VARCHAR (50) NULL,
    [Vehicle_No]       VARCHAR (50) NULL,
    [Vehicle_Type]     VARCHAR (50) NULL,
    [Vehicle_Owner]    VARCHAR (50) NULL,
    [Owner_Name]       VARCHAR (50) NULL,
    [Owner_ContactNo]  VARCHAR (50) NULL,
    [Driver_Name]      VARCHAR (50) NULL,
    [Driver_ContactNo] VARCHAR (50) NULL,
    [Cmp_ID]           NUMERIC (18) NULL,
    [Created_By]       NUMERIC (18) NULL,
    [Created_Date]     DATETIME     NULL,
    [Modify_By]        NUMERIC (18) NULL,
    [Modify_Date]      DATETIME     NULL,
    CONSTRAINT [PK_T0040_Vehicle_Master] PRIMARY KEY CLUSTERED ([Vehicle_ID] ASC)
);

