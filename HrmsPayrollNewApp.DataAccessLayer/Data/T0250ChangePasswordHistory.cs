using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250ChangePasswordHistory
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string Password { get; set; } = null!;

    public DateTime EffectiveFromDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }
}
