CREATE TABLE [dbo].[T0240_Perquisites_Master] (
    [Perquisites_Id] NUMERIC (18)   NOT NULL,
    [Cmp_id]         NUMERIC (18)   NOT NULL,
    [Name]           NVARCHAR (200) NOT NULL,
    [Sort_Name]      NVARCHAR (10)  NOT NULL,
    [Sorting_no]     NUMERIC (18)   CONSTRAINT [DF_T0240_Perquisites_Master_Sorting_no] DEFAULT ((0)) NOT NULL,
    [Def_id]         NUMERIC (10)   CONSTRAINT [DF_T0240_Perquisites_Master_Def_id] DEFAULT ((0)) NOT NULL,
    [Remarks]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_T0240_Perquisites_Master] PRIMARY KEY CLUSTERED ([Perquisites_Id] ASC) WITH (FILLFACTOR = 80)
);

