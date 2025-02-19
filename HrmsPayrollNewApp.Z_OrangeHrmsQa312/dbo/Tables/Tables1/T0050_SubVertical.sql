CREATE TABLE [dbo].[T0050_SubVertical] (
    [SubVertical_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_ID]                  NUMERIC (18)  NULL,
    [Vertical_ID]             NUMERIC (18)  NULL,
    [SubVertical_Code]        VARCHAR (100) NULL,
    [SubVertical_Name]        VARCHAR (100) NULL,
    [SubVertical_Description] VARCHAR (250) NULL,
    [IsActive]                TINYINT       NULL,
    [InActive_EffeDate]       DATETIME      NULL,
    CONSTRAINT [PK_T0050_SubVertical] PRIMARY KEY CLUSTERED ([SubVertical_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_SubVertical_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_SubVertical_T0040_Vertical_Segment] FOREIGN KEY ([Vertical_ID]) REFERENCES [dbo].[T0040_Vertical_Segment] ([Vertical_ID])
);

