CREATE TABLE [dbo].[T0020_PRIVILEGE_MASTER] (
    [Privilege_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_Id]               NUMERIC (18)   NOT NULL,
    [Privilege_Name]       NVARCHAR (50)  NULL,
    [Is_Active]            TINYINT        CONSTRAINT [DF_T0020_PRIVILEGE_MASTER_Is_Active] DEFAULT ((1)) NULL,
    [Privilege_Type]       TINYINT        CONSTRAINT [DF_T0020_PRIVILEGE_MASTER_Privilege_Type] DEFAULT ((0)) NULL,
    [Branch_Id]            NUMERIC (18)   NULL,
    [Branch_Id_Multi]      NVARCHAR (MAX) NULL,
    [Vertical_ID_Multi]    NVARCHAR (MAX) NULL,
    [SubVertical_ID_Multi] NVARCHAR (MAX) NULL,
    [Department_Id_Multi]  VARCHAR (MAX)  NULL,
    [State_id_Multi]       NVARCHAR (MAX) NULL,
    [District_id_Multi]    NVARCHAR (MAX) NULL,
    [Tehsil_id_Multi]      NVARCHAR (MAX) NULL,
    [Old_Effect]           INT            NULL,
    CONSTRAINT [PK_T0020_PRIVILEGE_MASTER] PRIMARY KEY CLUSTERED ([Privilege_ID] ASC) WITH (FILLFACTOR = 80)
);

