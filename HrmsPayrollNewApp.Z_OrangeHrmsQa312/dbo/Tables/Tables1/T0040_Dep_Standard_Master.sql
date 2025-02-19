CREATE TABLE [dbo].[T0040_Dep_Standard_Master] (
    [S_ID]         INT            IDENTITY (1, 1) NOT NULL,
    [StandardName] NVARCHAR (100) NULL,
    [Cmp_ID]       INT            NULL,
    [Seq]          INT            NULL,
    PRIMARY KEY CLUSTERED ([S_ID] ASC) WITH (FILLFACTOR = 95)
);

