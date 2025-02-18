using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsMethodMaster
{
    public decimal MethodId { get; set; }

    public decimal CmpId { get; set; }

    public string? Method { get; set; }

    public virtual ICollection<T0110HrmsAppraisalPlanDetail> T0110HrmsAppraisalPlanDetails { get; set; } = new List<T0110HrmsAppraisalPlanDetail>();
}
