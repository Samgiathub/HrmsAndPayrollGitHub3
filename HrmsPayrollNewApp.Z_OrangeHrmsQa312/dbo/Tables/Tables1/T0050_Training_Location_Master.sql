CREATE TABLE [dbo].[T0050_Training_Location_Master] (
    [Training_Institute_LocId] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                   NUMERIC (18)  NOT NULL,
    [Training_InstituteId]     NUMERIC (18)  NOT NULL,
    [Institute_LocationCode]   VARCHAR (50)  NOT NULL,
    [Institute_LocationDesc]   VARCHAR (200) NULL,
    CONSTRAINT [PK_T0050_Training_Location_Master] PRIMARY KEY CLUSTERED ([Training_Institute_LocId] ASC),
    CONSTRAINT [FK_T0050_Training_Location_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_Training_Location_Master_T0050_Training_Institute_Master] FOREIGN KEY ([Training_InstituteId]) REFERENCES [dbo].[T0050_Training_Institute_Master] ([Training_InstituteId])
);

