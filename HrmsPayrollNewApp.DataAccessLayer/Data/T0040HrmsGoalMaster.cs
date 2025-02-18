using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsGoalMaster
{
    public decimal GoalId { get; set; }

    public string? GoalTitle { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string? Description { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public DateTime? ForDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? Login { get; set; }

    public virtual ICollection<T0090EmpGoalDetail> T0090EmpGoalDetails { get; set; } = new List<T0090EmpGoalDetail>();
}
