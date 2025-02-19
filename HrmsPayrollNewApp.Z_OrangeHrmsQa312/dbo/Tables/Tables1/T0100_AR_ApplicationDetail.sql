CREATE TABLE [dbo].[T0100_AR_ApplicationDetail] (
    [AR_AppDetail_ID] NUMERIC (18)    NOT NULL,
    [AR_App_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [AD_ID]           NUMERIC (18)    NOT NULL,
    [AD_Flag]         CHAR (10)       NULL,
    [AD_Mode]         NVARCHAR (50)   NULL,
    [AD_Percentage]   NUMERIC (18, 2) NULL,
    [AD_Amount]       NUMERIC (18, 2) NULL,
    [E_AD_Max_Limit]  NUMERIC (18, 2) NULL,
    [Comments]        NVARCHAR (4000) NULL,
    [CreatedBy]       NUMERIC (18)    NOT NULL,
    [DateCreated]     DATETIME        NOT NULL,
    [Modifiedby]      NUMERIC (18)    NULL,
    [DateModified]    DATETIME        NULL,
    CONSTRAINT [PK_T0100_AR_ApplicationDetail] PRIMARY KEY CLUSTERED ([AR_AppDetail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_AR_ApplicationDetail_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0100_AR_ApplicationDetail_T0100_AR_Application] FOREIGN KEY ([AR_App_ID]) REFERENCES [dbo].[T0100_AR_Application] ([AR_App_ID])
);

