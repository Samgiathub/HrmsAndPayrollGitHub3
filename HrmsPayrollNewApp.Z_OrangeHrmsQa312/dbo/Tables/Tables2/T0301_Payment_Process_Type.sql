CREATE TABLE [dbo].[T0301_Payment_Process_Type] (
    [tran_id]              NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Payment_Process_name] VARCHAR (200)  NOT NULL,
    [Payment_Allowance]    NVARCHAR (MAX) NULL,
    [is_active]            TINYINT        CONSTRAINT [DF_T0301_Payment_Process_Type_is_active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_T0301_Payment_Process_Type] PRIMARY KEY CLUSTERED ([tran_id] ASC) WITH (FILLFACTOR = 80)
);

