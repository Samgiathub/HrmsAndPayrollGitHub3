CREATE TABLE [dbo].[T0040_PickupStation_Fare_Master] (
    [Fare_ID]        NUMERIC (18)    NOT NULL,
    [Pickup_ID]      NUMERIC (18)    NULL,
    [Fare]           NUMERIC (18, 2) NULL,
    [Discount]       NUMERIC (18, 2) NULL,
    [NetFare]        NUMERIC (18, 2) NULL,
    [Effective_Date] DATETIME        NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Created_By]     NUMERIC (18)    NULL,
    [Created_Date]   DATETIME        NULL,
    [Modified_By]    NUMERIC (18)    NULL,
    [Modified_Date]  DATETIME        NULL,
    CONSTRAINT [PK_T0050_PickupStation_Fare] PRIMARY KEY CLUSTERED ([Fare_ID] ASC),
    CONSTRAINT [FK_T0040_PickupStation_Fare_Master_T0040_PickupStation_Master] FOREIGN KEY ([Pickup_ID]) REFERENCES [dbo].[T0040_PickupStation_Master] ([Pickup_ID])
);

