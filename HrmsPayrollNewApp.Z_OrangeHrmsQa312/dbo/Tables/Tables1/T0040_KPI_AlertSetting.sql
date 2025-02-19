CREATE TABLE [dbo].[T0040_KPI_AlertSetting] (
    [KPI_AlertId]         NUMERIC (18) NOT NULL,
    [Cmp_Id]              NUMERIC (18) NOT NULL,
    [KPI_AlertDay]        NUMERIC (18) NULL,
    [KPI_Month]           NUMERIC (18) NULL,
    [KPI_AlertNodays]     NUMERIC (18) NULL,
    [KPI_Active]          INT          CONSTRAINT [DF_T0040_KPI_AlertSetting_KPI_Active] DEFAULT ((1)) NULL,
    [KPI_Type]            INT          NULL,
    [KPI_Preference]      BIT          NULL,
    [Emp_TrainingSuggest] BIT          NULL,
    [Allow_EditObjective] BIT          NULL,
    [Allow_EmpEditObj]    BIT          NULL,
    [KPI_AlertType]       INT          NULL,
    [Allow_Emp_IRating]   BIT          NULL,
    [Allow_Emp_FRating]   BIT          NULL,
    CONSTRAINT [PK_T0040_KPI_AlertSetting] PRIMARY KEY CLUSTERED ([KPI_AlertId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_KPI_AlertSetting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

