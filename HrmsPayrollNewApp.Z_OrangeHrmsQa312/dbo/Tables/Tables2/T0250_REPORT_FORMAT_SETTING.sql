CREATE TABLE [dbo].[T0250_REPORT_FORMAT_SETTING] (
    [Tran_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_id]       NUMERIC (18)  NOT NULL,
    [Module_Name]  VARCHAR (50)  NULL,
    [Paper_Value]  NUMERIC (2)   NOT NULL,
    [Format_Value] NUMERIC (2)   NOT NULL,
    [Sorting_No]   NUMERIC (5)   NOT NULL,
    [Format_Name]  VARCHAR (100) NULL,
    CONSTRAINT [PK_T0250_REPORT_FORMAT_SETTING] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

