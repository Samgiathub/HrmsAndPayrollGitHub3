using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpGoalDetail
{
    public decimal EmpGoalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? GoalId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string GoalStatus { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0040HrmsGoalMaster? Goal { get; set; }

    public virtual ICollection<T0091EmployeeGoalScore> T0091EmployeeGoalScores { get; set; } = new List<T0091EmployeeGoalScore>();
}
