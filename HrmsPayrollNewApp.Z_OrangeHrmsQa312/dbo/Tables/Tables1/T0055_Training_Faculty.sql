CREATE TABLE [dbo].[T0055_Training_Faculty] (
    [Training_FacultyId]       NUMERIC (18)  NOT NULL,
    [Cmp_Id]                   NUMERIC (18)  NOT NULL,
    [Training_InstituteId]     NUMERIC (18)  NOT NULL,
    [Faculty_Name]             VARCHAR (100) NOT NULL,
    [Faculty_Contact]          VARCHAR (50)  NULL,
    [Active]                   BIT           CONSTRAINT [DF_T0055_Training_Faculty_Active] DEFAULT ((1)) NULL,
    [Training_Institute_LocId] NUMERIC (18)  NULL,
    [Training_Id]              NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0055_Training_Faculty] PRIMARY KEY CLUSTERED ([Training_FacultyId] ASC),
    CONSTRAINT [FK_T0055_Training_Faculty_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_Training_Faculty_T0040_Hrms_Training_master] FOREIGN KEY ([Training_Id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0055_Training_Faculty_T0050_Training_Institute_Master] FOREIGN KEY ([Training_InstituteId]) REFERENCES [dbo].[T0050_Training_Institute_Master] ([Training_InstituteId]),
    CONSTRAINT [FK_T0055_Training_Faculty_T0050_Training_Location_Master] FOREIGN KEY ([Training_Institute_LocId]) REFERENCES [dbo].[T0050_Training_Location_Master] ([Training_Institute_LocId])
);

