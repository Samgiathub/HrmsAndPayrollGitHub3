CREATE TABLE [dbo].[T0185_LOCKED_LEAVE] (
    [Tran_ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Lock_Id]           INT            NOT NULL,
    [Emp_ID]            INT            NOT NULL,
    [For_Date]          DATETIME       NOT NULL,
    [Leave_ID]          INT            NOT NULL,
    [Leave_Type]        VARCHAR (36)   NOT NULL,
    [From_Time]         DATETIME       NULL,
    [To_Time]           DATETIME       NULL,
    [Leave_Days]        NUMERIC (9, 3) NOT NULL,
    [IsPaid]            BIT            NOT NULL,
    [IsCompOff]         BIT            NOT NULL,
    [IsOD]              BIT            NOT NULL,
    [Leave_Approval_ID] INT            NOT NULL,
    CONSTRAINT [fk_LOCKED_LEAVE] FOREIGN KEY ([Lock_Id]) REFERENCES [dbo].[T0180_LOCKED_ATTENDANCE] ([Lock_Id])
);

