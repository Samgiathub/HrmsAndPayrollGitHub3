CREATE TABLE [dbo].[T0140_Travel_Settlement_Application] (
    [Travel_Set_Application_id]   NUMERIC (18)    NOT NULL,
    [Travel_Approval_ID]          NUMERIC (18)    CONSTRAINT [DF_T0140_Travel_Settlement_Application_Travel_Approval_ID] DEFAULT ((0)) NOT NULL,
    [cmp_id]                      NUMERIC (18)    NOT NULL,
    [emp_id]                      NUMERIC (18)    NOT NULL,
    [Advance_Amount]              NUMERIC (18, 2) NOT NULL,
    [Expence]                     NUMERIC (18, 2) NOT NULL,
    [credit]                      NUMERIC (18, 2) NOT NULL,
    [Debit]                       NUMERIC (18, 2) NOT NULL,
    [Comment]                     VARCHAR (1000)  NULL,
    [Document]                    VARCHAR (1000)  NULL,
    [For_date]                    DATETIME        NOT NULL,
    [Visited_Flag]                TINYINT         NOT NULL,
    [Status]                      CHAR (1)        NOT NULL,
    [DirectEntry]                 TINYINT         CONSTRAINT [DF__T0140_Tra__Direc__3B1F9E8B] DEFAULT ((0)) NOT NULL,
    [ODDates]                     VARCHAR (MAX)   NULL,
    [Tour_Agenda_Actual]          NVARCHAR (1000) NULL,
    [IMP_Business_Appoint_Actual] NVARCHAR (1000) NULL,
    [KRA_Tour_Actual]             NVARCHAR (1000) NULL,
    [TravelTypeId]                NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0140_Travel_Settlement_Application] PRIMARY KEY CLUSTERED ([Travel_Set_Application_id] ASC) WITH (FILLFACTOR = 80)
);

