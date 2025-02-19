CREATE TABLE [dbo].[T0040_PickupStation_Master] (
    [Pickup_ID]      NUMERIC (18)    NOT NULL,
    [Pickup_Name]    VARCHAR (50)    NULL,
    [Route_ID]       NUMERIC (18)    NULL,
    [Pickup_KM]      NUMERIC (18, 2) NULL,
    [Effective_Date] DATETIME        NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Created_By]     NUMERIC (18)    NULL,
    [Created_Date]   DATETIME        NULL,
    [Modified_By]    NUMERIC (18)    NULL,
    [Modified_Date]  DATETIME        NULL,
    CONSTRAINT [PK_T0040_PickupStation_Master] PRIMARY KEY CLUSTERED ([Pickup_ID] ASC),
    CONSTRAINT [FK_T0040_PickupStation_Master_T0040_Route_Master] FOREIGN KEY ([Route_ID]) REFERENCES [dbo].[T0040_Route_Master] ([Route_ID])
);

