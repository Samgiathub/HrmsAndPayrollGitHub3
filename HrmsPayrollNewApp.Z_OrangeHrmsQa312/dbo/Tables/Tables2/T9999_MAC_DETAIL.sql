CREATE TABLE [dbo].[T9999_MAC_DETAIL] (
    [Tran_id]       INT           IDENTITY (1, 1) NOT NULL,
    [Mac_master_id] INT           NOT NULL,
    [Cmp_id]        INT           NOT NULL,
    [Mac_Address]   NVARCHAR (50) NOT NULL,
    [Emp_id]        INT           CONSTRAINT [DF_T9999_MAC_DETAIL_Emp_id] DEFAULT ((0)) NOT NULL,
    [Is_Active]     TINYINT       CONSTRAINT [DF_T9999_MAC_DETAIL_Is_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME      NULL,
    [Last_modified] DATETIME      NULL,
    [Modified_by]   INT           NULL,
    [PC_Name]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_T9999_MAC_DETAIL] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Login id of user modified data', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'T9999_MAC_DETAIL', @level2type = N'COLUMN', @level2name = N'Modified_by';

