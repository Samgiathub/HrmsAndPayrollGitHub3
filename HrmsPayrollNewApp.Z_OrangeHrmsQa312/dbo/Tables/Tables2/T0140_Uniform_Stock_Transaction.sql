CREATE TABLE [dbo].[T0140_Uniform_Stock_Transaction] (
    [Stock_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Uni_ID]        NUMERIC (18)    NOT NULL,
    [For_Date]      DATETIME        NOT NULL,
    [Stock_Opening] NUMERIC (18)    NOT NULL,
    [Stock_Credit]  NUMERIC (18)    NOT NULL,
    [Stock_Debit]   NUMERIC (18)    NOT NULL,
    [Stock_Balance] NUMERIC (18)    NOT NULL,
    [Stock_Posting] NUMERIC (18)    NOT NULL,
    [Modify_By]     VARCHAR (100)   NULL,
    [Modify_Date]   DATETIME        NULL,
    [Ip_Address]    VARCHAR (100)   NULL,
    [Fabric_Price]  NUMERIC (18, 2) NULL,
    CONSTRAINT [PK__T0140_Un__EFA64EB80A38775B] PRIMARY KEY NONCLUSTERED ([Stock_ID] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0140_Uniform_Stock_Transaction_Cmp_ID_Uni_ID_For_Date_Stock_ID]
    ON [dbo].[T0140_Uniform_Stock_Transaction]([Cmp_ID] ASC, [Uni_ID] ASC, [For_Date] DESC, [Stock_ID] DESC);

