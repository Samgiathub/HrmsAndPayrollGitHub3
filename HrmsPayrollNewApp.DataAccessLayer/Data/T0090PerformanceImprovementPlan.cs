using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090PerformanceImprovementPlan
{
    public decimal EmpPipId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int? PipStatus { get; set; }

    public int? FinYear { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime Enddate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0095PerformanceImprovementPlanDetail> T0095PerformanceImprovementPlanDetails { get; set; } = new List<T0095PerformanceImprovementPlanDetail>();
}
