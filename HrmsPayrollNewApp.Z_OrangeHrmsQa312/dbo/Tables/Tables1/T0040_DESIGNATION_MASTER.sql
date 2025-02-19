CREATE TABLE [dbo].[T0040_DESIGNATION_MASTER] (
    [Desig_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]              NUMERIC (18)    NOT NULL,
    [Desig_Name]          VARCHAR (100)   NOT NULL,
    [Desig_Dis_No]        NUMERIC (18)    NOT NULL,
    [Def_ID]              NUMERIC (18)    NULL,
    [Parent_ID]           NUMERIC (18)    NULL,
    [Is_Main]             TINYINT         NULL,
    [Mode_Of_Travel]      VARCHAR (50)    NULL,
    [Optional_allow_per]  NUMERIC (18, 2) CONSTRAINT [DF__T0040_DES__Optio__350E6054] DEFAULT ((0)) NOT NULL,
    [Desig_Code]          VARCHAR (50)    NULL,
    [IsActive]            TINYINT         CONSTRAINT [DF__T0040_DES__IsAct__3DE468CE] DEFAULT ((1)) NULL,
    [InActive_EffeDate]   DATETIME        CONSTRAINT [DF__T0040_DES__InEff__3ED88D07] DEFAULT (NULL) NULL,
    [Absconding_Reminder] TINYINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_DESIGNATION_MASTER] PRIMARY KEY CLUSTERED ([Desig_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_DESIGNATION_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_DESIGNATION_MASTER_9_805577908__K1_3]
    ON [dbo].[T0040_DESIGNATION_MASTER]([Desig_ID] ASC)
    INCLUDE([Desig_Name]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_51947707_3_1]
    ON [dbo].[T0040_DESIGNATION_MASTER]([Desig_Name], [Desig_ID]);

