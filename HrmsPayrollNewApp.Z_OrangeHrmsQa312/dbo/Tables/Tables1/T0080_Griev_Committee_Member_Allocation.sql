CREATE TABLE [dbo].[T0080_Griev_Committee_Member_Allocation] (
    [GCMID]      INT NOT NULL,
    [GCMEmpID]   INT NULL,
    [Cmp_ID]     INT NULL,
    [MemberType] INT NULL,
    [Is_Active]  INT DEFAULT ((1)) NULL,
    CONSTRAINT [PK_T0080_Griev_CMA] PRIMARY KEY CLUSTERED ([GCMID] ASC) WITH (FILLFACTOR = 80)
);

