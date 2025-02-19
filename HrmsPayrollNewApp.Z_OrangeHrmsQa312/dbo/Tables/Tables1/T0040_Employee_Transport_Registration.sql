CREATE TABLE [dbo].[T0040_Employee_Transport_Registration] (
    [Transport_Reg_ID] NUMERIC (18) NOT NULL,
    [Emp_ID]           NUMERIC (18) NULL,
    [Route_ID]         NUMERIC (18) NULL,
    [Pickup_ID]        NUMERIC (18) NULL,
    [Vehicle_ID]       NUMERIC (18) NULL,
    [Designation_ID]   NUMERIC (18) NULL,
    [Transport_Status] INT          NULL,
    [Transport_Type]   CHAR (1)     NULL,
    [Effective_Date]   DATETIME     NULL,
    [Cmp_ID]           NUMERIC (18) NULL,
    [Created_By]       NUMERIC (18) NULL,
    [Created_Date]     DATETIME     NULL,
    [Modified_By]      NUMERIC (18) NULL,
    [Modified_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0040_Employee_Transport_Registration] PRIMARY KEY CLUSTERED ([Transport_Reg_ID] ASC),
    CONSTRAINT [FK_T0040_Employee_Transport_Registration_T0040_PickupStation_Master] FOREIGN KEY ([Pickup_ID]) REFERENCES [dbo].[T0040_PickupStation_Master] ([Pickup_ID]),
    CONSTRAINT [FK_T0040_Employee_Transport_Registration_T0040_Route_Master] FOREIGN KEY ([Route_ID]) REFERENCES [dbo].[T0040_Route_Master] ([Route_ID]),
    CONSTRAINT [FK_T0040_Employee_Transport_Registration_T0040_Vehicle_Master] FOREIGN KEY ([Vehicle_ID]) REFERENCES [dbo].[T0040_Vehicle_Master] ([Vehicle_ID]),
    CONSTRAINT [FK_T0040_Employee_Transport_Registration_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

