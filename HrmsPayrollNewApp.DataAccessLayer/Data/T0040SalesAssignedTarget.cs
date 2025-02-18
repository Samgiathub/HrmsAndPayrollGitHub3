using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SalesAssignedTarget
{
    public decimal TargetTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public string? SalesCode { get; set; }

    public decimal? RouteId { get; set; }

    public int? TargetMonth { get; set; }

    public int? TargetYear { get; set; }

    public virtual ICollection<T0050SalesAssignedDetail> T0050SalesAssignedDetails { get; set; } = new List<T0050SalesAssignedDetail>();
}
