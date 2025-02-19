CREATE TABLE [dbo].[T0040_PerformanceFeedback_Master] (
    [PerformanceF_ID]   NUMERIC (18)   NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NOT NULL,
    [Performance_Name]  NVARCHAR (100) NULL,
    [Performance_Desc]  NVARCHAR (500) NULL,
    [Performance_Sort]  INT            NULL,
    [IsActive]          TINYINT        DEFAULT ((1)) NOT NULL,
    [InActive_EffeDate] DATETIME       NULL,
    [Evaluation_Type]   VARCHAR (7)    DEFAULT ('All') NOT NULL,
    [Effective_Date]    DATETIME       NULL,
    CONSTRAINT [PK_T0040_PerformanceFeedback_Master] PRIMARY KEY CLUSTERED ([PerformanceF_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_PerformanceFeedback_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

