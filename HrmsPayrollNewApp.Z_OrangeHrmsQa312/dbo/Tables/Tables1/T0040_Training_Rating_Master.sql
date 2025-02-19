CREATE TABLE [dbo].[T0040_Training_Rating_Master] (
    [Rat_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]          NUMERIC (18)   NULL,
    [Effective_Date]  DATETIME       NULL,
    [Rat_Description] VARCHAR (200)  NULL,
    [Rat_Score]       NUMERIC (5, 2) NULL,
    [Modify_Date]     DATETIME       NULL,
    [Modify_By]       NUMERIC (18)   NULL,
    [Ip_Address]      VARCHAR (20)   NULL,
    PRIMARY KEY CLUSTERED ([Rat_ID] ASC)
);

