




CREATE VIEW [dbo].[V0050_Piece_Trans]
AS

SELECT Piece_Tran_ID, E.Alpha_Emp_Code,E.Emp_Full_Name,p.Product_Name,SP.SubProduct_Name,PT.Cmp_ID,e.Emp_ID, p.Product_ID,SP.SubProduct_ID
,Pt.Piece_Trans_Count,pt.Piece_Trans_Date
FROM          T0050_Piece_Transaction PT WITH (NOLOCK)
			 Left Join T0080_EMP_MASTER E WITH (NOLOCK) on PT.Emp_ID = E.Emp_ID
			 Left Join T0040_Product_Master P WITH (NOLOCK) on PT.Product_ID = p.Product_ID
			 Left Join T0040_SubProduct_Master SP WITH (NOLOCK) on PT.SubProduct_ID = SP.SubProduct_ID and Sp.Product_ID = p.Product_ID



