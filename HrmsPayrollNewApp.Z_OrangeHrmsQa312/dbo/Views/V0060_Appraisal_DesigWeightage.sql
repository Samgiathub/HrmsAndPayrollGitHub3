





----------------------------
CREATE VIEW [dbo].[V0060_Appraisal_DesigWeightage]
AS
SELECT DISTINCT 
                      dbo.T0060_Appraisal_DesigWeightage.Desig_weightage_Id, ISNULL(dbo.T0060_Appraisal_DesigWeightage.EKPA_Weightage, 0) AS EKPA_Weightage, 
                      ISNULL(dbo.T0060_Appraisal_DesigWeightage.SA_Weightage, 0) AS SA_Weightage, dbo.T0040_DESIGNATION_MASTER.Cmp_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID,
                      dbo.T0060_Appraisal_DesigWeightage.Effective_Date,
                      dbo.T0060_Appraisal_DesigWeightage.EKPA_Weightage AS Expr1, 
                      dbo.T0060_Appraisal_DesigWeightage.SA_Weightage AS Expr2, ISNULL(dbo.T0060_Appraisal_DesigWeightage.PA_Weightage, 0) AS PA_Weightage, 
                      dbo.T0060_Appraisal_DesigWeightage.Effective_Date AS Expr3, ISNULL(dbo.T0060_Appraisal_DesigWeightage.PoA_Weightage, 0) AS PoA_Weightage, 
                      ISNULL(dbo.T0060_Appraisal_DesigWeightage.EKPA_RestrictWeightage, 0) AS EKPA_RestrictWeightage, 
                      ISNULL(dbo.T0060_Appraisal_DesigWeightage.SA_RestrictWeightage, 0) AS SA_RestrictWeightage
FROM         dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0060_Appraisal_DesigWeightage WITH (NOLOCK)  ON dbo.T0060_Appraisal_DesigWeightage.Desig_ID = dbo.T0040_DESIGNATION_MASTER.Desig_ID




