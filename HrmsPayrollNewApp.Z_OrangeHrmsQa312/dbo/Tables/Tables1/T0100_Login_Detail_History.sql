CREATE TABLE [dbo].[T0100_Login_Detail_History] (
    [Tran_Id]     NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_id]      NUMERIC (18)  NOT NULL,
    [Emp_id]      NUMERIC (18)  NOT NULL,
    [Login_id]    NUMERIC (18)  NOT NULL,
    [User_name]   VARCHAR (500) NULL,
    [Password]    VARCHAR (MAX) NULL,
    [system_date] DATETIME      NOT NULL,
    [status]      TINYINT       NOT NULL,
    [Ip_address]  VARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_T0100_Login_Detail_History_statussystem_date]
    ON [dbo].[T0100_Login_Detail_History]([status] ASC, [system_date] ASC)
    INCLUDE([Tran_Id], [Emp_id], [Login_id]) WITH (FILLFACTOR = 90);

