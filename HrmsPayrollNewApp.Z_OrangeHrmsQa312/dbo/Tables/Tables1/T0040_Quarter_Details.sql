CREATE TABLE [dbo].[T0040_Quarter_Details] (
    [Qtr_ID]         INT           NOT NULL,
    [Cmp_ID]         INT           NOT NULL,
    [Effective_date] DATETIME      NOT NULL,
    [Qtr_Name]       VARCHAR (150) NOT NULL,
    [From_Month]     INT           NOT NULL,
    [To_Month]       INT           NOT NULL,
    CONSTRAINT [PK_T0040_Quarter_Details] PRIMARY KEY CLUSTERED ([Qtr_ID] ASC) WITH (FILLFACTOR = 95)
);

