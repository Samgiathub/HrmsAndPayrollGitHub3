CREATE TABLE [dbo].[T0040_Exit_Group_Master] (
    [Group_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]        NUMERIC (18)  NOT NULL,
    [Group_Name]    VARCHAR (64)  NOT NULL,
    [Group_Sort_Id] NUMERIC (18)  NOT NULL,
    [Is_Active]     BIT           NOT NULL,
    [Grp_Rate_Id]   VARCHAR (500) NOT NULL,
    [System_Date]   DATETIME      NOT NULL,
    CONSTRAINT [PK_T0040_Exit_Group_Master] PRIMARY KEY CLUSTERED ([Group_Id] ASC)
);

