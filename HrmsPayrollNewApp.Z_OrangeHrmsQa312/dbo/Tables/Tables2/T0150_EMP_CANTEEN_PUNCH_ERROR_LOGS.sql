CREATE TABLE [dbo].[T0150_EMP_CANTEEN_PUNCH_ERROR_LOGS] (
    [Error_LogID]            NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]                 NUMERIC (18)   NOT NULL,
    [Emp_ID]                 NUMERIC (18)   NOT NULL,
    [Canteen_Punch_Datetime] DATETIME       NOT NULL,
    [Flag]                   VARCHAR (10)   NOT NULL,
    [Device_IP]              VARCHAR (20)   NOT NULL,
    [User_ID]                NUMERIC (18)   NOT NULL,
    [System_Date]            DATETIME       NOT NULL,
    [Canteen_ID]             NUMERIC (18)   NULL,
    [Card_No]                VARCHAR (50)   NULL,
    [Quantity]               NUMERIC (4, 2) NULL,
    [Canteen_TransactionID]  NUMERIC (18)   DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0150_EMP_CANTEEN_PUNCH_SYNC_LOGS] PRIMARY KEY CLUSTERED ([Error_LogID] ASC) WITH (FILLFACTOR = 95)
);

