CREATE TABLE [dbo].[T0190_Seniority_Award_Slab] (
    [Tran_Id]  NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [cmp_id]   NUMERIC (18)    NOT NULL,
    [AD_ID]    NUMERIC (18)    NOT NULL,
    [From_Age] NUMERIC (18, 2) NULL,
    [To_Age]   NUMERIC (18, 2) NULL,
    [Mode]     VARCHAR (50)    NULL,
    [Amount]   NUMERIC (18, 2) NULL,
    [remarks]  VARCHAR (500)   NULL,
    CONSTRAINT [PK_T0190_Seniority_Award_Slab] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

