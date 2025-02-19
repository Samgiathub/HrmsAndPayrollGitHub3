CREATE TABLE [dbo].[T0000_Form_Detail] (
    [Form_id]           NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Form_Url]          VARCHAR (100) NULL,
    [Is_Admin_Ess_Hrms] NUMERIC (2)   NOT NULL,
    [is_Active]         TINYINT       NOT NULL,
    CONSTRAINT [PK_T0000_Form_Detail] PRIMARY KEY CLUSTERED ([Form_id] ASC) WITH (FILLFACTOR = 80)
);

