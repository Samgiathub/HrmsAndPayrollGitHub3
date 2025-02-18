using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CostCenterMaster
{
    public decimal CenterId { get; set; }

    public decimal CmpId { get; set; }

    public string? CenterName { get; set; }

    public string? CenterCode { get; set; }

    public string? CostElement { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
