CREATE TABLE [dbo].[T0040_HRMS_TimeFrame_Master] (
    [TimeFrame_Id] NUMERIC (18)   NOT NULL,
    [Cmp_ID]       NUMERIC (18)   NOT NULL,
    [TimeFrame]    NVARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_HRMS_TimeFrame_Master] PRIMARY KEY CLUSTERED ([TimeFrame_Id] ASC) WITH (FILLFACTOR = 80)
);

