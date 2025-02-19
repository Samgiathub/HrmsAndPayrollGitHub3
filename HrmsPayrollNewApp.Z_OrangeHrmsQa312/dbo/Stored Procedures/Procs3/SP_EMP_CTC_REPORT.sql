--=============================================================================================================  
--ALTER BY   : NILAY  
--ALTER DATE : 13-DEC-2009  
--DESCRIPTION : ALTER CTC WISE SALARY REPORTS  
--MODIFY BY   : NILAY  
--REVIEW BY   : NILAY  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
--=============================================================================================================  
CREATE PROCEDURE [dbo].[SP_EMP_CTC_REPORT]  
  @Cmp_ID  NUMERIC  
 ,@From_Date  DATETIME  
 ,@To_Date  DATETIME   
 ,@Branch_ID  NUMERIC   = 0  
 ,@Cat_ID  NUMERIC  = 0  
 ,@Grd_ID  NUMERIC = 0  
 ,@Type_ID  NUMERIC  = 0  
 ,@Dept_ID  NUMERIC  = 0  
 ,@Desig_ID  NUMERIC = 0  
 ,@Emp_ID  NUMERIC  = 0  
 ,@Constraint VARCHAR(MAX) = ''  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
  
 IF @Branch_ID = 0  
  SET @Branch_ID = NULL  
 IF @Cat_ID = 0  
  SET @Cat_ID = NULL  
 IF @Type_ID = 0  
  SET @Type_ID = NULL  
 IF @Dept_ID = 0  
  SET @Dept_ID = NULL  
 IF @Grd_ID = 0  
  SET @Grd_ID = NULL  
 IF @Emp_ID = 0  
  SET @Emp_ID = NULL  
 If @Desig_ID = 0  
  SET @Desig_ID = NULL  
  --added by chetan 20122017  
 CREATE TABLE #Emp_Cons  
 (  
  Emp_ID NUMERIC,  
  Increment_ID NUMERIC,  
  Branch_ID NUMERIC  
 )  
 EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint  
   
 --comment by chetan 20122017 for maximum effect increment not reflecting in back dated case  
 --DECLARE @Emp_Cons TABLE  
 --(  
 -- Emp_ID NUMERIC  
 --)  
   
 --IF @Constraint <> ''  
 -- BEGIN  
 --  INSERT INTO @Emp_Cons  
 --  SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#')   
 -- END  
 --ELSE  
 -- BEGIN  
     
     
 --  INSERT INTO @Emp_Cons  
  
 --  SELECT I.Emp_Id FROM T0095_Increment I INNER JOIN   
 --    (SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment  
 --    WHERE Increment_Effective_date <= @To_Date  
 --    AND Cmp_ID = @Cmp_ID And Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'   
 --    GROUP BY emp_ID  ) Qry ON  
 --    I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date  
 --  WHERE Cmp_ID = @Cmp_ID   
 --  AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))  
 --  AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)  
 --  AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)  
 --  AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))  
 --  AND ISNULL(Type_ID,0) = ISNULL(@Type_ID ,ISNULL(Type_ID,0))  
 --  AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
 --  AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID)   
 --  AND I.Emp_ID in   
 --   (SELECT Emp_Id FROM  
 --   (SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN) qry  
 --   WHERE cmp_ID = @Cmp_ID   AND    
 --   (( @From_Date  >= join_Date  AND  @From_Date <= left_date )   
 --   OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )  
 --   OR Left_date IS NULL  AND @To_Date >= Join_Date)  
 --   OR @To_Date >= left_date  AND  @From_Date <= left_date )   
     
 -- END  
    
  declare @FinYear as nvarchar(20)  
  if MONTH(GetDate()) > 3  
   set @FinYear = Convert(nvarchar,YEAR(Getdate())) + '-' + convert(nvarchar,(YEAR(Getdate()) + 1))  
  else  
   set @FinYear = Convert(nvarchar,(YEAR(Getdate()) - 1)) + '-' + convert(nvarchar,YEAR(Getdate()))  
   
  -- Changed By Ali 22112013 EmpName_Alias  
  --SELECT I_Q.* ,I_Q.Gross_Salary,Cmp_Name,Cmp_address,BM.Comp_Name,BM.Branch_Address,Emp_Code, E.Alpha_Emp_Code  
  --   ,E.Emp_First_Name,E.Mobile_No,E.Work_Email,CTM.Cat_Name    -- Added By Gadriwala 17022014  
  --   --,E.Emp_Full_Name   
  --   ,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name  
  --   ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,I_Q.Basic_Salary,I_Q.Increment_Effective_Date,I_Q.Pre_Gross_Salary,I_Q.Increment_Amount,I_Q.Increment_Type  
  --   , @FinYear  as financial_Year  --Added by Mitesh on 28/07/2011  
  --   ,E.Pan_No --Added by nilesh on 04022015  
  --   ,CMI.Curr_Name,CMI.Curr_Symbol   
  --   FROM T0080_EMP_MASTER E   
  --   INNER JOIN T0010_Company_Master CM on  
  --   Cm.Cmp_Id =E.Cmp_ID INNER JOIN t0095_increment I_Q on e.Emp_ID = I_Q.Emp_ID inner join   
  --    ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment    
  --    where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
  --    I_Q.Emp_ID = Qry.Emp_ID and I_Q.Increment_ID = Qry.Increment_ID  INNER JOIN   
  --   T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID    LEFT OUTER JOIN  
  --   T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID   LEFT OUTER JOIN  
  --   T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
  --   T0030_CATEGORY_MASTER CTM On I_Q.Cat_ID = CTM.Cat_ID LEFT OUTER JOIN -- Added By Gadriwala 17022014  
  --   T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id  INNER JOIN   
  --   T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID left join  
  --   T0040_CURRENCY_MASTER CMI on E.Curr_ID = CMI.Curr_ID   
  --WHERE E.Cmp_ID = @Cmp_Id   
  --  AND E.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)   
  --Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
  -- When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
  --  Else e.Alpha_Emp_Code  
  -- End  
    
  SELECT Q.* ,Q.Gross_Salary  
     ,Cmp_Name,Cmp_address,BM.Comp_Name,BM.Branch_Address,Emp_Code, E.Alpha_Emp_Code  
     ,E.Emp_First_Name,E.Mobile_No,E.Work_Email,CTM.Cat_Name    -- Added By Gadriwala 17022014  
     ,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) AS Emp_Full_Name  
     ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name
     ,SBM.SubBranch_Name,VM.Vertical_Name,SVM.SubVertical_Name
     ,Date_of_Join,Gender  
     ,Q.Basic_Salary,Q.Increment_Effective_Date,Q.Pre_Gross_Salary,Q.Increment_Amount,Q.Increment_Type  
     , @FinYear  AS financial_Year  --Added by Mitesh on 28/07/2011  
     ,E.Pan_No --Added by nilesh on 04022015  
     ,CMI.Curr_Name,CMI.Curr_Symbol --,I.Band_Id
	 ,B.BandName
	 --,I.Is_Pradhan_Mantri,i.Is_1time_PF_Member   
  FROM T0080_EMP_MASTER E WITH (NOLOCK)  
     INNER JOIN T0010_Company_Master CM WITH (NOLOCK) ON Cm.Cmp_Id =E.Cmp_ID   
     INNER JOIN t0095_increment I WITH (NOLOCK) ON E.Emp_ID = I.Emp_ID  
	       
     INNER JOIN (                ---Added By Jimit 28022018  
        SELECT  I_q.*  
        from T0095_INCREMENT I_Q WITH (NOLOCK) INNER JOIN  
        (  
           SELECT MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID   
           FROM T0095_Increment I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E ON I2.Emp_ID = E.Emp_ID   
             INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
                FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.Emp_ID   
                WHERE I3.Increment_effective_Date <= @TO_DATE AND I3.Cmp_ID = @Cmp_ID and I3.Increment_Type Not IN ('Transfer','Deputation')  
                GROUP BY I3.EMP_ID    
                ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID                                     
           GROUP BY I2.Emp_ID  
        ) I1 ON I1.Emp_ID = I_Q.Emp_ID and I_Q.Increment_ID = I1.Increment_ID    
       )Q On Q.Emp_ID = E.Emp_ID  
    
     INNER JOIN #Emp_Cons EC ON EC.Emp_ID = I.Emp_ID AND EC.Increment_ID = I.Increment_ID --AND EC.Branch_ID = I.Branch_ID    
     INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID      
     LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID     
     LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id   
     LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON I.Cat_ID = CTM.Cat_ID   
     LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id    
     INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID  
     LEFT OUTER JOIN  T0050_SubBranch SBM WITH (NOLOCK) ON I.SubBranch_ID = SBM.SubBranch_ID
	 LEFT OUTER JOIN  T0040_Vertical_Segment VM WITH (NOLOCK) ON I.Vertical_ID = VM.Vertical_ID 
	  LEFT OUTER JOIN  T0050_SubVertical SVM WITH (NOLOCK) ON I.SubVertical_ID = SVM.SubVertical_ID 
     LEFT OUTER JOIN T0040_CURRENCY_MASTER CMI WITH (NOLOCK) ON E.Curr_ID = CMI.Curr_ID   
	 Left Outer JOIN  tblBandMaster B WITH (NOLOCK) ON B.BandId = I.Band_Id  
  WHERE E.Cmp_ID = @Cmp_Id   
  ORDER BY CASE WHEN ISNUMERIC(E.Alpha_Emp_Code) = 1 THEN RIGHT(REPLICATE('0',21) + E.Alpha_Emp_Code, 20)   
       WHEN ISNUMERIC(E.Alpha_Emp_Code) = 0 THEN RIGHT(REPLICATE(' ',21) + E.Alpha_Emp_Code , 20)  
       ELSE E.Alpha_Emp_Code  
   END  
    
RETURN  
