CREATE TABLE [dbo].[T0050_PRIVILEGE_DETAILS] (
    [Trans_Id]     NUMERIC (18) NOT NULL,
    [Privilage_ID] NUMERIC (18) NOT NULL,
    [Cmp_Id]       NUMERIC (18) NOT NULL,
    [Form_Id]      NUMERIC (18) NOT NULL,
    [Is_View]      TINYINT      CONSTRAINT [DF_T0020_PRIVILEGE_DETAILS_Is_View] DEFAULT ((0)) NOT NULL,
    [Is_Edit]      TINYINT      CONSTRAINT [DF_T0020_PRIVILEGE_DETAILS_Is_Edit] DEFAULT ((0)) NOT NULL,
    [Is_Save]      TINYINT      CONSTRAINT [DF_T0020_PRIVILEGE_DETAILS_Is_Save] DEFAULT ((0)) NOT NULL,
    [Is_Delete]    TINYINT      CONSTRAINT [DF_T0020_PRIVILEGE_DETAILS_Is_Delete] DEFAULT ((0)) NOT NULL,
    [Is_Print]     TINYINT      CONSTRAINT [DF_T0020_PRIVILEGE_DETAILS_Is_Print] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0020_PRIVILEGE_DETAILS] PRIMARY KEY CLUSTERED ([Trans_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_PRIVILEGE_DETAILS_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_PRIVILEGE_DETAILS_T0020_PRIVILEGE_MASTER] FOREIGN KEY ([Privilage_ID]) REFERENCES [dbo].[T0020_PRIVILEGE_MASTER] ([Privilege_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_PRIVILEGE_DETAILS_11_1335011837__K2_K3_K4_1_5_6_7_8_9]
    ON [dbo].[T0050_PRIVILEGE_DETAILS]([Privilage_ID] ASC, [Cmp_Id] ASC, [Form_Id] ASC)
    INCLUDE([Trans_Id], [Is_View], [Is_Edit], [Is_Save], [Is_Delete], [Is_Print]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_PRIVILEGE_DETAILS_11_1335011837__K4_1_2_3_5_6_7_8_9]
    ON [dbo].[T0050_PRIVILEGE_DETAILS]([Form_Id] ASC)
    INCLUDE([Trans_Id], [Privilage_ID], [Cmp_Id], [Is_View], [Is_Edit], [Is_Save], [Is_Delete], [Is_Print]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_PRIVILEGE_DETAILS_10_1335011837__K2_K4_K8_K6_K7_K5]
    ON [dbo].[T0050_PRIVILEGE_DETAILS]([Privilage_ID] ASC, [Form_Id] ASC, [Is_Delete] ASC, [Is_Edit] ASC, [Is_Save] ASC, [Is_View] ASC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_1335011837_4_3]
    ON [dbo].[T0050_PRIVILEGE_DETAILS]([Form_Id], [Cmp_Id]);


GO
CREATE STATISTICS [_dta_stat_1335011837_4_2]
    ON [dbo].[T0050_PRIVILEGE_DETAILS]([Form_Id], [Privilage_ID]);


GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER Tri_T0050_PRIVILEGE_DETAILS 
   ON  dbo.T0050_PRIVILEGE_DETAILS
   AFTER DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Privilage_ID Numeric(18,0)
    IF update(Privilage_ID) 
		Begin
			Select @Privilage_ID = Privilage_ID From inserted
			if @Privilage_ID <> 0
				Begin
					DELETE FROM T9999_CACHE_GET_EMP_PRIVILEGE WHERE Privilage_ID=@Privilage_ID 
				End
		End
	Else
		Begin
			Select @Privilage_ID = Privilage_ID From deleted
			if @Privilage_ID <> 0
				Begin
					DELETE FROM T9999_CACHE_GET_EMP_PRIVILEGE WHERE Privilage_ID=@Privilage_ID 
				End
		End
			

END

