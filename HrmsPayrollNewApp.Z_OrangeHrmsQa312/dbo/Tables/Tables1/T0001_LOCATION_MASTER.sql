CREATE TABLE [dbo].[T0001_LOCATION_MASTER] (
    [Loc_ID]        NUMERIC (18)   NOT NULL,
    [Loc_name]      NVARCHAR (150) NULL,
    [Att_Time_Diff] NVARCHAR (50)  NULL,
    [Loc_Cat_ID]    NUMERIC (18)   DEFAULT (NULL) NULL,
    CONSTRAINT [PK_location_master] PRIMARY KEY CLUSTERED ([Loc_ID] ASC) WITH (FILLFACTOR = 80)
);

