CREATE TABLE [dbo].[T0040_TYPE_MASTER] (
    [Type_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Type_Name]         VARCHAR (100)   NULL,
    [Type_Dis_No]       NUMERIC (18)    NULL,
    [Type_Def_ID]       NUMERIC (18)    NULL,
    [Encashment_Rate]   NUMERIC (18, 2) CONSTRAINT [DF_T0040_TYPE_MASTER_Encashment_Rate] DEFAULT ((1)) NOT NULL,
    [Type_Code]         VARCHAR (50)    NULL,
    [IsActive]          TINYINT         CONSTRAINT [DF__T0040_TYP__IsAct__7D94D98F] DEFAULT ((1)) NULL,
    [InActive_EffeDate] DATETIME        CONSTRAINT [DF__T0040_TYP__InEff__7E88FDC8] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0040_Type_Master] PRIMARY KEY CLUSTERED ([Type_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Type_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

