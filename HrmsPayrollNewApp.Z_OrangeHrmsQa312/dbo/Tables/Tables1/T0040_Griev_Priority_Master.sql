CREATE TABLE [dbo].[T0040_Griev_Priority_Master] (
    [G_PriorityID]   INT            NOT NULL,
    [PriorityCode]   NVARCHAR (MAX) NULL,
    [PriorityTitle]  NVARCHAR (MAX) NOT NULL,
    [PriorityStatus] NVARCHAR (MAX) NULL,
    [PriorityCDTM]   DATETIME       NULL,
    [PriorityUDTM]   DATETIME       NULL,
    [PriorityLog]    NVARCHAR (MAX) NULL,
    [Is_Active]      INT            DEFAULT ((1)) NULL,
    [Cmp_ID]         INT            NULL,
    CONSTRAINT [PK_T0040_Griev_Priority_Master] PRIMARY KEY CLUSTERED ([G_PriorityID] ASC) WITH (FILLFACTOR = 80)
);

