CREATE TABLE [dbo].[T0040_Route_Master] (
    [Route_ID]       NUMERIC (18)    NOT NULL,
    [Route_Name]     VARCHAR (50)    NULL,
    [Route_No]       VARCHAR (50)    NULL,
    [Route_KM]       NUMERIC (18, 2) NULL,
    [Fuel_Place]     VARCHAR (50)    NULL,
    [Vehicle_ID]     NUMERIC (18)    NULL,
    [Effective_Date] DATETIME        NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Created_By]     NUMERIC (18)    NULL,
    [Created_Date]   DATETIME        NULL,
    [Modified_By]    NUMERIC (18)    NULL,
    [Modified_Date]  DATETIME        NULL,
    CONSTRAINT [PK_T0040_Route_Master] PRIMARY KEY CLUSTERED ([Route_ID] ASC)
);

