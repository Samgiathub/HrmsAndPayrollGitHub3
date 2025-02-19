



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE    PROCEDURE [dbo].[Pro_rpt_get_Emp_Shift] 
	@Cmp_ID as numeric , 
	@From_Date as datetime , 
	@To_Date as datetime ,
	@Grd_ID as numeric ,
	@Type_ID as numeric ,
	@Dept_ID as numeric,
	@Emp_ID as numeric ,
	@shift_ID as numeric ,
	@Branch_ID as numeric,
	@Cat_ID as numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Emp_shift table 
		(
			 emp_ID numeric ,
			 Grd_ID  numeric ,
			 Type_ID numeric ,
			 Dept_ID  numeric,
			 Desig_ID  numeric,
			 Shift_ID numeric ,
			 Day1   varchar(2), 
			 Day2   varchar(2),
			 Day3   varchar(2),
			 Day4   varchar(2) ,
			 Day5   varchar(2) ,
			 Day6   varchar(2) ,
			 Day7   varchar(2) ,
			 Day8   varchar(2) ,
			 Day9   varchar(2) ,
			 Day10  varchar(2) ,
			 Day11  varchar(2) ,
			 Day12  varchar(2) ,
			 Day13  varchar(2) ,
			 Day14  varchar(2) ,
			 Day15  varchar(2) ,
			 Day16  varchar(2) ,
			 Day17  varchar(2) ,
			 Day18  varchar(2) ,
			 Day19  varchar(2) ,
			 Day20  varchar(2) ,
			 Day21  varchar(2) ,
			 Day22  varchar(2) ,
			 Day23  varchar(2) ,
			 Day24  varchar(2) ,
			 Day25  varchar(2) ,
			 Day26  varchar(2) ,
			 Day27  varchar(2) ,
			 Day28  varchar(2) ,
			 Day29  varchar(2) ,
			 Day30  varchar(2) ,
			 Day31  varchar(2) 
			)

	declare @Total_Days as numeric 
	declare @Temp_for_Date as datetime
	
	Declare @Desig_ID as numeric 
	
	declare @ctr as numeric 
	set @Total_Days = datediff(d,@from_Date,@to_Date) + 1
	set @Temp_for_Date  = @From_Date
	
	Declare @Day1 as varchar(1) 
	Declare @Day2 as varchar(2) 
	Declare @Day3 as varchar(2) 
	Declare @Day4 as varchar(2) 
	Declare @Day5 as varchar(2) 
	Declare @Day6 as varchar(2) 
	Declare @Day7 as varchar(2) 
	Declare @Day8 as varchar(2) 
	Declare @Day9 as varchar(2) 
	Declare @Day10 as varchar(2) 
	Declare @Day11 as varchar(2) 
	Declare @Day12 as varchar(2) 
	Declare @Day13 as varchar(2) 
	Declare @Day14 as varchar(2) 
	Declare @Day15 as varchar(2) 
	Declare @Day16 as varchar(2) 
	Declare @Day17 as varchar(2) 
	Declare @Day18 as varchar(2) 
	Declare @Day19 as varchar(2) 
	Declare @Day20 as varchar(2) 
	Declare @Day21 as varchar(2) 
	Declare @Day22 as varchar(2) 
	Declare @Day23 as varchar(2) 
	Declare @Day24 as varchar(2) 
	Declare @Day25 as varchar(2) 
	Declare @Day26 as varchar(2) 
	Declare @Day27 as varchar(2) 
	Declare @Day28 as varchar(2) 
	Declare @Day29 as varchar(2) 
	Declare @Day30 as varchar(2) 
	Declare @Day31 as varchar(2) 
	declare @Shift_Symbol as varchar(2)
	
	If @Dept_ID = 0
		set @Dept_ID = null
		
	IF @Type_ID = 0
		set @Type_ID = null

	IF @grd_id = 0
		set @grd_id = null
	 
	IF @Emp_ID = 0
		set  @Emp_ID  = null
	
	If @branch_id = 0
		set @branch_id = null		
	
	If @Cat_ID = 0
		set @Cat_ID = null 	
	 			
	set @Desig_ID = null
	
		declare Cur_Emp  cursor for
		 SELECT     Inc_Qry.EMP_ID ,Inc_Qry.GRD_ID,Inc_Qry.TYPE_ID,Inc_Qry.DEPT_ID ,Inc_Qry.DESIG_ID
		FROM    T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
		( SELECT DISTINCT  T0095_INCREMENT.EMP_ID ,GRD_ID,TYPE_ID,DEPT_ID ,DESIG_ID FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
		(select  MAX(Increment_Id)AS Increment_Id , EMP_ID from T0095_increment  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
		where Cmp_ID = @Cmp_ID
		and Increment_Effective_Date <= @To_Date
		GROUP BY EMP_id)  QRY ON T0095_INCREMENT.Increment_Id = QRY.Increment_Id 
				AND T0095_INCREMENT.EMP_ID = QRY.EMP_ID ) INC_QRY
		ON T0080_EMP_MASTER.EMP_ID = INC_QRY.EMP_ID  
		WHERE   (T0080_EMP_MASTER.Cmp_Id = @Cmp_Id   and Date_Of_Join <= @To_Date and 
				T0080_EMP_MASTER.emp_id in(
				select emp_Id from
				(select emp_id, cmp_id, Date_Of_Join, isnull(Emp_Left_Date, @To_Date) as Emp_left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_id = @cmp_id   and  
				(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_Left_Date ) 
				or ( @to_Date  >= Date_Of_Join  and @to_Date <= Emp_Left_Date )
				or Emp_Left_Date is null and @To_Date >= Date_Of_Join)
				) )
		and T0080_EMP_MASTER.Emp_ID = Isnull(@Emp_ID,T0080_EMP_MASTER.Emp_ID) 
		and cat_ID = Isnull(@Cat_ID ,Cat_ID) 
		and Branch_ID = Isnull(@Branch_ID,Branch_ID)
		and Inc_Qry.Grd_ID = Isnull(@Grd_ID,Inc_Qry.Grd_ID)
		and Isnull(Inc_Qry.Dept_ID,0) = Isnull(@Dept_ID,Isnull(Inc_Qry.Dept_ID,0))
		and Inc_Qry.Type_ID = Isnull(@Type_ID,Inc_Qry.Type_ID)
	open cur_emp
	fetch next from Cur_emp into @Emp_ID,@grd_id,@Type_ID ,@Dept_ID, @Branch_ID
	while @@Fetch_Status = 0	
		begin
				set @temp_For_DAte = @From_Date
				
						set @Day1  = '' 
						set @Day2  = ''
						set @Day3  = ''
						set @Day4  = '' 
						set @Day5  = '' 
						set @Day6  = '' 
						set @Day7  = '' 
						set @Day8  = ''
						set @Day9  = '' 
						set @Day10  = '' 
						set @Day11  = '' 
						set @Day12  = '' 
						set @Day13  = '' 
						set @Day14  = '' 
						set @Day15  = ''
						set @Day16  = ''
						set @Day17  = '' 
						set @Day18  = '' 
						set @Day19  = '' 
						set @Day20  = '' 
						set @Day21  = ''
						set @Day22  = '' 
						set @Day23  = '' 
						set @Day24  = '' 
						set @Day25  = ''
						set @Day26  = '' 
						set @Day27  = '' 
						set @Day28  = '' 
						set @Day29  = '' 
						set @Day30  = '' 
						set @Day31  = '' 
						set @Shift_ID = null
						set @Shift_Symbol = null

				
				while @temp_For_DAte <= @To_date
					begin
						
						
						set @Shift_ID = null
						set @Shift_Symbol  = null
				
						 if @Temp_for_Date = @From_Date 
							begin
								select @Shift_ID = Shift_ID from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
								 inner join (
									select Max(For_Date ) as for_Date , Emp_ID from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
										where Emp_ID = @emp_ID and For_Date <=@Temp_for_Date
								group by Emp_ID )  Qry on T0100_EMP_SHIFT_DETAIL.For_Date = Qry.For_Date 
								and T0100_EMP_SHIFT_DETAIL.Emp_ID = Qry.emp_Id  
								where T0100_EMP_SHIFT_DETAIL.Emp_ID = @emp_ID 
							end
						else
							begin
								select @Shift_ID = Shift_ID from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
								where For_Date = @Temp_For_Date and	  Emp_ID = @emp_ID 
							end				
			 			
			 			
			 			if not exists(	select emp_Id from
								(select emp_id, Cmp_ID, Join_Date, isnull(Left_Date, @Temp_for_Date) as Emp_Left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
								where Cmp_ID = @Cmp_ID   and Emp_ID =@Emp_ID and   
									(( @Temp_for_Date  >= Join_Date  and  @Temp_for_Date <= Emp_Left_Date) 
							or ( @Temp_for_Date >= Join_Date  and @Temp_for_Date <= Emp_Left_Date)
							or Emp_Left_Date is null and @Temp_for_Date >= Join_Date)
							) 
							begin
								set @Shift_ID = null
							end
			 			
			 			
			 			-- select @Shift_Symbol = left(Shift_Name,1) from Shift_MAster where Shift_ID = @Shift_ID and Cmp_ID = @Cmp_ID
			 			set @Shift_Symbol = @Shift_ID
			 			
			 			
			 			
						if day(@temp_For_Date  ) = 1  and isnull(@Shift_ID,0)  > 0  
							set @Day1  = @Shift_Symbol
						else if day(@temp_For_Date  ) = 2  and isnull(@Shift_ID,0)  > 0  
							set @Day2  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 3 and isnull(@Shift_ID,0)  > 0  
							set @Day3  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 4 and isnull(@Shift_ID,0)  > 0  
							set @Day4  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 5 and isnull(@Shift_ID,0)  > 0  
							set @Day5  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 6 and isnull(@Shift_ID,0)  > 0  
							set @Day6  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 7 and isnull(@Shift_ID,0)  > 0  
							set @Day7  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 8 and isnull(@Shift_ID,0)  > 0  
							set @Day8  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 9 and isnull(@Shift_ID,0)  > 0  
							set @Day9  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 10 and isnull(@Shift_ID,0)  > 0  
							set @Day10  = @Shift_Symbol
						else if day(@temp_For_Date  ) = 11 and isnull(@Shift_ID,0)  > 0  
							set @Day11  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 12 and isnull(@Shift_ID,0)  > 0  
							set @Day12  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 13 and isnull(@Shift_ID,0)  > 0  
							set @Day13  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 14 and isnull(@Shift_ID,0)  > 0  
							set @Day14  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 15 and isnull(@Shift_ID,0)  > 0  
							set @Day15  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 16 and isnull(@Shift_ID,0)  > 0  
							set @Day16  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 17 and isnull(@Shift_ID,0)  > 0  
							set @Day17  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 18 and isnull(@Shift_ID,0)  > 0  
							set @Day18  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 19 and isnull(@Shift_ID,0)  > 0  
							set @Day19  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 20 and isnull(@Shift_ID,0)  > 0  
							set @Day20  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 21 and isnull(@Shift_ID,0)  > 0  
							set @Day21  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 22 and isnull(@Shift_ID,0)  > 0   
							set @Day22  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 23 and isnull(@Shift_ID,0)  > 0   
							set @Day23  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 24 and isnull(@Shift_ID,0)  > 0  
							set @Day24  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 25 and isnull(@Shift_ID,0)  > 0   
							set @Day25  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 26 and isnull(@Shift_ID,0)  > 0   
							set @Day26  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 27 and isnull(@Shift_ID,0)  > 0  
							set @Day27  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 28 and isnull(@Shift_ID,0)  > 0  
							set @Day28  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 29 and isnull(@Shift_ID,0)  > 0  
							set @Day29  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 30 and isnull(@Shift_ID,0)  > 0  
							set @Day30  = @Shift_Symbol 
						else if day(@temp_For_Date  ) = 31 and isnull(@Shift_ID,0)  > 0  
							set @Day31  = @Shift_Symbol 
							
						
						if exists(select Max(For_Date )  from 
								T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) where Emp_ID = @emp_ID and For_Date > @Temp_for_Date )
								begin
									select @Temp_for_Date = min(For_Date )  from 
									T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) where Emp_ID = @emp_ID and For_Date > @Temp_for_Date
								end
						else		
							set @Temp_for_Date = @To_Date 
					end

						insert into @Emp_shift(emp_ID ,Grd_ID,type_Id,Dept_ID,Desig_ID ,  Shift_ID  ,  Day1   ,  Day2    ,
									Day3     , Day4     , Day5     , Day6    , Day7    , Day8     , Day9     , Day10    ,
									Day11    ,Day12    ,Day13    ,Day14    ,Day15    ,Day16    ,Day17    ,Day18    ,Day19    ,
									Day20    ,Day21    ,Day22    ,Day23    ,Day24    ,Day25    ,Day26    ,Day27    ,Day28    ,
									Day29    ,Day30    ,Day31    	
						)
						values(@emp_ID ,@grd_id,@Type_ID,@Dept_ID,@Desig_ID, @shift_ID		, @Day1   ,  @Day2    ,
									@Day3    , @Day4    , @Day5     , @Day6    , @Day7    , @Day8     , @Day9     , @Day10    ,
									@Day11    ,@Day12    ,@Day13    ,@Day14    ,@Day15    ,@Day16    ,@Day17    ,@Day18    ,@Day19    ,
									@Day20    ,@Day21    ,@Day22    ,@Day23    ,@Day24    ,@Day25    ,@Day26    ,@Day27    ,@Day28    ,
									@Day29    ,@Day30    ,@Day31)
					
					
					
			fetch next from Cur_emp into @Emp_ID , @grd_id,@Type_ID ,@Dept_ID, @branch_id	 
		end
close cur_emp
deallocate cur_emp			 	

	
	
	select ES.* , grd_name ,T0080_EMP_MASTER.Emp_Full_Name ,Shift_Name  ,T0080_EMP_MASTER.Cat_ID 
		,Type_Name,Dept_Name,Desig_Name,Emp_Code
		from @Emp_shift ES  inner join 
		T0080_EMP_MASTER WITH (NOLOCK) on T0080_EMP_MASTER.Emp_Id = ES.Emp_ID  inner join
		T0040_Grade_Master WITH (NOLOCK) on T0040_Grade_Master.Grd_ID = Es.Grd_ID inner join
		T0040_Shift_master WITH (NOLOCK) on T0040_Shift_master.Shift_Id = Es.shift_ID Inner join
		T0040_Type_Master ET WITH (NOLOCK) on ES.type_ID = ET.Type_ID left outer join
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on ES.Dept_ID = Dm.Dept_ID left outer join
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on Es.desig_ID = DGM.Desig_ID
		

 	RETURN




