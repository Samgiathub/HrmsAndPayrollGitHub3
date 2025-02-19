CREATE TABLE [dbo].[T0040_Master_Cost_Center] (
    [Cost_Slab_id]           NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_id]                 NUMERIC (18)  NULL,
    [effective_date]         DATETIME      NULL,
    [bandid]                 VARCHAR (MAX) NULL,
    [business_segment]       VARCHAR (MAX) NULL,
    [cost_center_id]         VARCHAR (MAX) NULL,
    [cost_center_percentage] VARCHAR (MAX) NULL,
    [Cost_Slab_Name]         VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Cost_Slab_id] ASC) WITH (FILLFACTOR = 95)
);

