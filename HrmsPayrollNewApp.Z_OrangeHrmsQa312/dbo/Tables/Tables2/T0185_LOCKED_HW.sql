CREATE TABLE [dbo].[T0185_LOCKED_HW] (
    [Tran_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [Lock_Id]      INT            NOT NULL,
    [Emp_ID]       INT            NOT NULL,
    [For_Date]     DATETIME       NOT NULL,
    [DayName]      VARCHAR (128)  NOT NULL,
    [HW_Day]       NUMERIC (5, 2) NOT NULL,
    [Is_P_Comp]    BIT            NULL,
    [Is_Half]      BIT            NULL,
    [Is_Cancel]    BIT            NOT NULL,
    [CancelReason] VARCHAR (128)  NULL,
    [Flag]         CHAR (1)       NOT NULL,
    CONSTRAINT [fk_LOCKED_HW] FOREIGN KEY ([Lock_Id]) REFERENCES [dbo].[T0180_LOCKED_ATTENDANCE] ([Lock_Id])
);

