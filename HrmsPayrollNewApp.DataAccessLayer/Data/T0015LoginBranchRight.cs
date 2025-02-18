using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0015LoginBranchRight
{
    public decimal TranId { get; set; }

    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public virtual T0030BranchMaster Branch { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login Login { get; set; } = null!;
}
