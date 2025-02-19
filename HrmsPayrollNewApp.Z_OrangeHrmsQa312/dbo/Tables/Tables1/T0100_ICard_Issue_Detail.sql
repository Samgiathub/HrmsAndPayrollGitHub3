CREATE TABLE [dbo].[T0100_ICard_Issue_Detail] (
    [Tran_ID]        NUMERIC (18)  NOT NULL,
    [Emp_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Increment_ID]   NUMERIC (18)  NOT NULL,
    [Effective_Date] DATETIME      NOT NULL,
    [Reason]         VARCHAR (512) NULL,
    [Is_Recovered]   BIT           NOT NULL,
    [Issue_By]       NUMERIC (18)  NOT NULL,
    [Issue_Date]     DATETIME      NOT NULL,
    [Return_Date]    DATETIME      NULL,
    [Expiry_Date]    DATETIME      NULL,
    CONSTRAINT [PK_T0100_ICard_Issue_Detail] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

