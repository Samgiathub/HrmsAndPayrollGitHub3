CREATE TABLE [dbo].[T0041_Claim_Maxlimit_GradeDesig_CityWise] (
    [Tran_ID]        NUMERIC (18) NOT NULL,
    [Claim_ID]       NUMERIC (18) NOT NULL,
    [Desig_ID]       NUMERIC (18) NULL,
    [Grd_ID]         NUMERIC (18) NULL,
    [City_cat_limit] NUMERIC (18) NOT NULL,
    [city_cat_id]    NUMERIC (10) NOT NULL,
    [Effective_Date] DATETIME     NULL,
    [Flag_Grd_Desig] TINYINT      NULL,
    [City_Cat_Flag]  TINYINT      NULL,
    [Cmp_ID]         NUMERIC (18) NOT NULL,
    [HQ_Flag]        TINYINT      DEFAULT ('0') NULL,
    CONSTRAINT [PK_T0041_Claim_Maxlimit_GradeDesig_CityWise] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0041_Claim_Maxlimit_GradeDesig_CityWise_T0040_CLAIM_MASTER] FOREIGN KEY ([Claim_ID]) REFERENCES [dbo].[T0040_CLAIM_MASTER] ([Claim_ID]),
    CONSTRAINT [FK_T0041_Claim_Maxlimit_GradeDesig_CityWise_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_ID]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0041_Claim_Maxlimit_GradeDesig_CityWise_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID])
);

