CREATE TABLE [dbo].[T0211_Salary_Processing_Status] (
    [Tran_ID]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [SPID]       INT           NULL,
    [GUID_Part]  VARCHAR (128) NULL,
    [TotalCount] INT           NULL,
    [Processed]  INT           NULL,
    CONSTRAINT [PK_T0211_Salary_Processing_Status] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

