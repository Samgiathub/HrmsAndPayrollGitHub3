




CREATE VIEW [dbo].[V0040_WARNING_MASTER]
AS
SELECT     W.War_ID, W.Cmp_ID, W.War_Name, W.War_Comments, W.Deduct_Rate, W.Deduct_Type, W.Level_Id, C.Level_Name,
			C.No_Of_Card,C.Card_Color
FROM         dbo.T0040_WARNING_MASTER AS W WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_Warning_CardMapping AS C WITH (NOLOCK)  ON W.Level_Id = C.Level_Id AND W.Cmp_ID = C.Cmp_Id



