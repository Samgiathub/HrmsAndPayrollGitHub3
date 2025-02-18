using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040WorkMaster
{
    public decimal WorkId { get; set; }

    public string WorkName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0150EmpWorkDetail> T0150EmpWorkDetails { get; set; } = new List<T0150EmpWorkDetail>();
}
