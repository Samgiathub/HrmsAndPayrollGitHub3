CREATE TABLE [dbo].[T0100_EMP_RETAINTION_STATUS] (
    [Tran_Id]           NUMERIC (18) NOT NULL,
    [Cmp_Id]            NUMERIC (18) NOT NULL,
    [Emp_Id]            NUMERIC (18) NOT NULL,
    [For_Date]          DATETIME     NOT NULL,
    [Start_Date]        DATETIME     NOT NULL,
    [End_Date]          DATETIME     NULL,
    [Is_Retain_ON]      TINYINT      CONSTRAINT [DF_T0100_EMP_RETAINTION_STATUS_Is_Retain_ON] DEFAULT ((0)) NOT NULL,
    [User_ID]           NUMERIC (18) NULL,
    [System_Date_Start] DATETIME     NULL,
    [System_Date_End]   DATETIME     NULL,
    [Tot_Retain_Days]   INT          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0100_EMP_RETAINTION_STATUS] PRIMARY KEY NONCLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

