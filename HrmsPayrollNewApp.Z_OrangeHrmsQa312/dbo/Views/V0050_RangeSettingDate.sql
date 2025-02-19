




CREATE VIEW [dbo].[V0050_RangeSettingDate]
AS
SELECT DISTINCT isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = T0040_HRMS_RangeMaster.Cmp_ID)) Effective_Date, cmp_id
FROM         T0040_HRMS_RangeMaster WITH (NOLOCK)
UNION
SELECT DISTINCT isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = t0040_Achievement_Master.Cmp_ID)) Effective_Date, cmp_id
FROM         t0040_Achievement_Master WITH (NOLOCK)
UNION
SELECT DISTINCT isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = t0050_HRMS_RangeDept_Allocation.Cmp_ID)) Effective_Date, cmp_id
FROM         t0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
UNION
SELECT DISTINCT isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = t0050_AppraisalLimit_Setting.Cmp_ID)) Effective_Date, cmp_id
FROM         t0050_AppraisalLimit_Setting WITH (NOLOCK)
UNION
SELECT DISTINCT isnull(EffectiveDate,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = T0050_Appraisal_Utility_Setting.Cmp_ID)) Effective_Date, cmp_id
FROM         T0050_Appraisal_Utility_Setting WITH (NOLOCK)


