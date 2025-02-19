CREATE TABLE [dbo].[T0040_Vertical_Segment] (
    [Vertical_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_ID]               NUMERIC (18)  NULL,
    [Vertical_Code]        VARCHAR (50)  NULL,
    [Vertical_Name]        VARCHAR (100) NULL,
    [Vertical_Description] VARCHAR (250) NULL,
    [IsActive]             TINYINT       NULL,
    [InActive_EffeDate]    DATETIME      NULL,
    CONSTRAINT [PK_T0040_Vertical_Segment] PRIMARY KEY CLUSTERED ([Vertical_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Vertical_Segment_Table_1] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

