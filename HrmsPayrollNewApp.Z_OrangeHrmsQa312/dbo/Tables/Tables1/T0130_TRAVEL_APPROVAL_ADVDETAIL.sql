CREATE TABLE [dbo].[T0130_TRAVEL_APPROVAL_ADVDETAIL] (
    [Travel_Approval_AdvDetail_ID] NUMERIC (18)    NOT NULL,
    [Travel_Approval_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]                       NUMERIC (18)    NOT NULL,
    [Expence_Type]                 VARCHAR (100)   NOT NULL,
    [Amount]                       NUMERIC (18, 2) NOT NULL,
    [Adv_Detail_Desc]              NVARCHAR (250)  NULL,
    [Curr_ID]                      NUMERIC (18)    DEFAULT (NULL) NULL,
    [Amount_dollar]                NUMERIC (18, 2) DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0130_TRAVEL_APPROVAL_ADVDETAIL] PRIMARY KEY CLUSTERED ([Travel_Approval_AdvDetail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_TRAVEL_APPROVAL_ADVDETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_TRAVEL_APPROVAL_ADVDETAIL_T0120_TRAVEL_APPROVAL] FOREIGN KEY ([Travel_Approval_ID]) REFERENCES [dbo].[T0120_TRAVEL_APPROVAL] ([Travel_Approval_ID])
);

