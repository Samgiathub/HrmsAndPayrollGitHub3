CREATE TABLE [dbo].[T0200_Training_Bond_Recover] (
    [Tran_ID]         NUMERIC (18)    NULL,
    [EMP_ID]          NUMERIC (18)    CONSTRAINT [DF_T0200_Training_Bond_Recover_Sal_Tran_ID] DEFAULT ((0)) NOT NULL,
    [Training_Apr_ID] NUMERIC (18)    CONSTRAINT [DF_T0200_Training_Bond_Recover_Training_Apr_ID] DEFAULT ((0)) NOT NULL,
    [Recover_Amount]  NUMERIC (18, 2) CONSTRAINT [DF_T0200_Training_Bond_Recover_Recover_Amount] DEFAULT ((0)) NOT NULL
);

