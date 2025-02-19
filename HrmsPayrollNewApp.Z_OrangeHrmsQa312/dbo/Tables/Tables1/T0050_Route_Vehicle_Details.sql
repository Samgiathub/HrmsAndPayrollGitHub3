CREATE TABLE [dbo].[T0050_Route_Vehicle_Details] (
    [Assign_ID]      NUMERIC (18) NOT NULL,
    [Vehicle_ID]     NUMERIC (18) NULL,
    [Route_ID]       NUMERIC (18) NULL,
    [Effective_Date] DATETIME     NULL,
    [Cmp_ID]         NUMERIC (18) NULL,
    [Created_By]     NUMERIC (18) NULL,
    [Created_Date]   DATETIME     NULL,
    CONSTRAINT [PK_T0050_Route_Vehicle_Details] PRIMARY KEY CLUSTERED ([Assign_ID] ASC),
    CONSTRAINT [FK_T0050_Route_Vehicle_Details_T0040_Route_Master] FOREIGN KEY ([Route_ID]) REFERENCES [dbo].[T0040_Route_Master] ([Route_ID]),
    CONSTRAINT [FK_T0050_Route_Vehicle_Details_T0040_Vehicle_Master] FOREIGN KEY ([Vehicle_ID]) REFERENCES [dbo].[T0040_Vehicle_Master] ([Vehicle_ID])
);

