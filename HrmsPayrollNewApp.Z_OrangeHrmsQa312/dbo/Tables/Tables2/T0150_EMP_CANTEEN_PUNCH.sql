CREATE TABLE [dbo].[T0150_EMP_CANTEEN_PUNCH] (
    [Tran_Id]                NUMERIC (18)   NOT NULL,
    [Cmp_ID]                 NUMERIC (18)   NOT NULL,
    [Emp_ID]                 NUMERIC (18)   NOT NULL,
    [Canteen_Punch_Datetime] DATETIME       NOT NULL,
    [Flag]                   VARCHAR (50)   NULL,
    [Device_IP]              VARCHAR (50)   NOT NULL,
    [Reason]                 VARCHAR (500)  NULL,
    [User_ID]                NUMERIC (18)   NOT NULL,
    [System_Date]            DATETIME       NOT NULL,
    [Canteen_ID]             NUMERIC (18)   NULL,
    [Card_No]                VARCHAR (50)   NULL,
    [Quantity]               NUMERIC (4, 2) NULL,
    [Canteen_TransactionID]  NUMERIC (18)   CONSTRAINT [DF__T0150_EMP__Cante__2BD1D476] DEFAULT ((0)) NULL,
    [TransFinishDate]        DATETIME       CONSTRAINT [DF__T0150_EMP__Trans__4F7BCEBD] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0150_EMP_CANTEEN_PUNCH] PRIMARY KEY CLUSTERED ([Tran_Id] ASC),
    CONSTRAINT [FK_T0150_EMP_CANTEEN_PUNCH_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0150_EMP_CANTEEN_PUNCH_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

