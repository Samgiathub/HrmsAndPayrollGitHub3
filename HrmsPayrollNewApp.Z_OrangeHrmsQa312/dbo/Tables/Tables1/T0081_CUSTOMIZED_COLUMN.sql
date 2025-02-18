﻿CREATE TABLE [dbo].[T0081_CUSTOMIZED_COLUMN] (
    [Tran_Id]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]       NUMERIC (18)  CONSTRAINT [DF_T0081_CUSTOMIZED_COLUMN_Cmp_Id] DEFAULT ((0)) NOT NULL,
    [Table_Name]   VARCHAR (200) NOT NULL,
    [Column_Name]  VARCHAR (200) NOT NULL,
    [Active]       TINYINT       CONSTRAINT [DF_T0081_CUSTOMIZED_COLUMN_Active] DEFAULT ((1)) NOT NULL,
    [Ess_Editable] TINYINT       CONSTRAINT [DF_T0081_CUSTOMIZED_COLUMN_Ess_Editable] DEFAULT ((0)) NOT NULL,
    [Ess_Visible]  TINYINT       CONSTRAINT [DF_T0081_CUSTOMIZED_COLUMN_Ess_Visible] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0081_CUSTOMIZED_COLUMN] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

