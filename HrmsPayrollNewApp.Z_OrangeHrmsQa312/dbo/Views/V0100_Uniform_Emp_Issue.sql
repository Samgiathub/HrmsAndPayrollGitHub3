



CREATE VIEW [dbo].[V0100_Uniform_Emp_Issue]
AS
SELECT     UEI.Uni_Apr_Id, UEI.Uni_Id, UM.Uni_Name, EM.Alpha_Emp_Code, EM.Emp_Full_Name, UEI.Issue_Date, UEI.Uni_Pieces AS Uni_Piece, UEI.Uni_Rate, 
                      UEI.Uni_Amount, UEI.Uni_deduct_Installment AS Uni_Ded_Install, UEI.Uni_Refund_Installment AS Uni_Ref_Install, UEI.Emp_ID, UEI.Cmp_ID, 
                      I.Branch_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID, EM.Emp_First_Name, 
                      UEI.Uni_deduct_Amount, UEI.Deduct_Pending_Amount, UEI.Refund_Pending_Amount, UEI.Uni_Refund_Amount
FROM         dbo.T0100_Uniform_Emp_Issue UEI WITH (NOLOCK)
	INNER JOIN dbo.T0040_Uniform_Master UM WITH (NOLOCK) ON UEI.Uni_Id = UM.Uni_ID 
	INNER JOIN dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = UEI.Emp_ID 
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON	I.Emp_ID = EM.Emp_ID 
	INNER JOIN 
			( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
				FROM T0095_INCREMENT I WITH (NOLOCK)
				INNER JOIN 
				(
						SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
						FROM T0095_INCREMENT I3 WITH (NOLOCK)
						WHERE I3.Increment_effective_Date <= GETDATE()
						GROUP BY I3.EMP_ID  
					) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
			   where I.INCREMENT_EFFECTIVE_DATE <= GETDATE()
			   group by I.emp_ID  
			) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 



