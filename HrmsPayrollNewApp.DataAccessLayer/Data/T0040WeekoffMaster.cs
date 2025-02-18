using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040WeekoffMaster
{
    public decimal WId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public string WeekoffName { get; set; } = null!;

    public decimal? WeekoffDay { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login? Login { get; set; }
}
