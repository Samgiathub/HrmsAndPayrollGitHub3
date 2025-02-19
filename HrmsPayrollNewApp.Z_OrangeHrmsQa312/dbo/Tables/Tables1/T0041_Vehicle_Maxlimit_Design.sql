CREATE TABLE [dbo].[T0041_Vehicle_Maxlimit_Design] (
    [Tran_ID]               NUMERIC (18)    NOT NULL,
    [Vehicle_ID]            INT             NOT NULL,
    [Desig_ID]              NUMERIC (18)    NULL,
    [Grade_ID]              NUMERIC (18)    NULL,
    [Branch_ID]             NUMERIC (18)    NULL,
    [Max_Limit]             NUMERIC (18, 2) CONSTRAINT [DF_T0041_Vehicle_Maxlimit_Design_Max_Limit] DEFAULT ((0)) NOT NULL,
    [Employee_Contribution] FLOAT (53)      NOT NULL,
    CONSTRAINT [PK_T0041_Vehicle_Maxlimit_Design] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0041_Vehicle_Maxlimit_Design_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_ID]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0041_Vehicle_Maxlimit_Design_T0040_VEHICLE_TYPE_MASTER] FOREIGN KEY ([Vehicle_ID]) REFERENCES [dbo].[T0040_VEHICLE_TYPE_MASTER] ([Vehicle_ID])
);

