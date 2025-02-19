CREATE TABLE [dbo].[T0040_Grievance_Type_Master] (
    [GrievanceTypeID]     INT            NOT NULL,
    [GrievanceTypeCode]   NVARCHAR (MAX) NULL,
    [GrievanceTypeTitle]  NVARCHAR (MAX) NULL,
    [GrievanceTypeStatus] NVARCHAR (MAX) NULL,
    [GrievanceTypeCDTM]   DATETIME       NULL,
    [GrievanceTypeUDTM]   DATETIME       NULL,
    [GrievanceTypeLog]    NVARCHAR (MAX) NULL,
    [Is_Active]           INT            CONSTRAINT [DF__T0040_Gri__Is_Ac__2127F896] DEFAULT ((1)) NULL,
    [Cmp_ID]              INT            NULL,
    CONSTRAINT [PK_T0040_Grievance_Type_Master] PRIMARY KEY CLUSTERED ([GrievanceTypeID] ASC) WITH (FILLFACTOR = 80)
);

