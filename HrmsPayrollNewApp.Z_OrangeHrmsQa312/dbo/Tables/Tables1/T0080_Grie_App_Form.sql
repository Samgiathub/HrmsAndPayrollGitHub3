CREATE TABLE [dbo].[T0080_Grie_App_Form] (
    [GrievanceID]       INT            NOT NULL,
    [Type_of_Grie_id]   INT            NULL,
    [Date_of_Grievance] DATETIME       NULL,
    [Grie_Against_id]   INT            NULL,
    [Grievance_Desc]    NVARCHAR (MAX) NULL,
    [Is_Active]         INT            CONSTRAINT [DF_Is_Active] DEFAULT (N'1') NULL,
    [Cmp_ID]            INT            NULL,
    CONSTRAINT [PK_T0040_T0080_Grie_App_Form] PRIMARY KEY CLUSTERED ([GrievanceID] ASC) WITH (FILLFACTOR = 80)
);

