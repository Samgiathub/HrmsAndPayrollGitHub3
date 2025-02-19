CREATE TABLE [dbo].[T0040_AD_Formula_Eligible_Setting] (
    [Tran_Id]                    NUMERIC (18)   NOT NULL,
    [Cmp_Id]                     NUMERIC (18)   NOT NULL,
    [AD_Id]                      NUMERIC (18)   NOT NULL,
    [AD_Formula_Eligible]        NVARCHAR (MAX) NOT NULL,
    [Actual_AD_Formula_Eligible] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_AD_Formula_Eligible_Setting] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

