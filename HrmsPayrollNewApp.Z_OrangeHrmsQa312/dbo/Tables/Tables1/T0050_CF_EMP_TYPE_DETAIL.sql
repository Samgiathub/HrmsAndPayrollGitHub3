CREATE TABLE [dbo].[T0050_CF_EMP_TYPE_DETAIL] (
    [Setting_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]             NUMERIC (18)  NOT NULL,
    [Effective_Date]     DATETIME      NULL,
    [Type_ID]            NUMERIC (18)  NULL,
    [Leave_ID]           NUMERIC (18)  NULL,
    [CF_Type_ID]         NUMERIC (18)  NULL,
    [Reset_Months]       NUMERIC (18)  CONSTRAINT [DF_T0050_CF_EMP_TYPE_DETAIL_Reset_Months] DEFAULT ((0)) NULL,
    [Duration]           VARCHAR (50)  NOT NULL,
    [CF_Months]          NVARCHAR (50) NULL,
    [Release_Month]      NUMERIC (18)  DEFAULT ((1)) NULL,
    [Reset_Month_String] NVARCHAR (50) NULL,
    [Laps_After_Release] TINYINT       NULL,
    CONSTRAINT [PK_T0050_CF_EMP_TYPE_DETAIL] PRIMARY KEY CLUSTERED ([Setting_ID] ASC) WITH (FILLFACTOR = 80)
);

