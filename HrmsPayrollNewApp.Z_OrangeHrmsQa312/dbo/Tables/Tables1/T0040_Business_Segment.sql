CREATE TABLE [dbo].[T0040_Business_Segment] (
    [Segment_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_ID]              NUMERIC (18)  NULL,
    [Segment_Code]        VARCHAR (50)  NULL,
    [Segment_Name]        VARCHAR (100) NULL,
    [Segment_Description] VARCHAR (250) NULL,
    [Is_MachineBased]     TINYINT       DEFAULT ((0)) NOT NULL,
    [MachineEmpType]      VARCHAR (20)  NULL,
    [IsActive]            TINYINT       NULL,
    [InActive_EffeDate]   DATETIME      NULL,
    CONSTRAINT [PK_T0040_Business_Segment] PRIMARY KEY CLUSTERED ([Segment_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Business_Segment_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

