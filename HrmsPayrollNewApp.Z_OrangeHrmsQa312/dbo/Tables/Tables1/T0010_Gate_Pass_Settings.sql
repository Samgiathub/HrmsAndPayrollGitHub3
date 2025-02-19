CREATE TABLE [dbo].[T0010_Gate_Pass_Settings] (
    [Tran_id]           NUMERIC (18)    NOT NULL,
    [cmp_id]            NUMERIC (18)    CONSTRAINT [DF_T0010_Gate_Pass_Settings_cmp_id] DEFAULT ((0)) NOT NULL,
    [Branch_id]         NUMERIC (18)    CONSTRAINT [DF_T0010_Gate_Pass_Settings_Branch_id] DEFAULT ((0)) NOT NULL,
    [Upto_days]         NUMERIC (18)    CONSTRAINT [DF_T0010_Gate_Pass_Settings_Upto_days] DEFAULT ((0)) NOT NULL,
    [Upto_Hours]        VARCHAR (25)    NULL,
    [Deduct_days]       NUMERIC (18, 2) CONSTRAINT [DF_T0010_Gate_Pass_Settings_Deduct_days] DEFAULT ((0)) NOT NULL,
    [Above_Hours]       VARCHAR (25)    NULL,
    [Deduct_Above_days] NUMERIC (18, 2) CONSTRAINT [DF_T0010_Gate_Pass_Settings_Deduct_Above_days] DEFAULT ((0)) NOT NULL
);

