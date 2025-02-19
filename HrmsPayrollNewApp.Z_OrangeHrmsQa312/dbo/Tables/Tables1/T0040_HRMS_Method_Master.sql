CREATE TABLE [dbo].[T0040_HRMS_Method_Master] (
    [Method_Id] NUMERIC (18)   NOT NULL,
    [Cmp_ID]    NUMERIC (18)   NOT NULL,
    [Method]    NVARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_HRMS_Method_Master] PRIMARY KEY CLUSTERED ([Method_Id] ASC) WITH (FILLFACTOR = 80)
);

