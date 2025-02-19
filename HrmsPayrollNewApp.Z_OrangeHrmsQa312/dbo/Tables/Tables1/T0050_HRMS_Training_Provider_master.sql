CREATE TABLE [dbo].[T0050_HRMS_Training_Provider_master] (
    [Training_Pro_ID]          NUMERIC (18)  NOT NULL,
    [Provider_Name]            VARCHAR (50)  NULL,
    [Provider_contact_Name]    VARCHAR (50)  NULL,
    [Provider_Number]          NUMERIC (18)  NULL,
    [Provider_Detail]          VARCHAR (500) NULL,
    [Provider_Email]           VARCHAR (50)  NULL,
    [Provider_Website]         VARCHAR (50)  NULL,
    [Training_id]              NUMERIC (18)  NULL,
    [cmp_id]                   NUMERIC (18)  NULL,
    [Provider_Emp_Id]          VARCHAR (MAX) NULL,
    [Provider_TypeId]          NCHAR (10)    NULL,
    [Provider_FacultyId]       VARCHAR (MAX) NULL,
    [Provider_InstituteId]     NUMERIC (18)  NULL,
    [Training_Institute_LocId] NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0050_HRMS_Training_Provider_master] PRIMARY KEY CLUSTERED ([Training_Pro_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_HRMS_Training_Provider_master_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_HRMS_Training_Provider_master_T0040_Hrms_Training_master] FOREIGN KEY ([Training_id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0050_HRMS_Training_Provider_master_T0050_Training_Institute_Master] FOREIGN KEY ([Provider_InstituteId]) REFERENCES [dbo].[T0050_Training_Institute_Master] ([Training_InstituteId]),
    CONSTRAINT [FK_T0050_HRMS_Training_Provider_master_T0050_Training_Location_Master] FOREIGN KEY ([Training_Institute_LocId]) REFERENCES [dbo].[T0050_Training_Location_Master] ([Training_Institute_LocId])
);

