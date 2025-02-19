CREATE TABLE [dbo].[T0040_Expense_Type_Master] (
    [Expense_Type_ID]       NUMERIC (18)    NOT NULL,
    [Expense_Type_name]     NVARCHAR (30)   NOT NULL,
    [Expense_Type_Group]    NVARCHAR (30)   NOT NULL,
    [Grade_Id_Multi]        VARCHAR (50)    NULL,
    [CMP_ID]                NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Grade_Wise_ExAmount]   TINYINT         DEFAULT ((0)) NOT NULL,
    [Display_FromTime]      TINYINT         DEFAULT (NULL) NULL,
    [is_overlimit]          TINYINT         DEFAULT ((0)) NOT NULL,
    [is_not_pree_post_date] TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Petrol_wise]        TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Deduct]             TINYINT         DEFAULT ((0)) NOT NULL,
    [Deduct_Per]            NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Travel_Mode]           TINYINT         DEFAULT (NULL) NULL,
    [GST_Applicable]        TINYINT         CONSTRAINT [DF_T0040_Expense_Type_Master_GST_Applicable] DEFAULT ((0)) NOT NULL,
    [TravelTypeId]          INT             NULL,
    [No_of_Days]            NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [GuestName]             NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Expense_Type_Master] PRIMARY KEY CLUSTERED ([Expense_Type_ID] ASC) WITH (FILLFACTOR = 80)
);

