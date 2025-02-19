CREATE TABLE [dbo].[T0100_Leave_Upload] (
    [tran_id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_id]            NUMERIC (18)    NOT NULL,
    [Emp_id]            NUMERIC (18)    NOT NULL,
    [leave_id]          NUMERIC (18)    NOT NULL,
    [month]             NUMERIC (18)    NOT NULL,
    [Year]              NUMERIC (18)    NOT NULL,
    [Opening]           NUMERIC (18, 2) CONSTRAINT [DF_T0100_Leave_Upload_Opening] DEFAULT ((0)) NOT NULL,
    [Credit]            NUMERIC (18, 2) CONSTRAINT [DF_T0100_Leave_Upload_Credit] DEFAULT ((0)) NOT NULL,
    [Debit]             NUMERIC (18, 2) NOT NULL,
    [Late_Adjust_leave] NUMERIC (18, 2) CONSTRAINT [DF_T0100_Leave_Upload_Late_Adjust_leave] DEFAULT ((0)) NOT NULL,
    [Balance]           NUMERIC (18, 2) NOT NULL,
    [user_id]           NUMERIC (18)    NOT NULL,
    [Ip_Address]        NVARCHAR (100)  NOT NULL,
    [Modify_Date]       DATETIME        NOT NULL
);

